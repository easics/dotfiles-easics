import gdb

long_type = None

def clong():
    global long_type
    if not long_type:
        long_type = gdb.lookup_type('long')
    return long_type

def run(command):
    return gdb.execute(command, to_string=True)

def readvar(name):
    return gdb.parse_and_eval(name)

def readvarlong(name):
    return readvar(name).cast(clong())

def setvar(name, value):
    return run('set {}={}'.format(name,value))

class SystemCThread:
    def __init__(self, name, stackpointer):
        self.name = name
        self.stackpointer = stackpointer
        # 25 is movq instruction after all pushqs
        self.qt_blocki = readvarlong("&qt_blocki") + 25

    def printBacktrace(self):
        print(self.name)
        self.switchTo()
        gdb.execute("backtrace")

    def switchTo(self):
        gdb.newest_frame().select() # otherwise we can't change registers
        setvar("$rsp", self.stackpointer)
        # 13 registers saved on stack, so rbp is 13*8 higher than rsp
        setvar("$rbp", self.stackpointer + 8*13)
        setvar("$rip", self.qt_blocki)

class SystemCCommand(gdb.Command):
    """SystemC inspection"""

    def __init__(self):
        gdb.Command.__init__(self, 'sc',
                             gdb.COMMAND_DATA, gdb.COMPLETE_NONE, True)

        SystemCCommand.Thread(self)

        self.sc_cor_qt = None
        self.sc_thread_process = None

        self.regs_dirty = False
        self.rsp_saved = None
        self.rbp_saved = None
        self.rip_saved = None
        self.saved_frame = None

        gdb.events.cont.connect(self.on_continue)

    @staticmethod
    def start():
        systemc = SystemCCommand()

    def thread(self, arg):
        tl = self.getThreads()
        if len(arg) == 0:
            i = 0
            for thread in tl:
                print('{}. {}'.format(i, thread.name))
                i += 1
        else:
            tl[int(arg)].switchTo()

    def on_continue(self, _):
        self.restoreRegs()

    def saveRegs(self):
        if not self.regs_dirty:
            print("Saving regs")
            self.rsp_saved = readvarlong("$rsp")
            self.rbp_saved = readvarlong("$rbp")
            self.rip_saved = readvarlong("$rip")
            self.saved_frame = gdb.selected_frame()
            self.regs_dirty = True

    def restoreRegs(self):
        if self.regs_dirty:
            print("Restoring regs")
            self.regs_dirty = False
            gdb.newest_frame().select() # otherwise we can't change registers
            setvar("$rsp", self.rsp_saved)
            setvar("$rbp", self.rbp_saved)
            setvar("$rip", self.rip_saved)
            self.saved_frame.select()
            self.rsp_saved = None
            self.rbp_saved = None
            self.rip_saved = None
            self.saved_frame = None

    def getThreads(self):
        self.saveRegs();
        if not self.sc_cor_qt:
            self.sc_cor_qt = gdb.lookup_type('sc_core::sc_cor_qt')
        if not self.sc_thread_process:
            self.sc_thread_process = \
              gdb.lookup_type('sc_core::sc_thread_process');
        processtable = readvar('sc_core::sc_curr_simcontext->m_process_table')
        thread = processtable['m_thread_q']
        i = 1
        threadList = []
        while thread != 0:
            name = thread['m_name'].string()
            m_cor_p = thread['m_cor_p']
            m_cor_p = m_cor_p.cast(self.sc_cor_qt.pointer())
            m_sp = m_cor_p.dereference()['m_sp']
            threadList.append(SystemCThread(name, m_sp))
            thread = thread['m_exist_p'].cast(self.sc_thread_process.pointer())
            i += 1
        return threadList

    class Thread(gdb.Command):
        """Manage SystemC threads
           Without arguments : list threads
           With integer argument : switch to select thread"""
        def __init__(self, parent):
            self.parent = parent
            gdb.Command.__init__(self, "sc thread", gdb.COMMAND_DATA,
                                 gdb.COMPLETE_NONE)

        def invoke(self, arg, from_tty):
            self.parent.thread(arg)

def register_systemc():
    SystemCCommand.start()

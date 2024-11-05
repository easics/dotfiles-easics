set history expansion on
set history filename ~/.gdb_history
set history save on

set overload-resolution on
set print object on
set print static-members off
#set auto-solib-add on
set confirm off
set pagination off

set auto-load safe-path /

# Remove annoying color codes in cgdb
set style enabled 0

set python print-stack full

define pnow
  p sc_core::sc_default_global_context[0].m_curr_time.to_string()
end
document pnow
  Print the current time in a SystemC simulation
end

define pdelta
  p sc_core::sc_default_global_context[0].m_delta_count
end
document pdelta
  Print the current delta counter in SystemC (This is _NOT_ the delta cycle
  count in Modelsim)
end

define newstr
  set ($arg0)=(std::string*)malloc(sizeof(std::string))
  call ($arg0)->basic_string()
  # 'assign' returns *this; casting return to void avoids printing of the struct.
  call (void)( ($arg0)->assign($arg1) )
end
document newstr
  Return a pointer to a new string, useful to index maps with strings as keys.
  Example usage:
    newstr $foo "hello world"
    p my_map[*$foo]
end

python
import os
import sys
sys.path.insert(0, os.path.expanduser('~/.gdb/python/systemc'))
import systemc
systemc.register_systemc()
exec(open(os.path.expanduser('~/.gdb/python/ac_types/ac_pp.py')).read())
sys.path.insert(0, '/usr/share/gcc/python')
end

define loadstd
#source /usr/share/gdb/auto-load/usr/lib64/libstdc++.so.6.0.25-gdb.py
  source /home_leuven/eda/gnu/gcc/13.3.0/lib64/libstdc++.so.6.0.32-gdb.py
end
document loadstd
  Load the libstdc++ pretty printers. Normally gdb does this automatically (by
  looking at the shared library list), but when you link libstdc++ statically,
  this doesn't work.
end

define loadsc
  source ~/.gdb/python/sc_pp/sc_pp.py
  py register_systemc23_printers()
end
document loadsc
  Load SystemC pretty printers
end

define loadsk
  source .gdb/python/skip.py
end
document loadsk
  Load a skip list so gdb uses to avoid stepping into C++ standard library code.
  Most of the times you don't want to step into that and it is just annoying to
  have to go through 15 template wrappers to get to your own code
end

# Source local config (without showing a warning if the local file does not exist)
pipe source ~/.gdbinit.local| > /dev/null

set history expansion on
set history filename ~/.gdb_history
set history save on

set overload-resolution on
set print object on
set print static-members off
set print pretty on
set print demangle on
#set auto-solib-add on
set confirm off
set pagination off

set auto-load safe-path /

# Remove annoying color codes in cgdb
set style enabled 0

define pnow
  p sc_core::sc_default_global_context[0].m_curr_time.m_value
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

python
import os
import sys
sys.path.insert(0, os.path.expanduser('~/.gdb/python/systemc'))
import systemc
systemc.register_systemc()
exec(open(os.path.expanduser('~/.gdb/python/ac_types/ac_pp.py')).read())
end

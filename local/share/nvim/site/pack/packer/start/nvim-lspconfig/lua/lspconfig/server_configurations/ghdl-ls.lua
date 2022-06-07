local util = require 'lspconfig.util'

return {
  default_config = {
    cmd = { 'ghdl-ls' },
    filetypes = { 'vhdl' },
    root_dir = util.root_pattern('hdl-prj.json'),
    single_file_support = true,
  },
  docs = {
    description = [[
Language server for ghdl-ls
]],
    default_config = {
      root_dir = [[util.root_pattern('hdl-prj.json')]],
    },
  },
}

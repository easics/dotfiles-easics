local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- config.color_scheme = "AdventureTime"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.set_environment_variables = { SHELL = "/bin/bash" }

config.default_prog = { "/bin/bash", "-l" }

local a = wezterm.action

local function is_inside_vim(pane)
  local tty = pane:get_tty_name()
  if tty == nil then
    return false
  end

  local success, stdout, stderr = wezterm.run_child_process({
    "sh",
    "-c",
    "ps -o state= -o comm= -t"
      .. wezterm.shell_quote_arg(tty)
      .. " | "
      .. "grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'",
  })

  return success
end

local function is_outside_vim(pane)
  return not is_inside_vim(pane)
end

local function bind_if(cond, key, mods, action)
  local function callback(win, pane)
    if cond(pane) then
      win:perform_action(action, pane)
    else
      win:perform_action(a.SendKey({ key = key, mods = mods }), pane)
    end
  end

  return { key = key, mods = mods, action = wezterm.action_callback(callback) }
end

config.keys = {
  bind_if(is_outside_vim, "h", "CTRL", a.ActivatePaneDirection("Left")),
  bind_if(is_outside_vim, "l", "CTRL", a.ActivatePaneDirection("Right")),
  { key = 'r', mods = 'CTRL|SHIFT', action = a.RotatePanes 'Clockwise' },
}

return config

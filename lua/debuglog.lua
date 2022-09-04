local loggers = {}
local loggers_opts = {}
local global_opts = {log_to_console = true, log_to_file = false}
local enabled_loggers = {}
local all_enabled = false
local outfile

local colors = {
  '#0066CC', '#0099CC', '#0099FF', '#00CC00', '#00CC66', '#00CC99', '#00CCFF',
  '#3333FF', '#3366FF', '#3399FF', '#33CC00', '#33CC33', '#33CC66', '#33CC99',
  '#33CCCC', '#33CCFF', '#6600CC', '#6600FF', '#6633CC', '#6633FF', '#66CC00',
  '#66CC33', '#9900CC', '#9900FF', '#9933CC', '#9933FF', '#99CC00', '#99CC33',
  '#CC0000', '#CC0033', '#CC0066', '#CC0099', '#CC00CC', '#CC00FF', '#CC3300',
  '#CC3333', '#CC3366', '#CC3399', '#CC33CC', '#CC33FF', '#CC6600', '#CC6633',
  '#CC9900', '#CC9933', '#CCCC00', '#CCCC33', '#FF0000', '#FF0033', '#FF0066',
  '#FF0099', '#FF00CC', '#FF00FF', '#FF3300', '#FF3333', '#FF3366', '#FF3399',
  '#FF33CC', '#FF33FF', '#FF6600', '#FF6633', '#FF9900', '#FF9933', '#FFCC00',
  '#FFCC33'
}
local hl_groups = {}

local function simple_hash(s)
  local hash = 5381
  for i = 1, #s do
    hash = (bit.lshift(hash, 5) + hash) + string.byte(s, i)
  end
  return hash
end

local function make_logger(name, hl, opts)
  return function(...)
    if not opts.enabled then
      return
    end
    if global_opts.log_to_console then
      local message = string.format(...)
      vim.api.nvim_echo({
        {os.date("%H:%M:%S:"), "Comment"}, {" "}, {name, hl}, {": "}, {message}
      }, true, {})
    end
    if global_opts.log_to_file then
      local fp = io.open(outfile, "a")
      local str = os.date("%H:%M:%S: ") .. string.format(...) .. "\n"
      fp:write(str)
      fp:close()
    end
  end
end

local M = {}

M.setup = function(opts)
  vim.cmd(
    [[comm! -nargs=1 DebugLogEnable :lua require('debuglog').enable(<args>)]])
  vim.cmd([[comm! DebugLogDisable :lua require('debuglog').disable()]])
  outfile = string.format('%s/debug.log',
              vim.api.nvim_call_function('stdpath', {'data'}))
  M.set_config(opts)
end

M.set_config = function(opts)
  opts = opts or {}
  for k, v in pairs(opts) do
    global_opts[k] = v
  end
end

M.outfile = function()
  return outfile
end

M.logger_for_shim_only = function(name)
  local logger = loggers[name]
  if logger then
    return logger
  end
  local opts = {enabled = all_enabled or enabled_loggers[name]}
  local hash = simple_hash(name)
  local color_index = (math.abs(hash) % #colors) + 1
  local hl = "DebugLog" .. color_index
  if not hl_groups[hl] then
    vim.cmd("hi! " .. hl .. " guifg=" .. colors[color_index])
    hl_groups[hl] = true
  end
  logger = make_logger(name, hl, opts)
  loggers[name] = logger
  loggers_opts[name] = opts
  return logger
end

M.enable = function(spec)
  spec = spec or ""
  M.disable()
  local split = vim.split(spec, ",")
  for _, l in ipairs(split) do
    if l == "*" then
      all_enabled = true
      for _, opts in pairs(loggers_opts) do
        opts.enabled = true
      end
    else
      enabled_loggers[l] = true
      local lopts = loggers_opts[l]
      if lopts then
        lopts.enabled = true
      end
    end
  end
end

M.disable = function()
  all_enabled = false
  for _, opts in pairs(loggers_opts) do
    opts.enabled = false
  end
  enabled_loggers = {}
end

local function quote(s)
  return "\"" .. s .. "\""
end

M.install_shim = function(dir)
  assert(dir and dir ~= "", "dir must be specified")

  local is_win = vim.loop.os_uname().sysname == "Windows"
  local path_sep = is_win and "\\" or "/"
  local source = debug.getinfo(2, "S").source:sub(2)
  local current_path = source:match("(.*/)")
  local current_dir = current_path:gsub(path_sep.."([^"..path_sep.."]+)$", function()
    return ""
  end)
  local shim_path = current_dir .. "/../dlog.lua"
  local cmd
  if is_win then
    cmd = "copy /y " .. quote(shim_path) .. " " .. quote(dir + "\\")
  else
    cmd = "cp -f " .. quote(shim_path) .. " " .. quote(dir + "\\")
  end
  if os.execute(cmd) ~= 0 then
    error("Could not copy the shim. Command used: " .. cmd)
  end
  vim.notify("Shim copied to " .. dir)
end

return M

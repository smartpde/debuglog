---dlog is a module for writing debug logs.
---WARNING: This file is auto-generated, DO NOT MODIFY.
---
---Example usage:
---  local d = require("dlog")("my_logger")
---  d("Formatted lua string %s, number %d, etc", "test", 42)
---
---This will print "Formatted lua string test, number 42, etc"
---
---If debug-log plugin is not installed, all logs are no-op.
---Read more at https://github.com/smartpde/debug-log#shim
local has_debuglog, debuglog = pcall(require, "debuglog")

local function noop()
end

if has_debuglog then
  return debuglog.logger_for_shim_only
end
return noop

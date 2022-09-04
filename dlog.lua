local has_debuglog, debuglog = pcall(require, "debuglog")

local function noop()
end

if has_debuglog then
  return debuglog.logger_for_shim_only
end
return noop

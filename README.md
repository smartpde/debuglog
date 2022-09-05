# debuglog for Neovim plugin developers

`debuglog` is made for Neovim plugin developers to debug the plugin locally, or collect
debugging info from users.

With `debuglog`, you leave the debug statements in the code. By default, nothing is logged,
but you can enable the loggers selectively.

The users of your plugin do _not_ need the `debuglog` to be installed. All logging is done
through the tiny [shim](#shim) file that you include in your plugin. Without the full
`debuglog` module, everything is a no-op.

## Installation

To install the plugin with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {"smartpde/debuglog"}
```

Once installed, call the `setup()` function to register various commands:
```lua
require("debuglog").setup()
```

## Shim

`debuglog` is an optional dependency of your plugin, therefore you must install the tiny
shim file [dlog.lua](https://github.com/smartpde/debuglog/blob/main/dlog.lua) into your
plugin's directory. The shim checks if the full `debuglog` module is present, and turns
all logging into a no-op otherwise.

There is a simple command to copy the shim file for you:

```
:DebugLogInstallShim <path to plugin_dir/lua>

For example:
:DebugLogInstallShim ~/projects/my_awesome_plugin/lua
```

You can of course copy the file any other way.

## Writing debug statements

Note that all debug loggers must be created using the `dlog` shim module:

```lua
-- Enable logging by running ":DebugLogEnable *" command first.

local dlog = require("dlog")
local logger1 = dlog("logger1")
local logger2 = dlog("logger2")

logger1("This is from %s", "logger1")
logger1("This is also from %s", "logger1")
logger2("And this is from %s", "logger2")
```

You can create many named loggers, the logger name will be attached to all its
messages. Additionally, log statements in the vim `:messages` will be nicely colored
for easier identification:

<img width="831" alt="image" src="https://user-images.githubusercontent.com/16953692/188493270-039a3bf8-34f6-4664-8a87-85d9b58c5003.png">

The loggers use standard Lua's [string.format()](https://www.lua.org/pil/20.html).

## Enable and disable logging

By default, nothing is logged unless you enable the loggers. To do so you can use the plugin
commands:

- Enable all loggers:

  ```
  :DebugLogEnable *
  ```

- Enable loggers selectively:

  ```
  :DebugLogEnable some_logger,another_logger
  ```

  Note that enabling new loggers disables all previous ones.

- Disable all logging:

  ```
  :DebugLogDisable
  ```

You can also use the corresponding Lua functions:

```lua
local debuglog = require("debuglog")
debuglog.enable("*")
debuglog.disable()
```

## Logging to file

By default, logs are written only to the `:messages` console. You can also enable logging
to a file:

- With user command:

  ```
  :DebugLogEnableFileLogging
  ```

- With Lua:

  ```lua
  require("debuglog").set_config({
    log_to_file = true,
    log_to_console = true,
  })
  ```

The log file path will be printed out. You can also use the following command
open the log file in Neovim:

```
:DebugLogOpenFileLog
```

Or get the log file path in Lua:

```lua
require("debuglog").log_file_path()
```

To disable file logging run:
```
:DebugLogDisableFileLogging
```

## Configuration options

The full list of configuration options with their defaults:

```lua
require("debuglog").setup({
  log_to_console = true,
  log_to_file = false,
  -- The highlight group for printing the time column in console
  time_hl_group = "Comment",
})
```

The options can also be modified by calling the `set_config(opts)` function
after the setup.

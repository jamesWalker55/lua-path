--- A port of some functions from Python's os.path module

local is_windows = nil

if pandoc == nil then
  -- https://stackoverflow.com/questions/295052/how-can-i-determine-the-os-of-the-system-from-within-a-lua-script
  -- http://www.lua.org/manual/5.2/manual.html#pdf-package.config
  local separator = package.config:sub(1, 1)
  is_windows = separator == "\\"
else
  -- Possible values are taken from here: https://hackage.haskell.org/package/base-4.16.0.0/docs/System-Info.html
  -- The value "mingw32" means Windows
  is_windows = pandoc.system.os == "mingw32"
end

if is_windows then
  return require "ntpath"
else
  return require "pathnx"
end

-- port of os.path for Linux-based systems

local module = {}

--- Split a pathname into drive and path. On Posix, drive is always empty.
--- @param path string
function module.splitdrive(path)
  return "", path
end

--[[
Join two or more pathname components, inserting '/' as needed.
If any component is an absolute path, all previous path components
will be discarded.  An empty last part will result in a path that
ends with a separator.
--]]
function module.join(a, ...)
  local p = { ... }
  local path = a
  for _, b in ipairs(p) do
    if b:sub(1, 1) == "/" then
      path = b
    elseif #path == 0 or path:sub(-1, -1) == "/" then
      path = path .. b
    else
      path = path .. "/" .. b
    end
  end
  return path
end

return module

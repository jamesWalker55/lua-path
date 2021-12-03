-- port of os.path for Linux-based systems

local util = require("util")
local common = require("genericpath")

local contains = util.contains

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

--- Split a path in root and extension.
--- The extension is everything starting at the last dot in the last
--- pathname component; the root is everything before that.
--- It is always true that root + ext == p.
function module.splitext(p)
  return common.splitext(p, "/", nil, ".")
end

-- Normalize a path, e.g. A//B, A/./B and A/foo/../B all become A/B.
-- It should be understood that this may change the meaning of the path
-- if it contains symbolic links!

--- Normalize path, eliminating double slashes, etc.
--- @param path string
function module.normpath(path)
  if #path == 0 then
    return "."
  end

  local initial_slashes = path:sub(1, 1) == "/"
  -- POSIX allows one or two initial slashes, but treats three or more as single slash.
  if initial_slashes and path:sub(2, 2) == "/" and not (path:sub(3, 3) == "/") then
    initial_slashes = 2
  end

  local comps = util.split(path, "[^/]*")
  local new_comps = {}
  for _, comp in ipairs(comps) do
    if contains(comp, { "", "." }) then
      goto continue
    end

    if
      comp ~= ".."
      or (not initial_slashes and #new_comps == 0)
      or (#new_comps > 0 and new_comps[#new_comps] == "..")
    then
      table.insert(new_comps, comp)
    elseif #new_comps > 0 then
      table.remove(new_comps)
    end
    ::continue::
  end
  comps = new_comps
  path = table.concat(comps, "/")
  if initial_slashes then
    if initial_slashes == true then
      initial_slashes = 1
    end

    path = ("/"):rep(initial_slashes) .. path
  end

  if #path > 0 then
    return path
  else
    return "."
  end
end

return module

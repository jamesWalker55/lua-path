-- port of os.path for Windows

local util = require "util"
local common = require "pathcommon"

local contains = util.contains

local module = {}


function module.splitext(p)
  return common.splitext(p, '\\', '/', '.')
end


--- @param path string
function module.splitdrive(path)
  if #path >= 2 then
    -- normalized path, by replacing all forward slashes with backslashes
    local npath = path:gsub("/", "\\")
    if npath:sub(1, 2) == "\\\\" and npath:sub(3, 3) ~= "\\" then
      -- this is a UNC path (starts with 2 backslashes)

      -- |---drive letter---|
      -- \\machine\mountpoint\directory\etc\...
      --                     |---directory----|

      local first_sep = npath:find("\\", 3)
      if first_sep == nil then return "", path end

      -- a UNC path can't have 2 slashes in a row (other than the first two)
      local second_sep = npath:find("\\", first_sep + 1)
      if second_sep == first_sep + 1 then return "", path end

      if second_sep == nil then
        return path, ""
      else
        return path:sub(1, second_sep - 1), path:sub(second_sep)
      end
    end

    if path:sub(2, 2) == ":" then return path:sub(1, 2), path:sub(3) end
  end

  return "", path
end


function module.join(path, ...)
  local paths = { ... }

  local result_drive, result_path = module.splitdrive(path)

  -- iterate for 2nd path onwards
  for _, p in ipairs(paths) do
    local p_drive, p_path = module.splitdrive(p)
    if #p_path > 0 and contains(p_path:sub(1, 1), {"\\", "/"}) then
      -- second path is absolute
      if #p_drive > 0 or #result_drive == 0 then result_drive = p_drive end

      result_path = p_path
      goto continue
    elseif #p_drive > 0 and p_drive ~= result_drive then
      if p_drive:lower() ~= result_drive:lower() then
        -- Different drives => ignore the first path entirely
        result_drive = p_drive
        result_path = p_path
        goto continue
      end
      -- Same drive in different case
      result_drive = p_drive
    end
    -- Second path is relative to the first
    if #result_path > 0 and not contains(result_path:sub(-1, -1), {"\\", "/"}) then
      result_path = result_path .. "\\"
    end
    result_path = result_path .. p_path
    ::continue:: ;
  end
  -- add separator between UNC and non-absolute path
  if
    #result_path > 0
    and (result_path:sub(0, 0) ~= "\\" or result_path:sub(0, 0) ~= "/")
    and #result_drive > 0
    and result_drive:sub(-1, -1) ~= ":"
  then
    return result_drive .. "\\" .. result_path
  end

  return result_drive .. result_path
end



-- Normalize a path, e.g. A//B, A/./B and A/foo/../B all become A\B.
-- Previously, this function also truncated pathnames to 8+3 format,
-- but as this module is called "ntpath", that's obviously wrong!

--- Normalize path, eliminating double slashes, etc.
function module.normpath(path)
  if contains(path:sub(1, 4), {[[\\.\]], [[\\?\]]}) then
    -- in the case of paths with these prefixes:
    -- \\.\ -> device names
    -- \\?\ -> literal paths
    -- do not do any normalization, but return the path
    -- unchanged apart from the call to os.fspath()
    return path
  end

  path = path:gsub("/", "\\")
  local prefix, path = module.splitdrive(path)

  -- collapse initial backslashes
  if path:sub(1,1) == "\\" then
    prefix = prefix .. "\\"

    path = ({path:gsub("^\\+", "")})[1]
  end

  -- split by separator into list
  local comps = util.split(path, "[^\\\\]*")
  local i = 1
  while i <= #comps do
    if #comps[i] == 0 or comps[i] == "." then
      table.remove(comps, i)
    elseif comps[i] == ".." then
      if i > 1 and comps[i-1] ~= ".." then
        for _ = 0, 1 do -- do twice
          table.remove(comps, i - 1)
        end
        i = i - 1
      elseif i == 1 and prefix:sub(-1, -1) == "\\" then
        table.remove(comps, i)
      else
        i = i + 1
      end
    else
      i = i + 1
    end
  end
  -- If the path is now empty, substitute '.'
  if #prefix == 0 and #comps == 0 then
    comps[#comps + 1] = "."
  end
  return prefix .. table.concat(comps, "\\")
end


--- Test whether a path is absolute
--- @param path string
function module.isabs(path)
  -- Paths beginning with \\?\ are always absolute, but do not necessarily contain a drive.
  local ABS_PATTERN = [[\\?\]]
  if path:gsub('/', '\\'):sub(1, 4) == ABS_PATTERN then return true end

  _, path = module.splitdrive(path)
  return #path > 0 and contains(path:sub(1, 1), {"/", "\\"})
end


--- Get the current working directory
--- There is no native function to do this, you MUST use an external library for this
function module.getcwd()
  assert(pandoc ~= nil, "#getcwd is only supported in a Pandoc environment")
  return pandoc.system.get_working_directory()
end

--- Return an absolute path.
--- @param path string
function module.abspath(path)
  if not module.isabs(path) then
    local cwd = module.getcwd()
    path = module.join(cwd, path)
  end
  return module.normpath(path)
end

print(module.join("c:/windows", "test", "hi"))
print(module.isabs("c:/windows"))
print(module.isabs("c:windows"))
print(debug.getinfo(1).short_src)
print(debug.getinfo(1).source)
print(module.normpath([[A//B]]))
print(module.normpath([[A/./B]]))
print(module.normpath([[A/foo/../B]]))
print(module.normpath([[A\B]]))
print(module.abspath([[A\B/../..]]))
print(module.abspath([[A\B/../../..]]))

return module

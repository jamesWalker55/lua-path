-- port of os.path for Windows

local util = require "util"

local contains = util.contains

local module = {}


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

  assert(#paths >= 1, "At least 1 path must be given as input")

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

print(module.join("c:/windows", "test", "hi"))

return module

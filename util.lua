local module = {}

function module.contains(val, arr)
  for _, x in ipairs(arr) do
    if val == x then return true end
  end
  return false
end

return module

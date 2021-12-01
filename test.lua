local module = {}


function module.lists(a, b)
  assert(#a == #b, ("Tables have different length: %s ~= %s"):format(#a, #b))
  for i=1,#a do
    assert(a[i] == b[i], ("Tables have different content: %s ~= %s"):format(a[i], b[i]))
  end
end


return module

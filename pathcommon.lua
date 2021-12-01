local module = {}


function module.splitext(p, sep, altsep, extsep)
  for i, x in ipairs({sep, altsep, extsep}) do
    assert(#x == 1, "Input separator must be a single char")
  end

  local sepIndex = ({p:find(".*%" .. sep)})[2] or -1

  if altsep ~= nil then
    local altsepIndex = ({p:find(".*%" .. altsep)})[2] or -1
    sepIndex = math.max(sepIndex, altsepIndex)
  end

  local dotIndex = ({p:find(".*%" .. extsep)})[2] or -1
  if dotIndex > sepIndex then
    -- skip all leading dots
    local filenameIndex = sepIndex + 1
    while filenameIndex < dotIndex do
      if p:sub(filenameIndex, filenameIndex) ~= extsep then
        return p:sub(1, dotIndex - 1), p:sub(dotIndex)
      end
      filenameIndex = filenameIndex + 1
    end
  end

  return p, ""
end


return module
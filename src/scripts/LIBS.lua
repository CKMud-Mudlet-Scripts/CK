-- Quality Of Life functions
function math.round(x, n)
  return tonumber(string.format("%." .. n .. "f", x))
end

function math.format(i)
  return tostring(i):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function table.sample_keys(tb)
  local keys = {}
  for k, v in pairs(tb) do
    table.insert(keys, k)
  end
  return keys[math.random(#keys)]
end

function table.sample_items(tl)
  local pos = math.floor(math.random() * #tl) + 1
  return tl[pos]
end

function table.append(list, item)
  list[#list + 1] = item
end

function table.extend(list, items)
  for _, item in ipairs(items) do
    list[#list + 1] = item
  end
end
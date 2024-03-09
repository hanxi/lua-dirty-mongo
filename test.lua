function dump_table(table, indent)
indent = indent or ""
  -- 判断table是否为空
  if table == nil then
    return "nil"
  end

  -- 判断table是否为基础类型
  if type(table) ~= "table" then
    return tostring(table)
  end

  -- 初始化输出字符串
  local output = "{\n"

  -- 遍历table中的所有键值对
  for k, v in pairs(table) do
    -- 缩进
    output = output .. indent .. "  "

    -- 转储键
    output = output .. tostring(k) .. " = "

    -- 转储值
    output = output .. dump_table(v, indent .. "  ") .. ",\n"
  end

  -- 缩进
  output = output .. indent .. "}"

  -- 返回输出字符串
  return output
end

local dirtydoc = require "dirtydoc"

local obj = dirtydoc.new()

obj.a = "a"
obj.b = "b"
obj.arr = {1,2,3}

print("obj:", dump_table(obj))

local dirty,result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

obj.a = "aa"
obj.arr[1] = 11
obj.arr[3] = nil
obj.arr[3] = nil
obj.hash = {
	x = "x"
}

local dirty,result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

print("obj:", dump_table(obj))

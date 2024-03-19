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
local schema = require "schema"

-- 如果 debug 环境有做覆盖率测试的话
-- release 环境可以把 schema 设置为空表
dirtydoc.need_schema = true

local obj = dirtydoc.new(schema.user)

obj.user_id = 10086
obj.item = dirtydoc.new(schema.item)
obj.item.item_id = 1001
obj.item = dirtydoc.new(schema.item)
obj.name = "hanxi"
obj.item.item_id = "hanxi"

obj.item.item_id = 10010
print("test __index", obj.item.item_id)

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

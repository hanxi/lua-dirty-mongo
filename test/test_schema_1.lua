package.path = package.path .. ";" .. "../?.lua"

local dirtydoc = require("dirtydoc")
local schema = require("schema")
local dump_table = require("dump_table")

-- 如果 debug 环境有做覆盖率测试的话
-- release 环境可以把 schema 设置为空表
dirtydoc.need_schema = true

local obj = dirtydoc.new(schema.user)

-- 正常的初始化赋值操作 obj 对应数据库的根节点数据
obj.user_id = 10086
obj.item = dirtydoc.new(schema.item)
obj.item.item_id = 1001
obj.items = dirtydoc.new(schema.arr_item)
local item = dirtydoc.new(schema.item)
item.item_id = 100
obj.items[1] = item
local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

-- 定义一个 item 并对其初始化
local item = dirtydoc.new(schema.item)
item.item_id = 200

-- 把 item 赋值到数据库数据后不能再次修改
-- 因为再次对 item 的修改无法在 obj 里监听到
print("=== check right value can't rewrite again")
obj.items[2] = item
item.can = true
local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

-- 再次完整覆盖整个 item 是可以监听到
print("=== set value again")
obj.item = item
local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

-- 赋值不是 scheme 会报错
print("=== check error set no schema value")
obj.item = {
	item_id = 300,
}
local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

-- 删除元素
print("=== set value nil")
obj.items[2] = nil
local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

-- 测试不存在的字段赋值
print("=== set value not in schema")
obj.a = "a"
obj.b = "b"
obj.arr = { 1, 2, 3 }


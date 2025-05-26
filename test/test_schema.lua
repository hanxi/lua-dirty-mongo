package.path = package.path .. ";" .. "../?.lua"

local dump_table = require("dump_table")
local dirtydoc = require("dirtydoc")
local schema = require("schema")

-- 本文件模拟 mongodb 从数据库加载数据和保存数据
-- obj 对应数据库中的 user 字段
local obj = dirtydoc.new(schema.user)

obj.user_id = 10086
obj.item = dirtydoc.new(schema.item)
obj.item.item_id = 1001
obj.name = "hanxi"
obj.items = dirtydoc.new(schema.arr_item)
print("=== init")
local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

-- 如果需要修改子表，需要先取引用再修改
local item = obj.item
item.item_id = 1002
print("=== 修改 item_id")
local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

-- 重新完整赋值 item
local item = dirtydoc.new(schema.item)
-- 没赋值给 obj 之前的 item 还能修改
item.item_id = 1003
obj.item = item
print("=== 完全覆盖 item")
local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

print("=== 不能再修改已赋值给 obj 之后的 item")
item.item_id = 1004
local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

package.path = package.path .. ";" .. "../?.lua"

local dirtydoc = require("dirtydoc")
local schema = require("schema")
local dump_table = require("dump_table")

-- 如果 debug 环境有做覆盖率测试的话
-- release 环境可以把 schema 设置为空表
dirtydoc.need_schema = true

local obj = dirtydoc.new(schema.user)

obj.user_id = 10086
obj.item = dirtydoc.new(schema.item)
obj.item.item_id = 1001
obj.items = dirtydoc.new(schema.arr_item)
local item = dirtydoc.new(schema.item)
item.item_id = 100
obj.items[1] = item
local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

local item = dirtydoc.new(schema.item)
item.item_id = 200
obj.items[2] = item
item.can = true

local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

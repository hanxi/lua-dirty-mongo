package.path = package.path .. ";" .. "../?.lua"

local dump_table = require("dump_table")
local dirtydoc = require("dirtydoc")

local obj = dirtydoc.new()

obj.a = "a"
obj.b = "b"
obj.arr = { 1, 2, 3 }

print("obj:", dump_table(obj))

local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

obj.a = "aa"
obj.arr[1] = 11
obj.arr[3] = nil
obj.arr[3] = nil
obj.hash = {
    x = "x",
}

local dirty, result = dirtydoc.commit_mongo(obj)
print("dirty:", dirty, "result:", dump_table(result))

print("obj:", dump_table(obj))

local test = dirtydoc.new()
test.a = dirtydoc.new(nil, {[31]={1}})

local temp= test.a[31]
temp[1] = 2
temp[2] = 2

local dirty,result = dirtydoc.commit_mongo(test)
print("dirty:", dirty, "result:", dump_table(result))

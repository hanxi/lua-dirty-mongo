-- see https://github.com/hanxi/lua-dirty-mongo/issues/3

package.path = package.path .. ";" .. "../?.lua"

local dump_table = require("dump_table")
local dirtydoc = require("dirtydoc")

local test = dirtydoc.new()
test.data = {
  {
    {value=1},
    {value=2},
  }, 
  {
    {value=3},
    {value=4},
  }
}
local dirty,result = dirtydoc.commit_mongo(test)
print("dirty:", dirty, "result:", dump_table(result))

test.data[1][2].value = 99

print("=============")
local dirty,result = dirtydoc.commit_mongo(test)
print("dirty:", dirty, "result:", dump_table(result))

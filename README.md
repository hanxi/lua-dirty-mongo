# lua-dirty-mongo
适配 MongoDB 的差异脏数据

全新版本见 : <https://github.com/hanxi/sproto-orm>

## 定义 schema 结构

采用 proto3 语法定义，支持 map 和 array 结构，基础数据类型支持 number, bool, string 三种，其中 `int32,uint32,int64,uint64,double,float` 都是生成一样的 number 类型。比如可以这样定义：

```proto
syntax = "proto3";

message user {
    int64 user_id = 1;
    string name = 2;
    item item = 3;
    repeated item items = 4;
    map<int32,item> mitems = 5;
}

message item {
    int32 item_id = 1;
    map<int32,int32> props = 2;
    repeated int32 list = 3;
    map<string,string> ss= 4;
    bool can = 5;
}
```

使用命令 `lua tools/gen_schema.lua test/schema.proto test/schema.lua` 可以将 test/schema.proto 文件生成 test/schema.lua 文件，这个文件用于开发中定义使用到的数据结构。注意只支持一个 proto 文件，不支持 import 多个文件。

## 差异脏数据

可以参考如下示例 test/test_schema_1.lua ：

```lua
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
```

输出结果如下：
```txt
dirty:  table: 0x55f5221b4c20   result: {
  $set = {
    item = {
      item_id = 1001,
    },
    items = {
      1 = {
        item_id = 100,
      },
    },
    user_id = 10086,
  },
  $unset = {
  },
}
dirty:  table: 0x55f5221bf650   result: {
  $set = {
    items.2 = {
      item_id = 200,
    },
  },
  $unset = {
  },
}
```

生成的差异修改结果可以直接用于 MongoDB 的 update 接口。

## TODO
- [x] 在 [hanxi/skynet-demo](https://github.com/hanxi/skynet-demo) 中加入使用示例

## 参考

- [适合游戏服务器开发的ORM](https://blog.hanxi.cc/p/93/)
- [tracedoc doc](https://blog.codingnow.com/2017/02/tracedoc.html)
- [jojo59516/tracedoc](https://github.com/jojo59516/tracedoc)
- [cloudwu/tracedoc](https://github.com/cloudwu/tracedoc)



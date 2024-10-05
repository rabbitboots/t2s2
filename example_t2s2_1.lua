-- T2S2: An example without format tables.


local inspect = require("test.inspect")
local t2s2 = require("t2s2")


-- The table to serialize.
local tbl = {
  [1] = true,
  [false] = "&",
  str = {
    [(1/0)] = (0/0), -- key is inf, value is NaN
    foo = {
      "bar",
      seq = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25}
    }
  }
}


local str = t2s2.serialize(tbl)
print("Output:\n\n" .. str)

--[[
return {
  [false] = "&",
  [1] = true,
  str = {
    [1/0] = 0/0,
    foo = {
      [1] = "bar",
      seq = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25
      }
    }
  }
}
--]]


print("\nCompare with the reloaded table:\n")
local ok, reloaded = assert(t2s2.deserialize(str))

print(inspect(reloaded))


-- T2S2: An example of using priority lists to set the order of certain keys.


local t2s2 = require("t2s2")


-- The table to serialize.
local rooms = {
	{
		name = "Red room",
		location = "North",
		boxes = {
			{x=0, y=0, w=16, h=16},
			{y=144, w=24, h=12, x=28},
			{w=32, h=32, x=144, y=96},
			{h=4, x=68, y=86, w=2},
		}
	}, {
		name = "Green room",
		location = "West",
		boxes = {
			{x=9, y=44, w=11, h=11},
			{y=28, w=12, h=14, x=160},
			{h=24, x=70, y=22, w=64},
		}
	}, {
		boxes = {
			{w=128, h=128},
		},
		location = "North-West",
		name = "Blue room"
	}
}

-- Priority lists.
local pri_box = {"x", "y", "w", "h"}
local pri_room = {"name", "location", "boxes"}


-- Set up the registry
local reg = {}

for _, room in ipairs(rooms) do
	reg[room] = pri_room
	for _, box in ipairs(room.boxes) do
		reg[box] = pri_box
	end
end

local str = t2s2.serialize(rooms, reg)


if not t2s2.getMissingPriorityFatal() then
	print("NOTE: One box in the blue room is missing keys 'x' and 'y'.")
	print("Use t2s2.setMissingPriorityFatal(true) to make missing priority keys raise a Lua error.")
	print("Otherwise, they will be silently ignored.")
end

print("Serialized output:\n\n" .. str)


--[[
return {
  {
    name = "Red room",
    location = "North",
    boxes = {
      {
        x = 0,
        y = 0,
        w = 16,
        h = 16
      }, {
        x = 28,
        y = 144,
        w = 24,
        h = 12
      }, {
        x = 144,
        y = 96,
        w = 32,
        h = 32
      }, {
        x = 68,
        y = 86,
        w = 2,
        h = 4
      }
    }
  }, {
    name = "Green room",
    location = "West",
    boxes = {
      {
        x = 9,
        y = 44,
        w = 11,
        h = 11
      }, {
        x = 160,
        y = 28,
        w = 12,
        h = 14
      }, {
        x = 70,
        y = 22,
        w = 64,
        h = 24
      }
    }
  }, {
    name = "Blue room",
    location = "North-West",
    boxes = {
      {
        w = 128,
        h = 128
      }
    }
  }
}
--]]


-- Without the 'reg' table in argument 2, the order would be 'boxes', 'location', 'name'.

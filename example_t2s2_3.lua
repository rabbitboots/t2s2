-- T2S2: An example of specifying priority lists indirectly, through a table's metatable.


local t2s2 = require("t2s2")


local _mt_person = {
	name = "unknown",
	head = "nothin'",
	l_arm = "nada",
	r_arm = "not a thing",
	torso = "nil",
	legs = "null",
	feet = "zip",
}


-- Make some people.
local function newPerson(head, l_arm, r_arm, torso, legs, feet)
	return setmetatable({head=head, l_arm=l_arm, r_arm=r_arm, torso=torso, legs=legs, feet=feet}, _mt_person)
end


-- The table to serialize.
local people = {
	--                    HEAD         L_ARM         R_ARM         TORSO        LEGS          FEET
	bimmy =     newPerson("cap",       "watch",      nil,          "shirt",     "shorts",     "sandals"   ),
	goober =    newPerson("goo",       "goo",        "goo",        "goo",       "goo",        "goo"       ),
	ripentear = newPerson("iron_helm", "iron_glove", "iron_glove", "iron_vest", "iron_pants", "iron_boots"),
	jolie =     newPerson("shades",    "arm_warmer", "arm_warmer", "oildrum",   "skirt",      "sneakers"  )
}

-- Put goober first, the rest in alphabetical order.
local pri_group = {"goober"}

-- Maintain the order or body parts used above.
local pri_individual = {"head", "l_arm", "r_arm", "torso", "legs", "feet"}

local reg = {
	[people]=pri_group,
	[_mt_person]=pri_individual -- < applies to all tables with this metatable attached
}

print(t2s2.serialize(people, reg))


-- Note that Bimmy's right arm is not part of the output; T2S2 does not serialize the contents of attached metatables.


-- Output:

--[[
return {
  goober = {
    head = "goo",
    l_arm = "goo",
    r_arm = "goo",
    torso = "goo",
    legs = "goo",
    feet = "goo"
  },
  bimmy = {
    head = "cap",
    l_arm = "watch",
    torso = "shirt",
    legs = "shorts",
    feet = "sandals"
  },
  jolie = {
    head = "shades",
    l_arm = "arm_warmer",
    r_arm = "arm_warmer",
    torso = "oildrum",
    legs = "skirt",
    feet = "sneakers"
  },
  ripentear = {
    head = "iron_helm",
    l_arm = "iron_glove",
    r_arm = "iron_glove",
    torso = "iron_vest",
    legs = "iron_pants",
    feet = "iron_boots"
  }
}
--]]


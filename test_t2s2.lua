-- Test: t2s2.lua


local PATH = ... and (...):match("(.-)[^%.]+$") or ""


local _load = loadstring or load


require(PATH .. "test.strict")


local errTest = require(PATH .. "test.err_test")
local inspect = require(PATH .. "test.inspect")
local t2s2 = require(PATH .. "t2s2")


local hex = string.char


local cli_verbosity
for i = 0, #arg do
	if arg[i] == "--verbosity" then
		cli_verbosity = tonumber(arg[i + 1])
		if not cli_verbosity then
			error("invalid verbosity value")
		end
	end
end


local self = errTest.new("t2s2", cli_verbosity)


local function _resetT2S2()
	t2s2.setFormatting()
	t2s2.setExpandedNames()
	t2s2.setMissingPriorityFatal()
	t2s2.setMaxDepth()
	t2s2.setMaxBytes()
end


-- [===[
self:registerFunction("t2s2.getFormatting()", t2s2.getFormatting)
self:registerFunction("t2s2.setFormatting()", t2s2.setFormatting)
self:registerJob("getFormatting() + setFormatting()", function(self)

	_resetT2S2()

	-- [====[
	do
		_resetT2S2()
		self:expectLuaError("setFormatting() arg #1 bad type", t2s2.setFormatting, {})
		self:expectLuaError("setFormatting() arg #2 bad type", t2s2.setFormatting, " ", {})
		self:expectLuaError("setFormatting() arg #3 bad type", t2s2.setFormatting, " ", "\n", {})
		self:expectLuaError("setFormatting() arg #4 bad type", t2s2.setFormatting, " ", "\n", "\t", {})
		self:expectLuaError("setFormatting() arg #5 bad type", t2s2.setFormatting, " ", "\n", "\t", 0, {})
		self:expectLuaError("setFormatting() arg #6 bad type", t2s2.setFormatting, " ", "\n", "\t", 0, ",", {})
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:expectLuaReturn("setFormatting() expected behavior", t2s2.setFormatting, "  ", "\n\n", "\t\t", -1, ";", 100)
		local s, l, i, d, x, c = self:expectLuaReturn("getFormatting() expected behavior", t2s2.getFormatting)
		self:isEqual(s, "  ")
		self:isEqual(l, "\n\n")
		self:isEqual(i, "\t\t")
		self:isEqual(d, -1)
		self:isEqual(x, ";")
		self:isEqual(c, 100)
	end
	--]====]
end
)
--]===]


-- [===[
self:registerFunction("t2s2.getExpandedNames()", t2s2.getExpandedNames)
self:registerFunction("t2s2.setExpandedNames()", t2s2.setExpandedNames)
self:registerJob("getExpandedNames() + setExpandedNames()", function(self)

	-- [====[
	do
		_resetT2S2()
		self:expectLuaReturn("setExpandedNames() expected behavior", t2s2.setExpandedNames, true)
		local ret = self:expectLuaReturn("getExpandedNames() expected behavior", t2s2.getExpandedNames)
		self:isEqual(ret, true)
	end
	--]====]
end
)
--]===]


-- [===[
self:registerFunction("t2s2.getMissingPriorityFatal()", t2s2.getMissingPriorityFatal)
self:registerFunction("t2s2.setMissingPriorityFatal()", t2s2.setMissingPriorityFatal)
self:registerJob("getMissingPriorityFatal() + setMissingPriorityFatal()", function(self)

	-- [====[
	do
		_resetT2S2()
		self:expectLuaReturn("setMissingPriorityFatal() expected behavior", t2s2.setMissingPriorityFatal, true)
		local ret = self:expectLuaReturn("getMissingPriorityFatal() expected behavior", t2s2.getMissingPriorityFatal)
		self:isEqual(ret, true)
	end
	--]====]
end
)
--]===]


-- [===[
self:registerFunction("t2s2.getMaxDepth()", t2s2.getMaxDepth)
self:registerFunction("t2s2.setMaxDepth()", t2s2.setMaxDepth)
self:registerJob("getMaxDepth() + setMaxDepth()", function(self)

	self:expectLuaError("setMaxDepth() arg #1 bad type", t2s2.setMaxDepth, true)


	-- [====[
	do
		_resetT2S2()
		self:expectLuaReturn("setMaxDepth() expected behavior", t2s2.setMaxDepth, 123)
		local ret = self:expectLuaReturn("getMaxDepth() expected behavior", t2s2.getMaxDepth)
		self:isEqual(ret, 123)
	end
	--]====]
end
)
--]===]


-- [===[
self:registerFunction("t2s2.getMaxBytes()", t2s2.getMaxBytes)
self:registerFunction("t2s2.setMaxBytes()", t2s2.setMaxBytes)
self:registerJob("getMaxBytes() + setMaxBytes()", function(self)

	self:expectLuaError("setMaxBytes() arg #1 bad type", t2s2.setMaxBytes, true)


	-- [====[
	do
		_resetT2S2()
		self:expectLuaReturn("setMaxBytes() expected behavior", t2s2.setMaxBytes, 600)
		local ret = self:expectLuaReturn("getMaxBytes() expected behavior", t2s2.getMaxBytes)
		self:isEqual(ret, 600)
	end
	--]====]
end
)
--]===]


-- [===[
self:registerFunction("t2s2.serialize()", t2s2.serialize)
self:registerJob("serialize()", function(self)

	-- [====[
	do
		_resetT2S2()
		local ser = self:expectLuaReturn("t2s2.serialize() minimal table", t2s2.serialize, {})
		self:isEvalTrue(ser:find("^%s*return%s*{%s*}%s*$"))
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] Values: strings, numbers (inf, NaN), booleans, tables")

		local tbl = {
			str = "string",
			int = 100,
			negative_int = -99,
			decimal = 0.1,
			decimal2 = 0.0000000000001,
			bool_true = true,
			bool_false = false,
			hex = 0xff,
			tbl = {},
			inf = (1/0),
			nan = (0/0),
		}
		local str = t2s2.serialize(tbl)
		local t2 = _load(str)()

		self:isType(t2, "table")

		self:isEqual(t2.str, "string")
		self:isEqual(t2.int, 100)
		self:isEqual(t2.negative_int, -99)
		self:isEqual(t2.decimal, 0.1)
		self:isEqual(t2.decimal2, 0.0000000000001)
		self:isEqual(t2.bool_true, true)
		self:isEqual(t2.bool_false, false)
		self:isEqual(t2.hex, 0xff)
		self:isType(t2.tbl, "table")
		self:isEqual(t2.inf, (1/0))
		self:isNotEqual(t2.nan, (0/0))

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:expectLuaError("cannot serialize functions", t2s2.serialize, {function() end})
		self:expectLuaError("cannot serialize tables as keys", t2s2.serialize, {[{}]="bar"})
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] minify test (empty space, newline, indent strings)")

		t2s2.setFormatting("", "", "")
		local tbl = {1, 2, 3, 4, 5, {foo="bar", baz="bop"}}
		local str = t2s2.serialize(tbl)

		self:isEqual(str, [[return{1,2,3,4,5,{baz="bop",foo="bar"}}]])

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] cancel first-level indent")

		t2s2.setFormatting(nil, nil, nil, -1)
		local tbl = {foo="bar", baz="bop"}
		local str = t2s2.serialize(tbl)

		self:isEqual(str, 'return {\nbaz = "bop",\nfoo = "bar"\n}')

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] use semicolon as separator")

		t2s2.setFormatting(nil, nil, nil, nil, ";", nil)
		local tbl = {1, 2, 3, 4, 5}
		local str = t2s2.serialize(tbl)

		self:print(3, str)

		self:isEvalTrue(str:find(";"))
		self:isEvalFalse(str:find(","))

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "Nested tables")
		local tbl = {
			{
				{
					{
						{
							{
								"Good morning",
								{
									"Hello"
								},
								"Good night",
							}
						}
					}
				}
			},
			"Goodbye",
		}
		local str = t2s2.serialize(tbl)
		self:print(3, str)
		local ok, t2 = assert(t2s2.deserialize(str))
		self:isEqual(t2[1][1][1][1][1][1], "Good morning")
		self:isEqual(t2[1][1][1][1][1][2][1], "Hello")
		self:isEqual(t2[1][1][1][1][1][3], "Good night")
		self:isEqual(t2[2], "Goodbye")
	end
	--]====]



	-- [====[
	do
		_resetT2S2()
		self:print(4, "Nested arrays")
		local tbl = {{"a"}, {"b"}, {"c"}}
		local str = t2s2.serialize(tbl)
		self:print(3, str)
		local ok, t2 = assert(t2s2.deserialize(str))
		self:isEqual(t2[1][1], "a")
		self:isEqual(t2[2][1], "b")
		self:isEqual(t2[3][1], "c")
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		t2s2.setFormatting(nil, nil, nil, nil, nil, 13)
		self:print(4, "Array columns (13)")
		local tbl = {
			1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
			22, 23, 24, 25, 26, 27, 28, 29, 30,
		}
		local str = t2s2.serialize(tbl)
		self:isEqual(str, "return {\
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,\
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,\
  27, 28, 29, 30\
}")
	end
	--]====]


	-- [====[
	if not rawget(_G, "jit") then
		self:print(4, "[SKIP] LuaJIT expanded names -- LuaJIT is required for this test.")
		self:lf(4)
	else
		_resetT2S2()
		self:print(4, "[+] LuaJIT expanded names")

		t2s2.setFormatting("", "", "")
		t2s2.setExpandedNames(true)
		local tbl = {["föo"]="bar"}
		local str = t2s2.serialize(tbl)

		self:isEqual(str, 'return{föo="bar"}')

		self:print(3, str)

		local ok, t2 = assert(t2s2.deserialize(str))

		-- We can't write {föo="bar"} here directly, because PUC-Lua's lexer will reject it.
		-- This line proves that LuaJIT read the deserialized table constructor correctly,
		-- though.
		self:isEvalTrue(t2["föo"], "bar")

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] priority keys, expected behavior")

		t2s2.setFormatting("", "", "")
		local fmt = {"hat", "belt", "tie", "coat"}
		local tbl = {coat=5, tie=7, hat=9, belt=2}
		local reg = {[tbl] = fmt}
		local str = t2s2.serialize(tbl, reg)

		self:isEqual(str, 'return{hat=9,belt=2,tie=7,coat=5}')

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] priority keys, partial coverage")

		t2s2.setFormatting("", "", "")
		local fmt = {"d", "c"}
		local tbl = {b=true, a=true, e=true, c=true, d=true} -- abcde
		local reg = {[tbl] = fmt}
		local str = t2s2.serialize(tbl, reg)

		self:isEqual(str, 'return{d=true,c=true,a=true,b=true,e=true}')

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] no trailing separator check: table with only priority keys")

		t2s2.setFormatting("", "", "")
		local fmt = {"z", "x", "y"}
		local tbl = {x=true, y=true, z=true}
		local reg = {[tbl] = fmt}
		local str = t2s2.serialize(tbl, reg)

		self:isEqual(str, 'return{z=true,x=true,y=true}')

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] no trailing separator check: table with no priority keys")

		t2s2.setFormatting("", "", "")
		local tbl = {x=true, y=true, z=true}
		local str = t2s2.serialize(tbl)

		self:isEqual(str, 'return{x=true,y=true,z=true}')

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] no trailing separator check: array")

		t2s2.setFormatting("", "", "")
		local tbl = {1, 2, 3}
		local str = t2s2.serialize(tbl)

		self:isEqual(str, 'return{1,2,3}')

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] arrays with priority keys revert to hash table formatting")

		local tbl = {1, 2, 3}
		local fmt = {"foo", "bar", "baz", "bop"}
		self:write(3, "The format table contains: ")
		for i, v in ipairs(fmt) do
			self:write(3, tostring(v) .. " ")
		end
		self:lf(3)

		local reg = {[tbl] = fmt}
		local str = t2s2.serialize(tbl, reg)

		self:isEqual(str, 'return {\n  [1] = 1,\n  [2] = 2,\n  [3] = 3\n}')

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] a priority list with no array entries is considered inactive/disabled, so the array does not revert to hash table formatting")

		local tbl = {1, 2, 3}
		local fmt = {}
		local reg = {[tbl] = fmt}
		local str = t2s2.serialize(tbl, reg)

		self:isEqual(str, 'return {\n  1, 2, 3\n}')

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[+] placement of a metatable in the priority list registry")

		t2s2.setFormatting("", "", "")
		local tbl = setmetatable({c=3, b=2, a=1}, {})
		local fmt = {"b", "a", "c"}
		local reg = {[getmetatable(tbl)] = fmt}
		local str = t2s2.serialize(tbl, reg)

		self:isEqual(str, 'return{b=2,a=1,c=3}')

		self:lf(4)
	end
	--]====]


	-- [====[
	do
		_resetT2S2()
		self:print(4, "[-] '_missing_pri_fatal' option")

		t2s2.setMissingPriorityFatal(false)
		local t = {foo="bar"}
		local f = {"zoinks"}
		local r = {[t]=f}
		self:expectLuaReturn("setMissingPriorityFatal() off: no trouble", t2s2.serialize, t, r)

		t2s2.setMissingPriorityFatal(true)
		self:expectLuaError("setMissingPriorityFatal() on: raise an error", t2s2.serialize, t, r)

		self:lf(4)
	end
	--]====]
end
)
--]===]

-- [===[
self:registerFunction("t2s2.deserialize()", t2s2.deserialize)
self:registerJob("deserialize()", function(self)

	_resetT2S2()

	-- [====[
	do
		_resetT2S2()
		local ok, val = self:expectLuaReturn("t2s2.deserialize() minimal table", t2s2.deserialize, "return {}")
		self:print(4, ok, val)
		self:isEvalTrue(ok)
		self:isType(val, "table")
		self:isNil(next(val))
	end
	--]====]


	-- [====[
	do
		self:print(4, "[-] rejects binary chunks")

		--[[
		Lua 5.2+ and LuaJIT support blocking binary chunks as an argument of load().
		Lua 5.1 does not have this feature, but its bytecode starts with "\033Lua",
		so unless the bytecode format has been altered, T2S2 will reject binary
		chunks when it searches for the substring 'return'.
		--]]
		local bin = string.dump(function() return {foo="bar"} end)
		local ok, val = t2s2.deserialize(bin)
		self:isEvalFalse(ok)
		self:print(3, val)
	end
	--]====]


	-- [====[
	do
		self:print(4, "[-] prohibits function calls")
		local ok, val = t2s2.deserialize("return {string.char(33)}")
		self:isEvalFalse(ok)
		self:print(3, val)
	end
	--]====]


	-- [====[
	do
		self:print(4, "[-] prohibits string methods")
		local ok, val = t2s2.deserialize("return {('a'):match('a')}")
		self:isEvalFalse(ok)
		self:print(3, val)
	end
	--]====]


	-- [====[
	do
		self:print(4, "[-] prohibits statements before returned table constructor")
		local ok, val = t2s2.deserialize("while true do end return {}")
		self:isEvalFalse(ok)
		self:print(3, val)
	end
	--]====]


	-- [====[
	do
		self:print(4, "[+] ignores whitespace and comments before returned table constructor")
		local ok, val = t2s2.deserialize("--\n--\n--[[foo]] \t --\n\n --[=[as\n\n\ndf]=]return {}")
		self:print(3, ok, val)
		self:isEvalTrue(ok)
		self:isType(val, "table")
		self:isNil(next(val))
	end
	--]====]
end
)
--]===]


-- [===[
self:registerJob("Pseudorandom table test", function(self)

	-- [====[
	do
		_resetT2S2()

		-- include NaN, infinity
		local inc_nan = true
		local inc_inf = true

		local root = {}
		local cursor = root
		-- Generate a mixed-up but deterministic table.
		local actions = {
			"i", "t", "s", "i", "i", "i", "s", "i", "t", "i", "i", "s", "t",
			"s", "bt", "bt", "i", "bt", "bf", "bf"
		}

		if inc_nan then
			for i = 1, 4 do
				table.insert(actions, "nan")
			end
		end
		if inc_inf then
			for i = 1, 4 do
				table.insert(actions, "inf")
			end
		end

		local i = 1
		local tumbler = 1
		local max = 256
		for i = 1, max do
			local action = actions[(tumbler - 1) % (#actions) + 1]
			tumbler = tumbler + i

			if action == "t" then
				cursor[i] = {}
				cursor = cursor[i]

			elseif action == "i" then
				cursor[i] = i

			elseif action == "s" then
				cursor[i] = tostring(i)

			elseif action == "inf" then
				cursor[i] = 1/0

			elseif action == "nan" then
				cursor[i] = 0/0

			elseif action == "bt" then
				cursor[i] = true

			elseif action == "bf" then
				cursor[i] = false
			end
		end

		self:print(3, inspect(root))

		local tbl_str = t2s2.serialize(root)
		local ok, t2 = assert(t2s2.deserialize(tbl_str))

		-- Compare table contents
		local function deepTableCompare(a, b, _depth)
			_depth = _depth or 1

			-- Check every field in A against B.
			for k in pairs(a) do
				if type(a[k]) ~= type(b[k]) then
					error("Type mismatch: " .. type(a[k]) .. ", " .. type(b[k]))

				elseif type(a[k]) == "table" then
					if deepTableCompare(a[k], b[k], _depth + 1) == false then
						error("Table mismatch: " .. tostring(a[k]) .. ", " .. tostring(b[k]))
					end

				-- Catch nan == nan
				elseif a[k] ~= a[k] and b[k] ~= b[k] then
					-- (Do nothing)

				elseif a[k] ~= b[k] then
					error("Value mismatch: " .. tostring(a[k]) .. ", " .. tostring(b[k]))
				end
			end
			-- Check B for fields that don't exist in A.
			for k in pairs(b) do
				if a[k] == nil then
					error("Value in B (" .. tostring(k) .. ":" .. tostring(a[k]) .. ") not in A.")
				end
			end
			return true
		end

		self:isEvalTrue(deepTableCompare(root, t2))
	end
	--]====]
end
)
--]===]


self:runJobs()

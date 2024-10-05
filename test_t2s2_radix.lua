-- Test: Radix fix for t2s2.lua


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
self:registerJob("Test radix mark fix", function(self)

	--[[
	I can't get 'os.setlocale()' to work in Windows 10, and switching my administrative language
	to French doesn't alter the command line's locale (C).

	I give up for tonight.
	--]]

	-- [====[
	do
		_resetT2S2()
		t2s2.setFormatting("", "", "")

		local old_locale

		-- Check if the current locale already uses ',' for the decimal separator
		local radix_test = ("%.1f"):format(0.5)

		if radix_test ~= "0,5" then
			old_locale = os.setlocale()
			local ok = os.setlocale('fr_FR')
			if not ok then
				error("failed to change locale to 'fr_FR', which uses ',' for decimal separators. The test cannot continue.")
			end
		end

		local tbl = {0.5}
		self:print(4, "[+] expected: 0.5 (not 0,5)\n")
		local str = t2s2.serialize(tbl)
		self:isEqual(str, "return{0.5}")

		if old_locale then
			assert(os.setlocale(old_locale))
		end
	end
	--]====]
end
)
--]===]


self:runJobs()

-- Safe loader for t2s2.
-- See README.md and LICENSE for more info.
-- Uses code from Serpent by Paul Kulchenko: https://github.com/pkulchenko/serpent
-- Version: 1.0.3


--[[
MIT License

Copyright (c) 2022 - 2024 RBTS
Serpent code: Copyright (c) 2012-2018 Paul Kulchenko (paul@kulchenko.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]


local M = {}


local PATH = ... and (...):match("(.-)[^%.]+$") or ""


local _argType = require(PATH .. "pile_arg_check").type


local _load = rawget(_G, "loadstring") and loadstring or load


M.lang = {
	err_call_fn = "cannot call functions",
	err_call_str = "cannot call string methods",
	not_lone_t = "expected lone table"
}
local lang = M.lang


local _i
local function _whitespace(s) _i = s:match("^%s+()", _i) or _i end
local function _comment2(s) local _i2, _ = _i; _, _i = s:match("^%-%-%[(=*)%[.-%]%1]()", _i); _i = _i or _i2 end
local function _comment1(s) _i = s:match("^%-%-[^\n]*()", _i) or _i end
local function _skipWS(s)
	while true do
		local _i2 = _i
		_whitespace(s)
		_comment2(s)
		_comment1(s)
		if _i == _i2 then
			break
		end
	end
end


local function _isLoneTable(s)
	_i = 1
	_skipWS(s)
	if s:find("^return", _i) then
		_i = _i + #"return"
		_skipWS(s)
	end
	if s:find("^{", _i) then
		return true
	end
end


local function _str__call()
	error(lang.err_call_str)
end


-- Based on 'deserialize()' from Serpent: https://github.com/pkulchenko/serpent
local _deserialize
do
	local _mt_env = {
		__index = function(t,k) return t end,
		__call = function(t,...) error(lang.err_call_fn) end
	}
	_deserialize = function(data)
		local env = setmetatable({}, _mt_env)
		local f, res = _load(data, nil, "t", env)
		if not f then return f, res end
		if rawget(_G, "setfenv") then setfenv(f, env) end
		return pcall(f)
	end
end


function M.deserialize(s)
	_argType(1, s, "string")

	if not _isLoneTable(s) then
		return nil, lang.not_lone_t
	end

	local str_mt__index
	local str_mt = getmetatable("")
	if str_mt then
		str_mt__index, str_mt.__index = str_mt.__index, {}
		for k, v in pairs(str_mt__index) do
			str_mt.__index[k] = (type(v) == "function") and _str__call or v
		end
	end

	local ok, res = _deserialize(s)

	if str_mt then
		str_mt.__index = str_mt__index
	end

	return ok, res
end


return M

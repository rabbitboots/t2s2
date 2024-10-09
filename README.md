**Version:** 1.0.2

# T2S2

T2S2 is a Lua table serializer for Lua 5.1 - 5.4.

Uses code from [Serpent](https://github.com/pkulchenko/serpent).


# Behavior

* Serializable keys: `boolean`, `number` and `string`

* Serializable values: `boolean`, `number`, `string` and `table`

* Arbitrary top placement of *priority keys* in a table; all other keys are sorted in a predictable order

* Configurable limits for the serializer: maximum nested tables. total bytes written

* Configurable spaces, indendation, newlines, item separator character (`,` or `;`), and items per line for arrays

* Rejects cyclic table references (tables appearing inside of themselves)

* Attached metatables are not saved, and serialization may be affected by metamethods

* Can load Lua table constructors while forbidding function calls, string methods, bytecode chunks, and any statements prior to `return {…`


# Example

```lua
local str = t2s2.serialize({3, 6, 9, {foo="bar", baz="bop"}})
print(str)
--[[
return {
  3, 6, 9, {
    baz = "bop",
    foo = "bar"
  }
}
--]]
```

# Package Information

`t2s2.lua` is the main file.

Files beginning with `pile` contain Lua boilerplate code, and are required.

Files and folders beginning with `test` or `example` can be deleted.


# T2S2 API


## t2s2.getFormatting

Gets the module-wide formatting of serialized tables.

`local space, newline, indent, indent_delta, separator, columns = t2s2.getFormatting()`

**Returns:** The space string, newline string, indent string, a modifier (number) for the initial indent level, the separator string, and the number of items to write per line for arrays.


## t2s2.setFormatting

Configures the module-wide formatting of serialized tables. Arguments that are `false`, `nil`, or unspecified will be reset to their default values.

`t2s2.setFormatting([space], [newline], [indent], [indent_delta], [separator], [columns])`

* `[space]`: The string for spaces. *Default:* `" "`

* `[newline]`: The string for newlines. *Default:* `"\n"`

* `[indent]`: The string for indents. *Default:* `"\t"`

* `[indent_delta]`: A modifier (number) for the initial indent level. (With a value of `-1`, indentation would only start on the second level of fields.) *Default:* `0`

* `[separator]`: The separator to use for table fields. Can be `,` or `;`. *Default:* `,`

* `[columns]`: The number of items to write per line for arrays (tables with only integer indices from 1..n, with no gaps and no other hash keys). *Default:* `0` (no limit)

**Notes:**

* The strings for space, newline and indent must contain only whitespace characters or be empty.


## t2s2.getExpandedNames

Gets the state for writing LuaJIT non-ASCII keys without brackets, like `bär` instead of `["bär"]`.

`local enabled = t2s2.getExpandedNames()`

**Returns:** `true` if expanded names are enabled, `false` if not.


## t2s2.setExpandedNames

Sets the state for writing LuaJIT non-ASCII keys without brackets, like `bär` instead of `["bär"]`.

`t2s2:setExpandedNames(enabled)`

* `enabled`: `true` to enable non-ASCII names, `false` to disable.

**Notes:**

* PUC-Lua cannot read the expanded names.


## t2s2.getMissingPriorityFatal

Gets the state for raising an error if a priority key is missing from a table to be serialized.

* `local enabled = t2s2.getMissingPriorityFatal()`

**Returns:** `true` if configured to raise an error when priority keys are missing from serialized tables, `false` otherwise.


## t2s2.setMissingPriorityFatal

Sets the state for raising an error if a priority key is missing from a table to be serialized.

`t2s2.setMissingPriorityFatal(enabled)`

* `enabled`: `true` to make the serializer raise an error if a priority key is missing, `false/nil` to ignore these cases.


## t2s2.getMaxDepth

Gets the current maximum depth for serialized nested tables.

`local n = t2s2.getMaxDepth()`

**Returns:** The maximum depth for serialized nested tables, or `nil` if no maximum is set.


## t2s2.setMaxDepth

Sets the maximum depth for serialized nested tables. T2S2 raises a Lua error if the limit is exceeded.

`t2s2.setMaxDepth(n)`

* `n`: The maximum table depth, or `nil` to unset the maximum.


## t2s2.getMaxBytes

Gets the maximum bytes allowed for serialized tables.

`local n = t2s2.getMaxBytes()`

**Returns:** The maximum bytes per serialized table, or `nil` if no maximum is set.


## t2s2.setMaxBytes

Sets the maximum bytes allowed for serialized tables. T2S2 raises a Lua error when the limit is exceeded.

`t2s2.setMaxBytes(n)`

* `n`: The maximum bytes to serialize, or `nil` to unset the maximum.


## t2s2.serialize

Converts a Lua table to a string.

`local str = t2s2.serialize(t, [pri_reg])`

* `t`: The table to serialize.

* `[pri_reg]`: Registry of priority lists: a hashtable that associates tables in `t` with priority lists.

**Returns:** The serialized string.


## t2s2.deserialize

Loads a Lua string table constructor while temporarily disabling function calls, string methods, bytecode chunks, and any statements appearing before `return {…`.

`local tbl = t2s2.deserialize(s)`

* `s`: The string to load.

**Returns:** `true` and a table on success, or `nil` and an error string on failure.


# Notes

## Chunks that are too big

T2S2 can serialize tables that are too big for Lua to read back:

  * Too many nested tables will lead to an error message along the lines of `chunk has too many syntax levels` or `C stack overflow`.

  * Lua 5.1 has a limit of about 262143 table constants in a function. (Error: `constant table overflow`.) This limit is greatly relaxed in Lua 5.2+ and LuaJIT; they can both read arrays with at least five million entries.


## Formatting

Numbers are serialized with `string.format("%.17g", n)`, so they could lose some precision if they are extremely large or have fractional parts.

Arrays and hash tables are formatted differently. When an array is associated with a priority list that has at least one entry, T2S2 will always treat it like a hash table, even if none of the priority keys are present in the array. If the associated priority list is empty, then it is disregarded.


### Character Escapes

The serializer escapes characters 0-31 and 127 in strings. The `\ddd` notation is used, except in the cases of `\a`, `\b`, `\f`, `\t`, `\n`, `\r` and `\v`. Additionally, double quotes and backslashes are escaped as `\"` and `\\`.


## Priority Lists

Priority lists allow you to serialize out specific keys in a table first, and in a specific order. A *registry* table associates your tables with priority lists. The keys are your tables or metatables, with the former taking priority; the values are priority lists.

```lua
-- Makes "foo" and "bar" get top billing in a serialized hash table:
local pri_list = {"foo", "bar"}

-- Registry example:
local pri_reg = {
	-- Direct association
	[my_table] = pri_list,

	-- Via metatable
	[_my_metatable] = pri_list
}
```


## Sorting

The sorting order is as follows:

* Priority keys, if specified
* Booleans (`false` before `true`)
* Numbers, in ascending order
* Strings, in ascending order (per-byte; 'ë' goes after 'z')

Tables are not supported as keys because there is no way to consistently sort them.


# License (MIT)

```
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
```

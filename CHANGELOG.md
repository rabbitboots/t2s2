# T2S2 Changelog

(Date format: `YYYY-MM-DD`)

# 1.0.1 (2024-10-08)

* Changed how `t2s2.serialize()` escapes characters in strings. All non-display ASCII characters are escaped, and the `%q` format specifier has been replaced by a call to `string.gsub()` with the intention of making the escape behavior consistent across Lua versions (PUC-Lua 5.1 doesn't escape certain chars that 5.2+ and JIT do).

* Added to README notes and rearranged some sections.


# 1.0.0 (2024-10-04)

This is a major rewrite of [TableToString](https://github.com/rabbitboots/table_to_string), with a new API, different sorting rules, a less invasive way of specifying priority keys, and a safe-load function adapted from [Serpent](https://github.com/pkulchenko/serpent).

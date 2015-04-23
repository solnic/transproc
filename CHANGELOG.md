## v0.2.1 to-be-released

### Changed

* `Transproc.register` raises a meaningful error when a given function is already registered (kwando)
* `Transproc[]` raises a meaningful error when a given function doesn't exist (kwando)
* `Transproc[]` raises a meaningful error when a transformation crashes (kwando)

### Fixed

* `Transproc()` no longer creates a function if it's already a function (splattael)
* A couple of mistakes in the API docs (AMHOL)

### Internal

* Rubocop integration \o/ (AMHOL)

[Compare v0.2.0...master](https://github.com/solnic/transproc/compare/v0.2.0...master)

## v0.2.0 2015-04-14

### Added

* `:map_keys` hash transformation (AMHOL)
* `:stringify_keys` hash transformation (AMHOL)
* `:map_values` hash transformation (AMHOL)
* `:guard` function (AMHOL)
* `:is` type-check function (solnic)
* `Function#to_ast` for easy inspection (solnic)
* Ability to define module with custom functions that will be auto-registered (solnic + splattael)

### Changed

* [BREAKING] `map_hash` renamed to `rename_keys`
* [BREAKING] `map_key` renamed to `map_value`
* [BREAKING] `map_array` no longer accepts multiple functions (AMHOL)
* All functions are now defined as module functions (solnic + splattael)
* Functions no longer create anonymous procs (solnic)

[Compare v0.1.3...v0.2.0](https://github.com/solnic/transproc/compare/v0.1.3...v0.2.0)

## v0.1.3 2015-04-07

### Added

* Added `hash_recursion` and `array_recursion` functions (AMHOL)
* Added `unwrap` and `unwrap!` functions (aflatter)

### Changed

* Speedup transproc `group` (splattael)

[Compare v0.1.2...v0.1.3](https://github.com/solnic/transproc/compare/v0.1.2...v0.1.3)

## v0.1.2 2015-03-14

### Changed

* `:nest` creates an empty hash even when keys are not present

[Compare v0.1.1...v0.1.2](https://github.com/solnic/transproc/compare/v0.1.1...v0.1.2)

## v0.1.1 2015-03-13

### Changed

* `Transproc(:map_array)` performance improvements (splattael + solnic)
* hash transformation performance improvements (solnic)

### Fixed

* `Transproc(:nest)` handles falsy values correctly now (solnic)
* Missing `require "time"` added (splattael)

[Compare v0.1.0...v0.1.1](https://github.com/solnic/transproc/compare/v0.1.0...v0.1.1)

## v0.1.0 2014-12-28

### Added

* added bang-method equivalents to all functions (solnic)
* group and wrap array transformations (solnic)
* date, datetime and time coercions (solnic)
* numeric coercions (solnic)
* boolean coercions (solnic)
* [hash] `:nest` which wraps a set of keys under a new key (solnic)

[Compare v0.0.1...v0.1.0](https://github.com/solnic/transproc/compare/v0.0.1...v0.1.0)

## v0.0.1 2014-12-24

First public release \o/

## v0.4.2 2017-01-12

## Added

* prefix option to HashTransformations#unwrap and HashTransformations#unwrap! (AMHOL)

## Fixed

* `map_array` won't cause a SystemStackError in case of gigantic arrays (solnic)

[Compare v0.4.1...v0.4.2](https://github.com/solnic/transproc/compare/v0.4.1...v0.4.2)

## v0.4.1 2016-11-08

## Added

* Class level transproc DSL (AMHOL)

## Fixed

* Works on latest rubinius again (katafrakt)

[Compare v0.4.0...v0.4.1](https://github.com/solnic/transproc/compare/v0.4.0...v0.4.1)

## v0.4.0 2015-11-23

## Fixed

* `rename_keys` no longer creates new keys (robmiller)

## Deleted

* `MalformedInputError` exception. Transproc doesn't catch and re-raise exceptions any longer (nepalez)

[Compare v0.3.2...v0.4.0](https://github.com/solnic/transproc/compare/v0.3.2...v0.4.0)

## v0.3.2 2015-08-17

## Changed

* Functions now use `.call` rather than `.[]` as it's more common (solnic)

## Fixed

* `Function#to_proc` properly carries additional args required by the proc (solnic)

[Compare v0.3.1...v0.3.2](https://github.com/solnic/transproc/compare/v0.3.1...v0.3.2)

## v0.3.1 2015-08-06

### Added

* `:deep_merge` in `HashTransformations` (saturnflyer)
* `Transproc::Function#to_proc` method (nepalez)
* `to_boolean` coercion turns `nil` into `false` (c0)
* Support symbolizing non-string values by `Coercions[:to_symbol]` and `HashTransformations[:symbolize_keys]` (nepalez)
* Support for importing several functions at once `import :foo, :bar, from: Foo` (nepalez)

[Compare v0.3.0...v0.3.1](https://github.com/solnic/transproc/compare/v0.3.0...v0.3.1)

## v0.3.0 2015-07-12

This release deprecates a couple of APIs and changes the way functions can be
accessed. The global `Transproc()` function registry is now deprecated and you
should define your own function registry via `extend Transproc::Registry` and its
`import` interface. See API docs for the details.

Proper deprecation warnings will appear as this is still a backward-compatible
release, however, please update to the new API as the global registry will be gone
in 1.0.0.

### Added

* `HashTransformations.eval_values` which evaluates callable values in a hash
  recursively (solnic)
* `HashTransformations.deep_symbolize_keys` which, surprise surprise, symbolizes
  keys in a hash, recursively (solnic)
* Shared examples `:transforming_immutable_data` and `:mutating_input_data`
  to specify transformations in RSpec (nepalez)

### Changed

* `Transproc::Registry` now uses singleton methods that can be imported from
  arbitrary modules via `import` interface (nepalez)
* Updated all built-in modules to the new registry API (nepalez + solnic)
* `Transproc()` has been deprecated (solnic)
* `Transproc::Helper` has been deprecated (solnic)

[Compare v0.2.4...v0.3.0](https://github.com/solnic/transproc/compare/v0.2.4...v0.3.0)

## v0.2.4 2015-06-20

### Added

* `Transproc::Registry` extension for registering reusable functions within modules (nepalez)
* `:recursion` recurse over an enumerable (AMHOL)

###  Changed

* `:group`, `:nest`, and `:wrap` support adding new data to existing groups/wraps (nepalez)
* `Transproc::MalformedInputError` includes original backtrace now (solnic)

[Compare v0.2.3...v0.2.4](https://github.com/solnic/transproc/compare/v0.2.3...v0.2.4)

## v0.2.3 2015-06-02

### Added

* `:split` splits a hash to array by a list of values from a specified key of the hash (nepalez)
* `:ungroup` is an inverse array transormation with respect to the `:group` (nepalez)
* `:insert_key` (and `:insert_key!`) is the partial inversion of `:extract_key`.
  The method converts array of values into array of tuples with given key (nepalez)
* `:add_keys` (and `:add_keys!`) adds missing keys to all tuples in array (nepalez)

### Fixed

* Warning about circular requires is gone now (splattael)

[Compare v0.2.2...v0.2.3](https://github.com/solnic/transproc/compare/v0.2.2...v0.2.3)

## v0.2.2 2015-05-22

### Added

* `:fold` folds array of tuples into array of values from a specified key of the hash (nepalez)

### Internal

* Fixed some Rubocop warnings (nepalez)
* Changed Rubocop `RegexpLiteral` from `MaxSlashes: 0` (not supported) to
  `EnforcedStyle: percent_r` (nepalez)

[Compare v0.2.1...v0.2.2](https://github.com/solnic/transproc/compare/v0.2.1...v0.2.2)

## v0.2.1 2015-05-17

### Added

* `:constructor_inject` injects arguments into the constructor of a class (AMHOL)
* `:set_ivars` which allocates an object and sets instance variables from a hash (key/value pairs) on an object (AMHOL)
* `:combine` which merges multiple arrays into one using "join keys" (solnic)
* `:reject_keys` which rejects specified keys in a hash (solnic)
* `:accept_keys` which accepts specified keys in a hash (solnic)
* `:extract_key` converts the array of hashes to array of values (nepalez)

### Changed

* `:unwrap` can be called without keys (solnic)
* `Transproc.register` raises a meaningful error when a given function is already registered (kwando)
* `Transproc[]` raises a meaningful error when a given function doesn't exist (kwando)
* `Transproc[]` raises a meaningful error when a transformation crashes (kwando)

### Fixed

* `Transproc()` no longer creates a function if it's already a function (splattael)
* A couple of mistakes in the API docs (AMHOL)

### Internal

* Rubocop integration \o/ (AMHOL)

[Compare v0.2.0...v0.2.1](https://github.com/solnic/transproc/compare/v0.2.0...v0.2.1)

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

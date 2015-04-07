## v0.1.3 to-be-released

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

# Digestive

[![Test Status][icon]][status]

[icon]: https://github.com/pyrmont/digestive/workflows/test/badge.svg
[status]: https://github.com/pyrmont/digestive/actions?query=workflow%3Atest

Digestive is a pure Janet library for generating
cryptographic digests.

## Installation

Add the dependency to your `info.jdn` file:

```janet
  :dependencies ["https://github.com/pyrmont/digestive"]
```

## Usage

Digestive can be used like this:

```janet
(import digestive)

(digestive/md5/digest "The quick brown fox jumps over the lazy dog")
# => "9e107d9d372bb6826bd81d3542a419d6"
```

## API

Documentation for Digestive's API is in [api.md][api].

[api]: https://github.com/pyrmont/digestive/blob/master/api.md

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/digestive/issues

## Licence

Digestive is licensed under the MIT Licence. See [LICENSE][] for more details.

[LICENSE]: https://github.com/pyrmont/digestive/blob/master/LICENSE

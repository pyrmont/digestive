# Digestive

[![Test Status][icon]][status]

[icon]: https://github.com/pyrmont/digestive/workflows/test/badge.svg
[status]: https://github.com/pyrmont/digestive/actions?query=workflow%3Atest

Digestive is a pure Janet library for generating cryptographic digests. It does
not require 64-bit integers.

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

(digestive/sha1/digest "The quick brown fox jumps over the lazy dog")
# => "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"

(digestive/sha2-256/digest "The quick brown fox jumps over the lazy dog")
# => "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"

(digestive/sha2-384/digest "The quick brown fox jumps over the lazy dog")
# => "ca737f1014a48f4c0b6dd43cb177b0afd9e5169367544c494011e3317dbf9a509cb1e5dc1e85a941bbee3d7f2afbc9b1"

(digestive/sha2-512/digest "The quick brown fox jumps over the lazy dog")
# => "07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6"

(digestive/sha3-256/digest "The quick brown fox jumps over the lazy dog")
# => "69070dda01975c8c120c3aada1b282394e7f032fa9cf32f4cb2259a0897dfc04"
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

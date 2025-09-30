# digestive API


[blake3-256digest](#blake3-256digest), [md5/digest](#md5digest), [sha1/digest](#sha1digest), [sha2/digest](#sha2digest), [sha3-256/digest](#sha3-256digest), [sha3-512/digest](#sha3-512digest)

## blake3-256digest

**function**  | [source][1]

```janet
(digest input &opt output-len)
```

Calculates a digest of `input` using the BLAKE3-256 algorithm

[1]: lib/blake3-256.janet#L303

## md5/digest

**function**  | [source][2]

```janet
(digest input)
```

Calculates a digest of `input` using the MD5 algorithm

[2]: lib/md5.janet#L46

## sha1/digest

**function**  | [source][3]

```janet
(digest input)
```

Calculates a digest of `input` using the SHA1 algorithm

[3]: lib/sha1.janet#L28

## sha2/digest

**function**  | [source][4]

```janet
(digest kind input)
```

Calculates a digest of `input` using the SHA2 algorithm

The value of `:kind` can be one of `:256`, `:384` and `:512`.

[4]: lib/sha2.janet#L335

## sha3-256/digest

**function**  | [source][5]

```janet
(digest input)
```

Calculates a digest of `input` using the SHA3-256 algorithm

[5]: lib/sha3-256.janet#L146

## sha3-512/digest

**function**  | [source][6]

```janet
(digest input)
```

Calculates a digest of `input` using the SHA3-512 algorithm

[6]: lib/sha3-512.janet#L146


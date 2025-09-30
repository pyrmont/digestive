(import ./bitops :as ops)

###
### SHA-256 (32-bit variant)
###

# SHA-256 constants (first 32 bits of the fractional parts of the cube roots
# of the first 64 primes 2..311)
(def- K256 [0x428a2f98 0x71374491 0xb5c0fbcf 0xe9b5dba5
            0x3956c25b 0x59f111f1 0x923f82a4 0xab1c5ed5
            0xd807aa98 0x12835b01 0x243185be 0x550c7dc3
            0x72be5d74 0x80deb1fe 0x9bdc06a7 0xc19bf174
            0xe49b69c1 0xefbe4786 0x0fc19dc6 0x240ca1cc
            0x2de92c6f 0x4a7484aa 0x5cb0a9dc 0x76f988da
            0x983e5152 0xa831c66d 0xb00327c8 0xbf597fc7
            0xc6e00bf3 0xd5a79147 0x06ca6351 0x14292967
            0x27b70a85 0x2e1b2138 0x4d2c6dfc 0x53380d13
            0x650a7354 0x766a0abb 0x81c2c92e 0x92722c85
            0xa2bfe8a1 0xa81a664b 0xc24b8b70 0xc76c51a3
            0xd192e819 0xd6990624 0xf40e3585 0x106aa070
            0x19a4c116 0x1e376c08 0x2748774c 0x34b0bcb5
            0x391c0cb3 0x4ed8aa4a 0x5b9cca4f 0x682e6ff3
            0x748f82ee 0x78a5636f 0x84c87814 0x8cc70208
            0x90befffa 0xa4506ceb 0xbef9a3f7 0xc67178f2])

# 32-bit helper: add multiple values together and get first word
(defn- add32 [& xs]
  (def total (ops/badd ;xs))
  (if (<= (length total) 4)
    total
    (buffer/slice total 0 4)))

# 32-bit helper: get a word from buffer and flip endianness
(defn- word-flip32 [b begin]
  (def res @"")
  (def end (+ 4 begin))
  (for i 0 4
    (buffer/push res (get b (- end i 1))))
  res)

# SHA-256 auxiliary functions

(defn- choose32 [x y z]
  (ops/bxor (ops/band x y) (ops/band (ops/bnot x) z)))

(defn- major32 [x y z]
  (ops/bxor (ops/bxor (ops/band x y) (ops/band x z)) (ops/band y z)))

(defn- big0-32 [x]
  (ops/bxor (ops/bxor (ops/blrot x 30) (ops/blrot x 19)) (ops/blrot x 10)))

(defn- big1-32 [x]
  (ops/bxor (ops/bxor (ops/blrot x 26) (ops/blrot x 21)) (ops/blrot x 7)))

(defn- small0-32 [x]
  (ops/bxor (ops/bxor (ops/blrot x 25) (ops/blrot x 14)) (ops/brushift x 3)))

(defn- small1-32 [x]
  (ops/bxor (ops/bxor (ops/blrot x 15) (ops/blrot x 13)) (ops/brushift x 10)))

(defn- sha256
  [input]
  # Initialize hash values (first 32 bits of fractional parts of square roots
  # of first 8 primes 2..19)
  (var h0 (buffer/push-word @"" 0x6a09e667))
  (var h1 (buffer/push-word @"" 0xbb67ae85))
  (var h2 (buffer/push-word @"" 0x3c6ef372))
  (var h3 (buffer/push-word @"" 0xa54ff53a))
  (var h4 (buffer/push-word @"" 0x510e527f))
  (var h5 (buffer/push-word @"" 0x9b05688c))
  (var h6 (buffer/push-word @"" 0x1f83d9ab))
  (var h7 (buffer/push-word @"" 0x5be0cd19))
  # Calculate padding length
  (def padlen (mod (- 55 (mod (length input) 64)) 64))
  # Convert input to buffer
  (def msg (buffer/new (+ (length input) 1 padlen 8)))
  (buffer/push-string msg input)
  # Add padding to message
  (buffer/push msg 0x80)
  (for i 0 padlen
    (buffer/push msg 0x00))
  # Input length as bits
  (def bitlen (ops/blen input))
  # Extract high 32 bits (word 1) and low 32 bits (word 0) from bitlen
  (def hi32 (ops/bword bitlen 1))
  (def lo32 (ops/bword bitlen 0))
  (buffer/push-string msg (word-flip32 hi32 0))
  (buffer/push-string msg (word-flip32 lo32 0))
  (var begin 0)
  (while (< begin (length msg))
    # Initialize working variables
    (var a h0)
    (var b h1)
    (var c h2)
    (var d h3)
    (var e h4)
    (var f h5)
    (var g h6)
    (var h h7)
    # Prepare message schedule array W[0..63]
    (def W (array/new 64))
    # Copy chunk into first 16 words W[0..15] of the message schedule array
    (for i 0 16
      (put W i (word-flip32 msg (+ begin (* 4 i)))))
    # Extend the first 16 words into the remaining 48 words W[16..63]
    (for i 16 64
      (def s1 (small1-32 (W (- i 2))))
      (def s0 (small0-32 (W (- i 15))))
      (put W i (add32 s1 (W (- i 7)) s0 (W (- i 16)))))
    # Main loop - compression function
    (for i 0 64
      (def S1 (big1-32 e))
      (def ch (choose32 e f g))
      (def temp1 (add32 h S1 ch (buffer/push-word @"" (K256 i)) (W i)))
      (def S0 (big0-32 a))
      (def maj (major32 a b c))
      (def temp2 (add32 S0 maj))
      # Update working variables
      (set h g)
      (set g f)
      (set f e)
      (set e (add32 d temp1))
      (set d c)
      (set c b)
      (set b a)
      (set a (add32 temp1 temp2)))
    # Add this chunk's hash to result
    (set h0 (add32 h0 a))
    (set h1 (add32 h1 b))
    (set h2 (add32 h2 c))
    (set h3 (add32 h3 d))
    (set h4 (add32 h4 e))
    (set h5 (add32 h5 f))
    (set h6 (add32 h6 g))
    (set h7 (add32 h7 h))
    (set begin (+ begin 64)))
  # Produce the final hash value
  (-> (buffer h0 h1 h2 h3 h4 h5 h6 h7)
      (ops/bstring :be? true)))

###
### SHA-384 and SHA-512 (64-bit variants)
###

# SHA-384/512 constants (first 64 bits of the fractional parts of the cube roots
# of the first 80 primes)
(def- K512 [(ops/bjoin 0x428a2f98 0xd728ae22) (ops/bjoin 0x71374491 0x23ef65cd)
            (ops/bjoin 0xb5c0fbcf 0xec4d3b2f) (ops/bjoin 0xe9b5dba5 0x8189dbbc)
            (ops/bjoin 0x3956c25b 0xf348b538) (ops/bjoin 0x59f111f1 0xb605d019)
            (ops/bjoin 0x923f82a4 0xaf194f9b) (ops/bjoin 0xab1c5ed5 0xda6d8118)
            (ops/bjoin 0xd807aa98 0xa3030242) (ops/bjoin 0x12835b01 0x45706fbe)
            (ops/bjoin 0x243185be 0x4ee4b28c) (ops/bjoin 0x550c7dc3 0xd5ffb4e2)
            (ops/bjoin 0x72be5d74 0xf27b896f) (ops/bjoin 0x80deb1fe 0x3b1696b1)
            (ops/bjoin 0x9bdc06a7 0x25c71235) (ops/bjoin 0xc19bf174 0xcf692694)
            (ops/bjoin 0xe49b69c1 0x9ef14ad2) (ops/bjoin 0xefbe4786 0x384f25e3)
            (ops/bjoin 0x0fc19dc6 0x8b8cd5b5) (ops/bjoin 0x240ca1cc 0x77ac9c65)
            (ops/bjoin 0x2de92c6f 0x592b0275) (ops/bjoin 0x4a7484aa 0x6ea6e483)
            (ops/bjoin 0x5cb0a9dc 0xbd41fbd4) (ops/bjoin 0x76f988da 0x831153b5)
            (ops/bjoin 0x983e5152 0xee66dfab) (ops/bjoin 0xa831c66d 0x2db43210)
            (ops/bjoin 0xb00327c8 0x98fb213f) (ops/bjoin 0xbf597fc7 0xbeef0ee4)
            (ops/bjoin 0xc6e00bf3 0x3da88fc2) (ops/bjoin 0xd5a79147 0x930aa725)
            (ops/bjoin 0x06ca6351 0xe003826f) (ops/bjoin 0x14292967 0x0a0e6e70)
            (ops/bjoin 0x27b70a85 0x46d22ffc) (ops/bjoin 0x2e1b2138 0x5c26c926)
            (ops/bjoin 0x4d2c6dfc 0x5ac42aed) (ops/bjoin 0x53380d13 0x9d95b3df)
            (ops/bjoin 0x650a7354 0x8baf63de) (ops/bjoin 0x766a0abb 0x3c77b2a8)
            (ops/bjoin 0x81c2c92e 0x47edaee6) (ops/bjoin 0x92722c85 0x1482353b)
            (ops/bjoin 0xa2bfe8a1 0x4cf10364) (ops/bjoin 0xa81a664b 0xbc423001)
            (ops/bjoin 0xc24b8b70 0xd0f89791) (ops/bjoin 0xc76c51a3 0x0654be30)
            (ops/bjoin 0xd192e819 0xd6ef5218) (ops/bjoin 0xd6990624 0x5565a910)
            (ops/bjoin 0xf40e3585 0x5771202a) (ops/bjoin 0x106aa070 0x32bbd1b8)
            (ops/bjoin 0x19a4c116 0xb8d2d0c8) (ops/bjoin 0x1e376c08 0x5141ab53)
            (ops/bjoin 0x2748774c 0xdf8eeb99) (ops/bjoin 0x34b0bcb5 0xe19b48a8)
            (ops/bjoin 0x391c0cb3 0xc5c95a63) (ops/bjoin 0x4ed8aa4a 0xe3418acb)
            (ops/bjoin 0x5b9cca4f 0x7763e373) (ops/bjoin 0x682e6ff3 0xd6b2b8a3)
            (ops/bjoin 0x748f82ee 0x5defb2fc) (ops/bjoin 0x78a5636f 0x43172f60)
            (ops/bjoin 0x84c87814 0xa1f0ab72) (ops/bjoin 0x8cc70208 0x1a6439ec)
            (ops/bjoin 0x90befffa 0x23631e28) (ops/bjoin 0xa4506ceb 0xde82bde9)
            (ops/bjoin 0xbef9a3f7 0xb2c67915) (ops/bjoin 0xc67178f2 0xe372532b)
            (ops/bjoin 0xca273ece 0xea26619c) (ops/bjoin 0xd186b8c7 0x21c0c207)
            (ops/bjoin 0xeada7dd6 0xcde0eb1e) (ops/bjoin 0xf57d4f7f 0xee6ed178)
            (ops/bjoin 0x06f067aa 0x72176fba) (ops/bjoin 0x0a637dc5 0xa2c898a6)
            (ops/bjoin 0x113f9804 0xbef90dae) (ops/bjoin 0x1b710b35 0x131c471b)
            (ops/bjoin 0x28db77f5 0x23047d84) (ops/bjoin 0x32caab7b 0x40c72493)
            (ops/bjoin 0x3c9ebe0a 0x15c9bebc) (ops/bjoin 0x431d67c4 0x9c100d4c)
            (ops/bjoin 0x4cc5d4be 0xcb3e42b6) (ops/bjoin 0x597f299c 0xfc657e2a)
            (ops/bjoin 0x5fcb6fab 0x3ad6faec) (ops/bjoin 0x6c44198c 0x4a475817)])

# 64-bit helper: add multiple values together and get first 8 bytes
(defn- add64 [& xs]
  (def total (ops/badd ;xs))
  (if (<= (length total) 8)
    total
    (buffer/slice total 0 8)))

# 64-bit helper: get a word from buffer and flip endianness
(defn- word-flip64 [b begin]
  (def res @"")
  (for i 0 8
    (buffer/push res (get b (+ begin (- 7 i)))))
  res)

# SHA-384/512 auxiliary functions
(defn- choose64 [x y z]
  (ops/bxor (ops/band x y) (ops/band (ops/bnot x) z)))

(defn- major64 [x y z]
  (ops/bxor (ops/bxor (ops/band x y) (ops/band x z)) (ops/band y z)))

(defn- big0-64 [x]
  (ops/bxor (ops/bxor (ops/blrot x 36) (ops/blrot x 30)) (ops/blrot x 25)))

(defn- big1-64 [x]
  (ops/bxor (ops/bxor (ops/blrot x 50) (ops/blrot x 46)) (ops/blrot x 23)))

(defn- small0-64 [x]
  (ops/bxor (ops/bxor (ops/blrot x 63) (ops/blrot x 56)) (ops/brushift x 7)))

(defn- small1-64 [x]
  (ops/bxor (ops/bxor (ops/blrot x 45) (ops/blrot x 3)) (ops/brushift x 6)))

# Core digest function for 64-bit SHA-2 variants
(defn- digest64
  [input init-h num-output-words]
  (var h0 (init-h 0))
  (var h1 (init-h 1))
  (var h2 (init-h 2))
  (var h3 (init-h 3))
  (var h4 (init-h 4))
  (var h5 (init-h 5))
  (var h6 (init-h 6))
  (var h7 (init-h 7))
  # Calculate padding length (for 128-byte blocks)
  (def padlen (mod (- 111 (mod (length input) 128)) 128))
  # Convert input to buffer
  (def msg (buffer/new (+ (length input) 1 padlen 16)))
  (buffer/push-string msg input)
  # Add padding to message
  (buffer/push msg 0x80)
  (for i 0 padlen
    (buffer/push msg 0x00))
  # Input length as bits (uses 128-bit length field)
  (def bitlen (ops/blen input))
  # Extract high 64 bits (word 1) and low 64 bits (word 0) from bitlen
  (def hi64 (ops/bword64 bitlen 1))
  (def lo64 (ops/bword64 bitlen 0))
  (buffer/push-string msg (word-flip64 hi64 0))
  (buffer/push-string msg (word-flip64 lo64 0))
  (var begin 0)
  (while (< begin (length msg))
    # Initialize working variables
    (var a h0)
    (var b h1)
    (var c h2)
    (var d h3)
    (var e h4)
    (var f h5)
    (var g h6)
    (var h h7)
    # Prepare message schedule array W[0..79]
    (def W (array/new 80))
    # Copy chunk into first 16 words W[0..15] of the message schedule array
    (for i 0 16
      (put W i (word-flip64 msg (+ begin (* 8 i)))))
    # Extend the first 16 words into the remaining 64 words W[16..79]
    (for i 16 80
      (def s1 (small1-64 (W (- i 2))))
      (def s0 (small0-64 (W (- i 15))))
      (put W i (add64 s1 (W (- i 7)) s0 (W (- i 16)))))
    # Main loop - compression function
    (for i 0 80
      (def S1 (big1-64 e))
      (def ch (choose64 e f g))
      (def temp1 (add64 h S1 ch (K512 i) (W i)))
      (def S0 (big0-64 a))
      (def maj (major64 a b c))
      (def temp2 (add64 S0 maj))
      # Update working variables
      (set h g)
      (set g f)
      (set f e)
      (set e (add64 d temp1))
      (set d c)
      (set c b)
      (set b a)
      (set a (add64 temp1 temp2)))
    # Add this chunk's hash to result
    (set h0 (add64 h0 a))
    (set h1 (add64 h1 b))
    (set h2 (add64 h2 c))
    (set h3 (add64 h3 d))
    (set h4 (add64 h4 e))
    (set h5 (add64 h5 f))
    (set h6 (add64 h6 g))
    (set h7 (add64 h7 h))
    (set begin (+ begin 128)))
  # Produce the final hash value
  (def hash-words [h0 h1 h2 h3 h4 h5 h6 h7])
  (-> (buffer ;(array/slice hash-words 0 num-output-words))
      (ops/bstring :bits 64 :be? true)))

(defn- sha384
  [input]
  # Initialize hash values (first 64 bits of fractional parts of square roots
  # of 9th through 16th primes: 23, 29, 31, 37, 41, 43, 47, 53)
  (defn init-h [i]
    (case i
      0 (ops/bjoin 0xcbbb9d5d 0xc1059ed8)
      1 (ops/bjoin 0x629a292a 0x367cd507)
      2 (ops/bjoin 0x9159015a 0x3070dd17)
      3 (ops/bjoin 0x152fecd8 0xf70e5939)
      4 (ops/bjoin 0x67332667 0xffc00b31)
      5 (ops/bjoin 0x8eb44a87 0x68581511)
      6 (ops/bjoin 0xdb0c2e0d 0x64f98fa7)
      7 (ops/bjoin 0x47b5481d 0xbefa4fa4)))
  # SHA-384 uses only the first 6 words of the 8-word output
  (digest64 input init-h 6))

(defn- sha512
  [input]
  # Initialize hash values (first 64 bits of fractional parts of square roots
  # of first 8 primes: 2, 3, 5, 7, 11, 13, 17, 19)
  (defn init-h [i]
    (case i
      0 (ops/bjoin 0x6a09e667 0xf3bcc908)
      1 (ops/bjoin 0xbb67ae85 0x84caa73b)
      2 (ops/bjoin 0x3c6ef372 0xfe94f82b)
      3 (ops/bjoin 0xa54ff53a 0x5f1d36f1)
      4 (ops/bjoin 0x510e527f 0xade682d1)
      5 (ops/bjoin 0x9b05688c 0x2b3e6c1f)
      6 (ops/bjoin 0x1f83d9ab 0xfb41bd6b)
      7 (ops/bjoin 0x5be0cd19 0x137e2179)))
  # SHA-512 uses all 8 words of output
  (digest64 input init-h 8))

(defn digest
  ```
  Calculates a digest of `input` using the SHA2 algorithm

  The value of `kind` can be one of `:256`, `:384` and `:512`.
  ```
  [kind input]
  (case kind
    :256
    (sha256 input)
    :384
    (sha384 input)
    :512
    (sha512 input)))

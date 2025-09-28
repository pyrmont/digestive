(import ./bitops :as ops)

# Helpers

# Add multiple values together and get first 8 bytes (64-bit word)
(defn- add [& xs]
  (def total (ops/badd ;xs))
  (if (<= (length total) 8)
    total
    (buffer/slice total 0 8)))

# Print string by reversing order of 32-bit words (why does this work?))
(defn- bstring [x]
  (def s (ops/bstring x))
  (def res (buffer/new-filled (length s)))
  (for i 0 (length s)
    (def lo? (< (mod i 16) 8))
    (def pos (if lo? (+ i 8) (- i 8)))
    (buffer/push-at res pos (get s i)))
  (string res))

# Get a big-endian 64-bit word from a little-endian buffer
(defn- word-be [b begin]
  (def res @"")
  (for i 0 8
    (buffer/push res (get b (+ begin (- 7 i)))))
  res)

# Create 64-bit word by joining high and low 32-bit words
(defn- join [hi lo]
  (def res @"")
  (buffer/push-word res lo)
  (buffer/push-word res hi)
  res)

# SHA-512 constants (first 64 bits of the fractional parts of the cube roots
# of the first 80 primes)
(def- K [(join 0x428a2f98 0xd728ae22) (join 0x71374491 0x23ef65cd)
         (join 0xb5c0fbcf 0xec4d3b2f) (join 0xe9b5dba5 0x8189dbbc)
         (join 0x3956c25b 0xf348b538) (join 0x59f111f1 0xb605d019)
         (join 0x923f82a4 0xaf194f9b) (join 0xab1c5ed5 0xda6d8118)
         (join 0xd807aa98 0xa3030242) (join 0x12835b01 0x45706fbe)
         (join 0x243185be 0x4ee4b28c) (join 0x550c7dc3 0xd5ffb4e2)
         (join 0x72be5d74 0xf27b896f) (join 0x80deb1fe 0x3b1696b1)
         (join 0x9bdc06a7 0x25c71235) (join 0xc19bf174 0xcf692694)
         (join 0xe49b69c1 0x9ef14ad2) (join 0xefbe4786 0x384f25e3)
         (join 0x0fc19dc6 0x8b8cd5b5) (join 0x240ca1cc 0x77ac9c65)
         (join 0x2de92c6f 0x592b0275) (join 0x4a7484aa 0x6ea6e483)
         (join 0x5cb0a9dc 0xbd41fbd4) (join 0x76f988da 0x831153b5)
         (join 0x983e5152 0xee66dfab) (join 0xa831c66d 0x2db43210)
         (join 0xb00327c8 0x98fb213f) (join 0xbf597fc7 0xbeef0ee4)
         (join 0xc6e00bf3 0x3da88fc2) (join 0xd5a79147 0x930aa725)
         (join 0x06ca6351 0xe003826f) (join 0x14292967 0x0a0e6e70)
         (join 0x27b70a85 0x46d22ffc) (join 0x2e1b2138 0x5c26c926)
         (join 0x4d2c6dfc 0x5ac42aed) (join 0x53380d13 0x9d95b3df)
         (join 0x650a7354 0x8baf63de) (join 0x766a0abb 0x3c77b2a8)
         (join 0x81c2c92e 0x47edaee6) (join 0x92722c85 0x1482353b)
         (join 0xa2bfe8a1 0x4cf10364) (join 0xa81a664b 0xbc423001)
         (join 0xc24b8b70 0xd0f89791) (join 0xc76c51a3 0x0654be30)
         (join 0xd192e819 0xd6ef5218) (join 0xd6990624 0x5565a910)
         (join 0xf40e3585 0x5771202a) (join 0x106aa070 0x32bbd1b8)
         (join 0x19a4c116 0xb8d2d0c8) (join 0x1e376c08 0x5141ab53)
         (join 0x2748774c 0xdf8eeb99) (join 0x34b0bcb5 0xe19b48a8)
         (join 0x391c0cb3 0xc5c95a63) (join 0x4ed8aa4a 0xe3418acb)
         (join 0x5b9cca4f 0x7763e373) (join 0x682e6ff3 0xd6b2b8a3)
         (join 0x748f82ee 0x5defb2fc) (join 0x78a5636f 0x43172f60)
         (join 0x84c87814 0xa1f0ab72) (join 0x8cc70208 0x1a6439ec)
         (join 0x90befffa 0x23631e28) (join 0xa4506ceb 0xde82bde9)
         (join 0xbef9a3f7 0xb2c67915) (join 0xc67178f2 0xe372532b)
         (join 0xca273ece 0xea26619c) (join 0xd186b8c7 0x21c0c207)
         (join 0xeada7dd6 0xcde0eb1e) (join 0xf57d4f7f 0xee6ed178)
         (join 0x06f067aa 0x72176fba) (join 0x0a637dc5 0xa2c898a6)
         (join 0x113f9804 0xbef90dae) (join 0x1b710b35 0x131c471b)
         (join 0x28db77f5 0x23047d84) (join 0x32caab7b 0x40c72493)
         (join 0x3c9ebe0a 0x15c9bebc) (join 0x431d67c4 0x9c100d4c)
         (join 0x4cc5d4be 0xcb3e42b6) (join 0x597f299c 0xfc657e2a)
         (join 0x5fcb6fab 0x3ad6faec) (join 0x6c44198c 0x4a475817)])
#
# SHA-512 auxiliary functions
(defn- choose [x y z]
  (ops/bxor (ops/band x y) (ops/band (ops/bnot x) z)))

(defn- major [x y z]
  (ops/bxor (ops/bxor (ops/band x y) (ops/band x z)) (ops/band y z)))

(defn- big0 [x]
  (ops/bxor (ops/bxor (ops/blrot x 36) (ops/blrot x 30)) (ops/blrot x 25)))

(defn- big1 [x]
  (ops/bxor (ops/bxor (ops/blrot x 50) (ops/blrot x 46)) (ops/blrot x 23)))

(defn- small0 [x]
  (ops/bxor (ops/bxor (ops/blrot x 63) (ops/blrot x 56)) (ops/brushift x 7)))

(defn- small1 [x]
  (ops/bxor (ops/bxor (ops/blrot x 45) (ops/blrot x 3)) (ops/brushift x 6)))

# Digest function

(defn digest
  ```
  Calculates a digest of `input` using the SHA-512 algorithm
  ```
  [input]
  # Initialize hash values (SHA-512 uses 8 64-bit words)
  # These are the first 64 bits of the fractional parts of the square roots
  # of the first 8 primes 2..19
  (var h0 (join 0x6a09e667 0xf3bcc908))
  (var h1 (join 0xbb67ae85 0x84caa73b))
  (var h2 (join 0x3c6ef372 0xfe94f82b))
  (var h3 (join 0xa54ff53a 0x5f1d36f1))
  (var h4 (join 0x510e527f 0xade682d1))
  (var h5 (join 0x9b05688c 0x2b3e6c1f))
  (var h6 (join 0x1f83d9ab 0xfb41bd6b))
  (var h7 (join 0x5be0cd19 0x137e2179))
  # Calculate padding length (for 128-byte blocks)
  (def padlen (- 112 (mod (+ (length input) 1) 128)))
  # Convert input to buffer
  (def msg (buffer/new (+ (length input) 1 padlen 16)))
  (buffer/push-string msg input)
  # Add padding to message
  (buffer/push msg 0x80)
  (for i 0 padlen
    (buffer/push msg 0x00))
  # Input length as bits (SHA-512 uses 128-bit length field)
  (def bitlen (ops/blen input))
  # Extract high 64 bits (word 1) and low 64 bits (word 0) from bitlen
  (def hi64 (ops/bword64 bitlen 1))
  (def lo64 (ops/bword64 bitlen 0))
  (buffer/push-string msg (word-be hi64 0))
  (buffer/push-string msg (word-be lo64 0))
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
      (put W i (word-be msg (+ begin (* 8 i)))))
    # Extend the first 16 words into the remaining 64 words W[16..79]
    (for i 16 80
      (def s1 (small1 (W (- i 2))))
      (def s0 (small0 (W (- i 15))))
      (put W i (add s1 (W (- i 7)) s0 (W (- i 16)))))
    # Main loop - compression function
    (for i 0 80
      (def S1 (big1 e))
      (def ch (choose e f g))
      (def temp1 (add h S1 ch (K i) (W i)))
      (def S0 (big0 a))
      (def maj (major a b c))
      (def temp2 (add S0 maj))
      # Update working variables
      (set h g)
      (set g f)
      (set f e)
      (set e (add d temp1))
      (set d c)
      (set c b)
      (set b a)
      (set a (add temp1 temp2)))
    # Add this chunk's hash to result
    (set h0 (add h0 a))
    (set h1 (add h1 b))
    (set h2 (add h2 c))
    (set h3 (add h3 d))
    (set h4 (add h4 e))
    (set h5 (add h5 f))
    (set h6 (add h6 g))
    (set h7 (add h7 h))
    (set begin (+ begin 128)))
  # Produce the final hash value
  (->> (buffer h0 h1 h2 h3 h4 h5 h6 h7)
       (bstring)))

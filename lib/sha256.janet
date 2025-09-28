(import ./bitops :as ops)

# Helpers

# Add multiple values together and get first word
(defn- add [& xs]
  (def total (ops/badd ;xs))
  (if (<= (length total) 4)
    total
    (buffer/slice total 0 4)))

# Get a word from a buffer and flip its endianness
(defn- word-flip [b begin]
  (def res @"")
  (def end (+ 4 begin))
  (for i 0 4
    (buffer/push res (get b (- end i 1))))
  res)

# SHA-256 constants (first 32 bits of the fractional parts of the cube roots
# of the first 64 primes 2..311)
(def- K [0x428a2f98 0x71374491 0xb5c0fbcf 0xe9b5dba5
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

# SHA-256 auxiliary functions

(defn- choose [x y z]
  (ops/bxor (ops/band x y) (ops/band (ops/bnot x) z)))

(defn- major [x y z]
  (ops/bxor (ops/bxor (ops/band x y) (ops/band x z)) (ops/band y z)))

(defn- big0 [x]
  (ops/bxor (ops/bxor (ops/blrot x 30) (ops/blrot x 19)) (ops/blrot x 10)))

(defn- big1 [x]
  (ops/bxor (ops/bxor (ops/blrot x 26) (ops/blrot x 21)) (ops/blrot x 7)))

(defn- small0 [x]
  (ops/bxor (ops/bxor (ops/blrot x 25) (ops/blrot x 14)) (ops/brushift x 3)))

(defn- small1 [x]
  (ops/bxor (ops/bxor (ops/blrot x 15) (ops/blrot x 13)) (ops/brushift x 10)))

# Digest function

(defn digest
  ```
  Calculates a digest of `input` using the SHA-256 algorithm
  ```
  [input]
  # Initialize hash values (SHA-256 uses 8 32-bit words)
  # These are the first 32 bits of the fractional parts of the square roots
  # of the first 8 primes 2..19
  (var h0 (buffer/push-word @"" 0x6a09e667))
  (var h1 (buffer/push-word @"" 0xbb67ae85))
  (var h2 (buffer/push-word @"" 0x3c6ef372))
  (var h3 (buffer/push-word @"" 0xa54ff53a))
  (var h4 (buffer/push-word @"" 0x510e527f))
  (var h5 (buffer/push-word @"" 0x9b05688c))
  (var h6 (buffer/push-word @"" 0x1f83d9ab))
  (var h7 (buffer/push-word @"" 0x5be0cd19))
  # Calculate padding length
  (def padlen (- 56 (mod (+ (length input) 1) 64)))
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
  (buffer/push-string msg (word-flip hi32 0))
  (buffer/push-string msg (word-flip lo32 0))
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
      (put W i (word-flip msg (+ begin (* 4 i)))))
    # Extend the first 16 words into the remaining 48 words W[16..63]
    (for i 16 64
      (def s1 (small1 (W (- i 2))))
      (def s0 (small0 (W (- i 15))))
      (put W i (add s1 (W (- i 7)) s0 (W (- i 16)))))
    # Main loop - compression function
    (for i 0 64
      (def S1 (big1 e))
      (def ch (choose e f g))
      (def temp1 (add h S1 ch (buffer/push-word @"" (K i)) (W i)))
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
    (set begin (+ begin 64)))
  # Produce the final hash value
  (-> (buffer h0 h1 h2 h3 h4 h5 h6 h7)
      (ops/bstring :be? true)))

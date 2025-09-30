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

# Pre-computed constants for SHA1, derived from square roots of primes
(def- K0 (buffer/push-word @"" 0x5A827999))  # sqrt(2)  for rounds 0-19
(def- K1 (buffer/push-word @"" 0x6ED9EBA1))  # sqrt(3)  for rounds 20-39
(def- K2 (buffer/push-word @"" 0x8F1BBCDC))  # sqrt(5)  for rounds 40-59
(def- K3 (buffer/push-word @"" 0xCA62C1D6))  # sqrt(10) for rounds 60-79

# Digest function

(defn digest
  ```
  Calculates a digest of `input` using the SHA1 algorithm
  ```
  [input]
  # Initialize hash values (SHA1 uses 5 32-bit words)
  (var h0 (buffer/push-word @"" 0x67452301))
  (var h1 (buffer/push-word @"" 0xEFCDAB89))
  (var h2 (buffer/push-word @"" 0x98BADCFE))
  (var h3 (buffer/push-word @"" 0x10325476))
  (var h4 (buffer/push-word @"" 0xC3D2E1F0))
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
  (buffer/push-string msg (word-flip hi32 0))
  (buffer/push-string msg (word-flip lo32 0))
  (var begin 0)
  (while (< begin (length msg))
    # Initialize working variables
    (var A h0)
    (var B h1)
    (var C h2)
    (var D h3)
    (var E h4)
    # Prepare message schedule array W[0..79]
    (def W (array/new 80))
    # Copy chunk into first 16 words W[0..15] of the message schedule array
    (for i 0 16
      (put W i (word-flip msg (+ begin (* 4 i)))))
    # Extend the sixteen 32-bit words into eighty 32-bit words
    (for i 16 80
      (def w (ops/bxor (W (- i 3))
                       (ops/bxor (W (- i 8))
                                 (ops/bxor (W (- i 14))
                                           (W (- i 16))))))
      (put W i (ops/blrot w 1)))
    # Main loop
    (for i 0 80
      (var F nil)
      (var K nil)
      (cond
        # Round 1
        (<= 0 i 19)
        (do
          # F = (B AND C) OR ((NOT B) AND D)
          (set F (ops/bor (ops/band B C)
                          (ops/band (ops/bnot B) D)))
          (set K K0))
        # Round 2
        (<= 20 i 39)
        (do
          # F = B XOR C XOR D
          (set F (ops/bxor (ops/bxor B C) D))
          (set K K1))
        # Round 3
        (<= 40 i 59)
        (do
          # F = (B AND C) OR (B AND D) OR (C AND D)
          (set F (ops/bor (ops/band B C)
                          (ops/bor (ops/band B D)
                                   (ops/band C D))))
          (set K K2))
        # Round 4
        (do
          # F = B XOR C XOR D
          (set F (ops/bxor (ops/bxor B C) D))
          (set K K3)))
      (def temp (add (ops/blrot A 5) F E K (W i)))
      # Update working variables
      (set E D)
      (set D C)
      (set C (ops/blrot B 30))
      (set B A)
      (set A temp))
    # Add this chunk's hash to result
    (set h0 (add h0 A))
    (set h1 (add h1 B))
    (set h2 (add h2 C))
    (set h3 (add h3 D))
    (set h4 (add h4 E))
    (set begin (+ begin 64)))
  # Produce the final hash value
  (-> (buffer h0 h1 h2 h3 h4)
      (ops/bstring :be? true)))

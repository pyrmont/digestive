(import ./bitops :as ops)

# Helpers

# Add multiple values together and get first word
(defn- add [& xs]
  (def total (ops/badd ;xs))
  (if (<= (length total) 4)
    total
    (buffer/slice total 0 4)))

# Get a word from a buffer
(defn- word [b &opt begin]
  (default begin 0)
  (buffer/slice b begin (+ 4 begin)))

# Specify the per-round shift numbers
(def- s (array 7  12 17 22 7  12 17 22 7  12 17 22 7  12 17 22
               5  9  14 20 5  9  14 20 5  9  14 20 5  9  14 20
               4  11 16 23 4  11 16 23 4  11 16 23 4  11 16 23
               6  10 15 21 6  10 15 21 6  10 15 21 6  10 15 21))

# Use buffers as arrays of 32-bit unsigned integers
(def- K (buffer/new 256))

# Use pre-computer table of the integer part of the sines of integers
(buffer/push-word K 0xd76aa478 0xe8c7b756 0x242070db 0xc1bdceee)
(buffer/push-word K 0xf57c0faf 0x4787c62a 0xa8304613 0xfd469501)
(buffer/push-word K 0x698098d8 0x8b44f7af 0xffff5bb1 0x895cd7be)
(buffer/push-word K 0x6b901122 0xfd987193 0xa679438e 0x49b40821)
(buffer/push-word K 0xf61e2562 0xc040b340 0x265e5a51 0xe9b6c7aa)
(buffer/push-word K 0xd62f105d 0x02441453 0xd8a1e681 0xe7d3fbc8)
(buffer/push-word K 0x21e1cde6 0xc33707d6 0xf4d50d87 0x455a14ed)
(buffer/push-word K 0xa9e3e905 0xfcefa3f8 0x676f02d9 0x8d2a4c8a)
(buffer/push-word K 0xfffa3942 0x8771f681 0x6d9d6122 0xfde5380c)
(buffer/push-word K 0xa4beea44 0x4bdecfa9 0xf6bb4b60 0xbebfbc70)
(buffer/push-word K 0x289b7ec6 0xeaa127fa 0xd4ef3085 0x04881d05)
(buffer/push-word K 0xd9d4d039 0xe6db99e5 0x1fa27cf8 0xc4ac5665)
(buffer/push-word K 0xf4292244 0x432aff97 0xab9423a7 0xfc93a039)
(buffer/push-word K 0x655b59c3 0x8f0ccc92 0xffeff47d 0x85845dd1)
(buffer/push-word K 0x6fa87e4f 0xfe2ce6e0 0xa3014314 0x4e0811a1)
(buffer/push-word K 0xf7537e82 0xbd3af235 0x2ad7d2bb 0xeb86d391)

# Digest function

(defn digest
  ```
  Calculates a digest of `input` using the MD5 algorithm
  ```
  [input]
  # Initialise variables
  (var a0 (buffer/push-word @"" 0x67452301))
  (var b0 (buffer/push-word @"" 0xefcdab89))
  (var c0 (buffer/push-word @"" 0x98badcfe))
  (var d0 (buffer/push-word @"" 0x10325476))
  # Calculate padding length
  (def padlen (- 56 (mod (+ (length input) 1) 64)))
  # Convert input to buffer
  (def msg (buffer/new (+ (length input) 1 padlen 8)))
  (buffer/push-string msg input)
  # Add padding to message
  (buffer/push msg 0x80)
  (for i 0 padlen
    (buffer/push msg 0x00))
  # Add low-order 64-bits of input length
  (buffer/push-word msg (* 8 (length input)) 0)
  (var begin 0)
  (while (< begin (length msg))
    (var A a0)
    (var B b0)
    (var C c0)
    (var D d0)
    # Main loop
    (for i 0 64
      (var F nil)
      (var g nil)
      (cond
        # Round 1
        (<= 0 i 15)
        (do
          (set F (ops/bor (ops/band B C) (ops/band (ops/bnot B) D)))
          (set g i))
        # Round 2
        (<= 16 i 31)
        (do
          (set F (ops/bor (ops/band D B) (ops/band (ops/bnot D) C)))
          (set g (mod (+ 1 (* 5 i)) 16)))
        # Round 3
        (<= 32 i 47)
        (do
          (set F (ops/bxor (ops/bxor B C) D))
          (set g (mod (+ (* 3 i) 5) 16)))
        # Round 4
        (do
          (set F (ops/bxor C (ops/bor B (ops/bnot D))))
          (set g (mod (* 7 i) 16))))
      # Update working variables
      (set F (add F A (word K (* 4 i)) (word msg (+ begin (* 4 g)))))
      (set A D)
      (set D C)
      (set C B)
      (set B (add B (ops/blrot F (s i)))))
    # Add this chunk's hash to result
    (set a0 (add a0 A))
    (set b0 (add b0 B))
    (set c0 (add c0 C))
    (set d0 (add d0 D))
    (set begin (+ begin 64)))
  # Produce the final hash value
  (->> (map string/reverse [a0 b0 c0 d0])
       (apply buffer)
       (ops/bstring)))

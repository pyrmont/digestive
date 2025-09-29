# Bitwise functions on arbitrary length little-endian buffers

(defn band [x y]
  (def res (buffer/new-filled (length x)))
  (def ylen (* 8 (length y)))
  (for i 0 (* 8 (length x))
    (if (= i ylen)
      (break))
    (if (and (buffer/bit x i) (buffer/bit y i))
      (buffer/bit-set res i)))
  res)

(defn bor [x y]
  (def res (buffer/new-filled (length x)))
  (for i 0 (* 8 (length x))
    (if (or (buffer/bit x i) (buffer/bit y i))
      (buffer/bit-set res i)))
  res)

(defn bxor [x y]
  (def res (buffer/new-filled (length x)))
  (for i 0 (* 8 (length x))
    (if (= (buffer/bit x i) (not (buffer/bit y i)))
      (buffer/bit-set res i)))
  res)

(defn bnot [x]
  (def res (buffer/new-filled (length x)))
  (for i 0 (* 8 (length x))
    (if (not (buffer/bit x i))
      (buffer/bit-set res i)))
  res)

(defn blshift [x n]
  (def res (buffer/new-filled (length x)))
  (for i n (* 8 (length x))
    (if (buffer/bit x (- i n))
      (buffer/bit-set res i)))
  res)

(defn brushift [x n]
  (def res (buffer/new-filled (length x)))
  (for i n (* 8 (length x))
    (if (buffer/bit x i)
      (buffer/bit-set res (- i n))))
  res)

(defn bzero? [x]
  (var i 0)
  (while (< i (length x))
    (if (buffer/bit x i)
      (break))
    (++ i))
  (= i (length x)))

(defn blrot [x n]
  (def res (buffer/new-filled (length x)))
  (def bitlen (* 8 (length x)))
  (for i 0 bitlen
    (def pos (if (< (+ i n) bitlen) (+ i n) (% (+ i n) bitlen)))
    (if (buffer/bit x i)
      (buffer/bit-set res pos)))
  res)

# Utility functions

(defn badd [x & ys]
  (var res (buffer x))
  (each y ys
    (var carry false)
    (var reslen (* 8 (length res)))
    (def ylen (* 8 (length y)))
    (var i 0)
    (while (< i reslen)
      (if (= i ylen)
        (break))
      (cond
        (and (buffer/bit res i) (buffer/bit y i))
        (do
          (if (not carry)
            (buffer/bit-clear res i))
          (set carry true))
        (buffer/bit res i)
        (if carry
          (buffer/bit-clear res i))
        (buffer/bit y i)
        (if (not carry)
          (buffer/bit-set res i))
        (when carry
          (buffer/bit-set res i)
          (set carry false)))
      (when (and (= (++ i) reslen) carry)
        (buffer/push-word res 0x01)
        (set carry false)
        (set reslen (* 8 (length res)))))
    (when (> ylen reslen)
      (def start (/ (- ylen reslen) 8))
      (buffer/push-string res (buffer/slice y start))))
  res)

(defn bjoin [hi lo]
  (def res @"")
  (buffer/push-word res lo)
  (buffer/push-word res hi)
  res)

(defn blen [x]
  (def res (buffer/push-word @"" (length x)))
  (blshift res 3))

(defn bstring [x &named bits be?]
  (default bits 32)
  (def res (buffer/new (* 2 (length x))))
  (def width (/ bits 8))
  (var word (buffer/new (* 2 width)))
  (defn flip [b]
    (-> (partition 2 b) reverse string/join))
  (for i 0 (length x)
    (when (and (> i 0) (zero? (mod i width)))
      (buffer/push res (if be? (flip word) word))
      (buffer/clear word))
    (buffer/push word (string/format "%02x" (get x i))))
  (buffer/push res (if be? (flip word) word))
  res)

(defn bword [x i]
  # Extract 4 bytes begining at i * 4
  (def begin (* i 4))
  (if (>= begin (length x))
    (buffer/new-filled 4) # Return 0 if beyond buffer length
    (do
      (def end (min (+ begin 4) (length x)))
      (def res (buffer/slice x begin end))
      # Pad with zeros if needed
      (while (< (length res) 4)
        (buffer/push res 0))
      res)))

(defn bword64 [x i]
  # Extract 8 bytes beginning at i * 8
  (def begin (* i 8))
  (if (>= begin (length x))
    (buffer/new-filled 8)  # Return 0 if beyond buffer length
    (do
      (def end (min (+ begin 8) (length x)))
      (def res (buffer/slice x begin end))
      # Pad with zeros if needed
      (while (< (length res) 8)
        (buffer/push res 0))
      res)))

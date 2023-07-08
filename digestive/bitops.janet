(defn bnew [x]
  (buffer/push-word @"" x))


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


(defn bstring [x]
  (def bitcount (* 8 (length x)))
  (var buf @"")
  (var word 0)
  (for i 0 bitcount
    (set word (+ word (if (buffer/bit x i) (math/exp2 (% i 32)) 0)))
    (when (or (= bitcount (inc i)) (zero? (% (inc i) 32)))
      (buffer/push buf (string/format "%08x" word))
      (set word 0)))
  (string buf))


(defn bprint [x]
  (print (bstring x)))

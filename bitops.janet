(defn band [x y]
  (def res (buffer/new-filled (length x)))
  (for i 0 (* 8 (length x))
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
  (var res x)
  (each y ys
    (var carry (band res y))
    (set res (bxor res y))
    (while (not (bzero? carry))
      (def scarry (blshift carry 1))
      (set carry (band res scarry))
      (set res (bxor res scarry))))
  res)


(defn bprint [x]
  (var res 0)
  (def bitcount (* 8 (length x)))
  (for i 0 bitcount
    (set res (+ res (if (buffer/bit x i) (math/exp2 (% i 32)) 0)))
    (when (or (= bitcount (inc i)) (zero? (% (inc i) 32)))
      (prinf "%08x " res)
      (set res 0)))
  (print))

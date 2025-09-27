(use ../deps/testament)

(import ../lib/bitops :as bitops)


(deftest bitwise-and
  (def x (buffer/push-word @"" 0xdead))
  (def y (buffer/push-word @"" 0xbeef))
  (def actual (bitops/bstring (bitops/band x y)))
  (def expect (string/format "%08x" (band 0xdead 0xbeef)))
  (is (== expect actual)))


(deftest bitwise-or
  (def x (buffer/push-word @"" 0xdead))
  (def y (buffer/push-word @"" 0xbeef))
  (def actual (bitops/bstring (bitops/bor x y)))
  (def expect (string/format "%08x" (bor 0xdead 0xbeef)))
  (is (== expect actual)))


(deftest bitwise-xor
  (def x (buffer/push-word @"" 0xdead))
  (def y (buffer/push-word @"" 0xbeef))
  (def actual (bitops/bstring (bitops/bxor x y)))
  (def expect (string/format "%08x" (bxor 0xdead 0xbeef)))
  (is (== expect actual)))


(deftest bitwise-not
  (def x (buffer/push-word @"" 0xdead))
  (def actual (bitops/bstring (bitops/bnot x)))
  (def expect-x (band (bnot (int/u64 0xdead)) 0xFFFFFFFF))
  (def expect (string/format "%08x" expect-x))
  (is (== expect actual)))


(deftest bitwise-lshift
  (def x (buffer/push-word @"" 0xdead))
  (def actual (bitops/bstring (bitops/blshift x 5)))
  (def expect (string/format "%08x" (blshift 0xdead 5)))
  (is (== expect actual)))


(deftest bitwise-rushift
  (def x (buffer/push-word @"" 0xdead))
  (def actual (bitops/bstring (bitops/brushift x 5)))
  (def expect (string/format "%08x" (brushift 0xdead 5)))
  (is (== expect actual)))


(deftest bitwise-zero?
  (def x (buffer/push-word @"" 0x00))
  (def actual (bitops/bzero? x))
  (def expect (zero? 0x00))
  (is (== expect actual)))


(deftest bitwise-blrot
  (def x (buffer/push-word @"" 0xdead))
  (def actual (bitops/bstring (bitops/blrot x 5)))
  (defn lrot [x n] (bor (blshift x n) (brushift n (- 32 n))))
  (def expect (string/format "%08x" (lrot 0xdead 5)))
  (is (== expect actual)))


(deftest bitwise-add-equal-length
  (def x (buffer/push-word @"" 0xdead))
  (def y (buffer/push-word @"" 0xbeef))
  (def actual (bitops/bstring (bitops/badd x y)))
  (def expect (string/format "%08x" (+ 0xdead 0xbeef)))
  (is (== expect actual)))


(deftest bitwise-add-unequal-length-left
  (def x (buffer/push-word @"" 0xdead))
  (def y (buffer/push-word @"" 0xbe))
  (def actual (bitops/bstring (bitops/badd x y)))
  (def expect (string/format "%08x" (+ 0xdead 0xbe)))
  (is (== expect actual)))


(deftest bitwise-add-unequal-length-right
  (def x (buffer/push-word @"" 0xde))
  (def y (buffer/push-word @"" 0xbeef))
  (def actual (bitops/bstring (bitops/badd x y)))
  (def expect (string/format "%08x" (+ 0xde 0xbeef)))
  (is (== expect actual)))


(deftest bitwise-string
  (def actual (bitops/bstring @"\x00\x00\x00\x00"))
  (def expect "00000000")
  (is (== expect actual)))


(run-tests!)

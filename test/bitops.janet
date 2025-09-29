(use ../deps/testament)

(import ../lib/bitops :as bitops)

# Test bitwise functions

(deftest bitwise-and
  (def x (buffer/push-word @"" 0xdead))
  (def y (buffer/push-word @"" 0xbeef))
  (def actual (bitops/bstring (bitops/band x y) :be? true))
  (def expect (string/format "%08x" (band 0xdead 0xbeef)))
  (is (== expect actual)))

(deftest bitwise-or
  (def x (buffer/push-word @"" 0xdead))
  (def y (buffer/push-word @"" 0xbeef))
  (def actual (bitops/bstring (bitops/bor x y) :be? true))
  (def expect (string/format "%08x" (bor 0xdead 0xbeef)))
  (is (== expect actual)))

(deftest bitwise-xor
  (def x (buffer/push-word @"" 0xdead))
  (def y (buffer/push-word @"" 0xbeef))
  (def actual (bitops/bstring (bitops/bxor x y) :be? true))
  (def expect (string/format "%08x" (bxor 0xdead 0xbeef)))
  (is (== expect actual)))

(deftest bitwise-not
  (def x (buffer/push-word @"" 0xdead))
  (def actual (bitops/bstring (bitops/bnot x) :be? true))
  (def expect-x (band (bnot (int/u64 0xdead)) 0xFFFFFFFF))
  (def expect (string/format "%08x" expect-x))
  (is (== expect actual)))

(deftest bitwise-lshift
  (def x (buffer/push-word @"" 0xdead))
  (def actual (bitops/bstring (bitops/blshift x 5) :be? true))
  (def expect (string/format "%08x" (blshift 0xdead 5)))
  (is (== expect actual)))

(deftest bitwise-rushift
  (def x (buffer/push-word @"" 0xdead))
  (def actual (bitops/bstring (bitops/brushift x 5) :be? true))
  (def expect (string/format "%08x" (brushift 0xdead 5)))
  (is (== expect actual)))

(deftest bitwise-zero?
  (def x (buffer/push-word @"" 0x00))
  (def actual (bitops/bzero? x))
  (def expect (zero? 0x00))
  (is (== expect actual)))

(deftest bitwise-lrot
  (def x (buffer/push-word @"" 0xdead))
  (def actual (bitops/bstring (bitops/blrot x 5) :be? true))
  (defn lrot [x n] (bor (blshift x n) (brushift n (- 32 n))))
  (def expect (string/format "%08x" (lrot 0xdead 5)))
  (is (== expect actual)))

# Test utility functions

(deftest badd-equal-length
  (def x (buffer/push-word @"" 0xdead))
  (def y (buffer/push-word @"" 0xbeef))
  (def actual (bitops/bstring (bitops/badd x y) :be? true))
  (def expect (string/format "%08x" (+ 0xdead 0xbeef)))
  (is (== expect actual)))

(deftest badd-unequal-length-left
  (def x (buffer/push-word @"" 0xdead))
  (def y (buffer/push-word @"" 0xbe))
  (def actual (bitops/bstring (bitops/badd x y) :be? true))
  (def expect (string/format "%08x" (+ 0xdead 0xbe)))
  (is (== expect actual)))

(deftest badd-unequal-length-right
  (def x (buffer/push-word @"" 0xde))
  (def y (buffer/push-word @"" 0xbeef))
  (def actual (bitops/bstring (bitops/badd x y) :be? true))
  (def expect (string/format "%08x" (+ 0xde 0xbeef)))
  (is (== expect actual)))

(deftest bjoin
  (def actual1 (bitops/bjoin 0x00000000 0x00000000))
  (def expect1 @"\x00\x00\x00\x00\x00\x00\x00\x00")
  (is (== expect1 actual1))
  (def actual2 (bitops/bjoin 0xdeadbeef 0xcafebabe))
  (def expect2 @"\xBE\xBA\xFE\xCA\xEF\xBE\xAD\xDE")
  (is (== expect2 actual2)))

(deftest blen
  (def actual (bitops/blen "foo"))
  (def expect (buffer/push-word @"" (* 8 (length "foo"))))
  (is (== expect actual)))

(deftest bstring
  (def actual1 (bitops/bstring @"\x00\x00\x00\x00"))
  (def expect1 "00000000")
  (is (== expect1 actual1))
  (def actual2 (bitops/bstring @"\xde\xad\xbe\xef"))
  (def expect2 "deadbeef")
  (is (== expect2 actual2))
  (def actual3 (bitops/bstring @"\x01\x02\x03\x04" :be? true))
  (def expect3 "04030201")
  (is (== expect3 actual3))
  (def actual4 (bitops/bstring @"\x01\x02\x03\x04" :bits 16 :be? true))
  (def expect4 "02010403")
  (is (== expect4 actual4)))

(deftest bword-high
  (def x (buffer "\x01" "\x02" "\x03" "\x04"
                 "\x05" "\x06" "\x07" "\x08"))
  (def actual (bitops/bword x 0))
  (def expect "\x01\x02\x03\x04")
  (is (== expect actual)))

(deftest bword-low
  (def x (buffer "\x01" "\x02" "\x03" "\x04"
                 "\x05" "\x06" "\x07" "\x08"))
  (def actual (bitops/bword x 1))
  (def expect "\x05\x06\x07\x08")
  (is (== expect actual)))

(deftest bword64-high
  (def x (buffer "\x01" "\x02" "\x03" "\x04"
                 "\x05" "\x06" "\x07" "\x08"
                 "\x09" "\x10" "\x11" "\x12"
                 "\x13" "\x14" "\x15" "\x16"))
  (def actual (bitops/bword64 x 0))
  (def expect "\x01\x02\x03\x04\x05\x06\x07\x08")
  (is (== expect actual)))

(deftest bword64-low
  (def x (buffer "\x01" "\x02" "\x03" "\x04"
                 "\x05" "\x06" "\x07" "\x08"
                 "\x09" "\x10" "\x11" "\x12"
                 "\x13" "\x14" "\x15" "\x16"))
  (def actual (bitops/bword64 x 1))
  (def expect "\x09\x10\x11\x12\x13\x14\x15\x16")
  (is (== expect actual)))

(run-tests!)

(use testament)

(import ../md5 :as md5)


(deftest digest
  (def actual1 (md5/digest ""))
  (def expect1 "d41d8cd98f00b204e9800998ecf8427e")
  (is (== expect1 actual1))
  (def actual2 (md5/digest "The quick brown fox jumps over the lazy dog"))
  (def expect2 "9e107d9d372bb6826bd81d3542a419d6")
  (is (== expect2 actual2))
  (def actual3 (md5/digest "The quick brown fox jumps over the lazy dog."))
  (def expect3 "e4d909c290d0fb1ca068ffaddf22cbd0")
  (is (== expect3 actual3))
  (def actual4 (md5/digest "hello"))
  (def expect4 "5d41402abc4b2a76b9719d911017c592")
  (is (== expect4 actual4)))

(run-tests!)

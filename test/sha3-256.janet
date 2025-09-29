(use ../deps/testament)

(import ../lib/sha3-256 :as sha3-256)

(deftest digest
  # Test empty string
  (def actual1 (sha3-256/digest ""))
  (def expect1 "a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (sha3-256/digest "The quick brown fox jumps over the lazy dog"))
  (def expect2 "69070dda01975c8c120c3aada1b282394e7f032fa9cf32f4cb2259a0897dfc04")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (sha3-256/digest "The quick brown fox jumps over the lazy dog."))
  (def expect3 "a80f839cd4f83f6c3dafc87feae470045e4eb0d366397d5c6ce34ba1739f734d")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (sha3-256/digest "hello"))
  (def expect4 "3338be694f50c5f338814986cdf0686453a888b84f424d792af4b9202398f392")
  (is (== expect4 actual4)))

(run-tests!)


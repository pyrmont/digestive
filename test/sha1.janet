(use ../deps/testament)

(import ../lib/sha1 :as sha1)

(deftest digest
  # Test empty string
  (def actual1 (sha1/digest ""))
  (def expect1 "da39a3ee5e6b4b0d3255bfef95601890afd80709")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (sha1/digest "The quick brown fox jumps over the lazy dog"))
  (def expect2 "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (sha1/digest "The quick brown fox jumps over the lazy dog."))
  (def expect3 "408d94384216f890ff7a0c3528e8bed1e0b01621")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (sha1/digest "hello"))
  (def expect4 "aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d")
  (is (== expect4 actual4)))

(run-tests!)

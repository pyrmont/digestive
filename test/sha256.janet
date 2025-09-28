(use ../deps/testament)

(import ../lib/sha256 :as sha256)

(deftest digest
  # Test empty string
  (def actual1 (sha256/digest ""))
  (def expect1 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (sha256/digest "The quick brown fox jumps over the lazy dog"))
  (def expect2 "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (sha256/digest "The quick brown fox jumps over the lazy dog."))
  (def expect3 "ef537f25c895bfa782526529a9b63d97aa631564d5d789c2b765448c8635fb6c")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (sha256/digest "hello"))
  (def expect4 "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
  (is (== expect4 actual4)))

(run-tests!)

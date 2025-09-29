(use ../deps/testament)

(import ../lib/sha2-384 :as sha2-384)

(deftest digest
  # Test empty string
  (def actual1 (sha2-384/digest ""))
  (def expect1 "38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (sha2-384/digest "The quick brown fox jumps over the lazy dog"))
  (def expect2 "ca737f1014a48f4c0b6dd43cb177b0afd9e5169367544c494011e3317dbf9a509cb1e5dc1e85a941bbee3d7f2afbc9b1")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (sha2-384/digest "The quick brown fox jumps over the lazy dog."))
  (def expect3 "ed892481d8272ca6df370bf706e4d7bc1b5739fa2177aae6c50e946678718fc67a7af2819a021c2fc34e91bdb63409d7")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (sha2-384/digest "hello"))
  (def expect4 "59e1748777448c69de6b800d7a33bbfb9ff1b463e44354c3553bcdb9c666fa90125a3c79f90397bdf5f6a13de828684f")
  (is (== expect4 actual4)))

(run-tests!)

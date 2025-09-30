(use ../deps/testament)

(import ../lib/sha1 :as sha1)

(deftest original
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

(deftest fips-180-1
  # Test empty string
  (def actual1 (sha1/digest ""))
  (def expect1 "da39a3ee5e6b4b0d3255bfef95601890afd80709")
  (is (== expect1 actual1))
  # Test "abc"
  (def actual2 (sha1/digest "abc"))
  (def expect2 "a9993e364706816aba3e25717850c26c9cd0d89d")
  (is (== expect2 actual2))
  # Test "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
  (def actual3 (sha1/digest "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"))
  (def expect3 "84983e441c3bd26ebaae4aa1f95129e5e54670f1")
  (is (== expect3 actual3))
  # Test "message digest"
  (def actual4 (sha1/digest "message digest"))
  (def expect4 "c12252ceda8be8994d5fa0290a47231c1d16aae3")
  (is (== expect4 actual4)))

(deftest multi-block
  # Test string that requires multiple blocks (>64 bytes)
  (def input1 (string/repeat "a" 100))
  (def actual1 (sha1/digest input1))
  (def expect1 "7f9000257a4918d7072655ea468540cdcbd42e0c")
  (is (== expect1 actual1))
  # Test file with 1000 bytes
  (def input2 (string/repeat "a" 1000))
  (def actual2 (sha1/digest input2))
  (def expect2 "291e9a6c66994949b57ba5e650361e98fc36b1ba")
  (is (== expect2 actual2)))

(deftest boundary-cases
  # Test single character
  (def actual1 (sha1/digest "a"))
  (def expect1 "86f7e437faa5a7fce15d1ddcb9eaeaea377667b8")
  (is (== expect1 actual1))
  # Test single byte
  (def actual2 (sha1/digest "\x00"))
  (def expect2 "5ba93c9db0cff93f52b521d7420e43f6eda2784f")
  (is (== expect2 actual2))
  # Test at 55 bytes (one byte before padding in first block)
  (def input3 (string/repeat "a" 55))
  (def actual3 (sha1/digest input3))
  (def expect3 "c1c8bbdc22796e28c0e15163d20899b65621d65a")
  (is (== expect3 actual3))
  # Test at 56 bytes (forces length into second block)
  (def input4 (string/repeat "a" 56))
  (def actual4 (sha1/digest input4))
  (def expect4 "c2db330f6083854c99d4b5bfb6e8f29f201be699")
  (is (== expect4 actual4))
  # Test at 64 bytes (exactly one block)
  (def input5 (string/repeat "a" 64))
  (def actual5 (sha1/digest input5))
  (def expect5 "0098ba824b5c16427bd7a1122a5a442a25ec644d")
  (is (== expect5 actual5)))

(run-tests!)

(use ../deps/testament)

(import ../lib/sha2 :as sha2)

(deftest original
  # Test empty string
  (def actual1 (sha2/digest :256 ""))
  (def expect1 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (sha2/digest :256 "The quick brown fox jumps over the lazy dog"))
  (def expect2 "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (sha2/digest :256 "The quick brown fox jumps over the lazy dog."))
  (def expect3 "ef537f25c895bfa782526529a9b63d97aa631564d5d789c2b765448c8635fb6c")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (sha2/digest :256 "hello"))
  (def expect4 "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
  (is (== expect4 actual4)))

(deftest fips-180-2
  # Test empty string
  (def actual1 (sha2/digest :256 ""))
  (def expect1 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
  (is (== expect1 actual1))
  # Test "abc"
  (def actual2 (sha2/digest :256 "abc"))
  (def expect2 "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
  (is (== expect2 actual2))
  # Test "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
  (def actual3 (sha2/digest :256 "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"))
  (def expect3 "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1")
  (is (== expect3 actual3)))

(deftest standard-vectors
  # Test "message digest"
  (def actual1 (sha2/digest :256 "message digest"))
  (def expect1 "f7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1413d393cb650")
  (is (== expect1 actual1))
  # Test lowercase alphabet
  (def actual2 (sha2/digest :256 "abcdefghijklmnopqrstuvwxyz"))
  (def expect2 "71c480df93d6ae2f1efad1447c66c9525e316218cf51fc8d9ed832f2daf18b73")
  (is (== expect2 actual2))
  # Test alphanumeric
  (def actual3 (sha2/digest :256 "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"))
  (def expect3 "db4bfcbd4da0cd85a60c3c37d3fbd8805c77f15fc6b1fdfe614ee0a7c8fdb4c0")
  (is (== expect3 actual3))
  # Test numbers
  (def actual4 (sha2/digest :256 "12345678901234567890123456789012345678901234567890123456789012345678901234567890"))
  (def expect4 "f371bc4a311f2b009eef952dd83ca80e2b60026c8e935592d0f9c308453c813e")
  (is (== expect4 actual4)))

(deftest multi-block
  # Test string that requires multiple blocks (>64 bytes)
  (def input1 (string/repeat "a" 100))
  (def actual1 (sha2/digest :256 input1))
  (def expect1 "2816597888e4a0d3a36b82b83316ab32680eb8f00f8cd3b904d681246d285a0e")
  (is (== expect1 actual1))
  # Test file with 1000 bytes
  (def input2 (string/repeat "a" 1000))
  (def actual2 (sha2/digest :256 input2))
  (def expect2 "41edece42d63e8d9bf515a9ba6932e1c20cbc9f5a5d134645adb5db1b9737ea3")
  (is (== expect2 actual2)))

(deftest boundary-cases
  # Test single character
  (def actual1 (sha2/digest :256 "a"))
  (def expect1 "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb")
  (is (== expect1 actual1))
  # Test single byte
  (def actual2 (sha2/digest :256 "\x00"))
  (def expect2 "6e340b9cffb37a989ca544e6bb780a2c78901d3fb33738768511a30617afa01d")
  (is (== expect2 actual2))
  # Test at 55 bytes (one byte before padding in first block)
  (def input3 (string/repeat "a" 55))
  (def actual3 (sha2/digest :256 input3))
  (def expect3 "9f4390f8d30c2dd92ec9f095b65e2b9ae9b0a925a5258e241c9f1e910f734318")
  (is (== expect3 actual3))
  # Test at 56 bytes (forces length into second block)
  (def input4 (string/repeat "a" 56))
  (def actual4 (sha2/digest :256 input4))
  (def expect4 "b35439a4ac6f0948b6d6f9e3c6af0f5f590ce20f1bde7090ef7970686ec6738a")
  (is (== expect4 actual4))
  # Test at 64 bytes (exactly one block)
  (def input5 (string/repeat "a" 64))
  (def actual5 (sha2/digest :256 input5))
  (def expect5 "ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb")
  (is (== expect5 actual5)))

(run-tests!)

(use ../deps/testament)

(import ../lib/blake3 :as blake3)

(deftest original
  # Test empty string
  (def actual1 (blake3/digest :256 ""))
  (def expect1 "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (blake3/digest :256 "The quick brown fox jumps over the lazy dog"))
  (def expect2 "2f1514181aadccd913abd94cfa592701a5686ab23f8df1dff1b74710febc6d4a")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (blake3/digest :256 "The quick brown fox jumps over the lazy dog."))
  (def expect3 "4c9bd68d7f0baa2e167cef98295eb1ec99a3ec8f0656b33dbae943b387f31d5d")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (blake3/digest :256 "hello"))
  (def expect4 "ea8f163db38682925e4491c5e58d4bb3506ef8c14eb78a86e908c5624a67200f")
  (is (== expect4 actual4)))

(deftest official-vectors
  # Test empty string
  (def actual1 (blake3/digest :256 ""))
  (def expect1 "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262")
  (is (== expect1 actual1))
  # Test "abc"
  (def actual2 (blake3/digest :256 "abc"))
  (def expect2 "6437b3ac38465133ffb63b75273a8db548c558465d79db03fd359c6cd5bd9d85")
  (is (== expect2 actual2))
  # Test "BLAKE3"
  (def actual3 (blake3/digest :256 "BLAKE3"))
  (def expect3 "f890484173e516bfd935ef3d22b912dc9738de38743993cfedf2c9473b3216a4")
  (is (== expect3 actual3)))

(deftest standard-vectors
  # Test "message digest"
  (def actual1 (blake3/digest :256 "message digest"))
  (def expect1 "7bc2a2eeb95ddbf9b7ecf6adcb76b453091c58dc43955e1d9482b1942f08d19b")
  (is (== expect1 actual1))
  # Test lowercase alphabet
  (def actual2 (blake3/digest :256 "abcdefghijklmnopqrstuvwxyz"))
  (def expect2 "2468eec8894acfb4e4df3a51ea916ba115d48268287754290aae8e9e6228e85f")
  (is (== expect2 actual2))
  # Test alphanumeric
  (def actual3 (blake3/digest :256 "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"))
  (def expect3 "8bee3200baa9f3a1acd279f049f914f110e730555ff15109bd59cdd73895e239")
  (is (== expect3 actual3))
  # Test numbers
  (def actual4 (blake3/digest :256 "12345678901234567890123456789012345678901234567890123456789012345678901234567890"))
  (def expect4 "f263acf51621980b9c8de5da4a17d314984e05abe4a21cc83a07fe3e1e366dd1")
  (is (== expect4 actual4)))

(deftest multi-chunk
  # Test string that requires multiple chunks (>1024 bytes for BLAKE3)
  (def input1 (string/repeat "a" 2000))
  (def actual1 (blake3/digest :256 input1))
  (def expect1 "c849401fee5e93cf05cbbeb2c60ae6fda8778dfadb996910aded82052fff769d")
  (is (== expect1 actual1))
  # Test exactly 3 chunks
  (def input2 (string/repeat "b" 3072))
  (def actual2 (blake3/digest :256 input2))
  (def expect2 "940b4c89041480123ad64bb0eff465f66596853cd518ad6c4cdc0941e3cdd9aa")
  (is (== expect2 actual2)))

(deftest boundary-cases
  # Test single character
  (def actual1 (blake3/digest :256 "a"))
  (def expect1 "17762fddd969a453925d65717ac3eea21320b66b54342fde15128d6caf21215f")
  (is (== expect1 actual1))
  # Test single byte
  (def actual2 (blake3/digest :256 "\x00"))
  (def expect2 "2d3adedff11b61f14c886e35afa036736dcd87a74d27b5c1510225d0f592e213")
  (is (== expect2 actual2))
  # Test at 1023 bytes (one byte before chunk boundary)
  (def input3 (string/repeat "a" 1023))
  (def actual3 (blake3/digest :256 input3))
  (def expect3 "d1a12877ca3fa679de7e9a2af16d67498aaa4ad315f0a98dba2cea3ebc9c0250")
  (is (== expect3 actual3))
  # Test at 1024 bytes (exactly one chunk)
  (def input4 (string/repeat "a" 1024))
  (def actual4 (blake3/digest :256 input4))
  (def expect4 "5a1c9e5d85d9898297037e8e24f69bb0e604a84c91c3b3ef4784a374812900d9")
  (is (== expect4 actual4))
  # Test at 1025 bytes (one byte over chunk boundary)
  (def input5 (string/repeat "a" 1025))
  (def actual5 (blake3/digest :256 input5))
  (def expect5 "c59d2e12583df14d951e757a42f1734d355c8c5b1db6b6a33ab2bfabeed40c7d")
  (is (== expect5 actual5))
  # Test at 2048 bytes (exactly two chunks)
  (def input6 (string/repeat "a" 2048))
  (def actual6 (blake3/digest :256 input6))
  (def expect6 "11654ac17d073b0905429320fee0a34776cb5f10a9767287c70b627fc4f45539")
  (is (== expect6 actual6)))

(run-tests!)

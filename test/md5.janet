(use ../deps/testament)

(import ../lib/md5 :as md5)

(deftest original
  # Test empty string
  (def actual1 (md5/digest ""))
  (def expect1 "d41d8cd98f00b204e9800998ecf8427e")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (md5/digest "The quick brown fox jumps over the lazy dog"))
  (def expect2 "9e107d9d372bb6826bd81d3542a419d6")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (md5/digest "The quick brown fox jumps over the lazy dog."))
  (def expect3 "e4d909c290d0fb1ca068ffaddf22cbd0")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (md5/digest "hello"))
  (def expect4 "5d41402abc4b2a76b9719d911017c592")
  (is (== expect4 actual4)))

(deftest rfc-1321
  # Test empty string
  (def actual1 (md5/digest ""))
  (def expect1 "d41d8cd98f00b204e9800998ecf8427e")
  (is (== expect1 actual1))
  # Test "abc"
  (def actual2 (md5/digest "abc"))
  (def expect2 "900150983cd24fb0d6963f7d28e17f72")
  (is (== expect2 actual2))
  # Test "message digest"
  (def actual3 (md5/digest "message digest"))
  (def expect3 "f96b697d7cb7938d525a2f31aaf161d0")
  (is (== expect3 actual3))
  # Test lowercase alphabet
  (def actual4 (md5/digest "abcdefghijklmnopqrstuvwxyz"))
  (def expect4 "c3fcd3d76192e4007dfb496cca67e13b")
  (is (== expect4 actual4))
  # Test alphanumeric
  (def actual5 (md5/digest "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"))
  (def expect5 "d174ab98d277d9f5a5611c2c9f419d9f")
  (is (== expect5 actual5))
  # Test numbers
  (def actual6 (md5/digest "12345678901234567890123456789012345678901234567890123456789012345678901234567890"))
  (def expect6 "57edf4a22be3c955ac49da2e2107b67a")
  (is (== expect6 actual6)))

(deftest multi-block
  # Test string that requires multiple blocks (>64 bytes)
  (def input1 (string/repeat "a" 100))
  (def actual1 (md5/digest input1))
  (def expect1 "36a92cc94a9e0fa21f625f8bfb007adf")
  (is (== expect1 actual1))
  # Test file with 1000 bytes
  (def input2 (string/repeat "a" 1000))
  (def actual2 (md5/digest input2))
  (def expect2 "cabe45dcc9ae5b66ba86600cca6b8ba8")
  (is (== expect2 actual2)))

(deftest boundary-cases
  # Test single character
  (def actual1 (md5/digest "a"))
  (def expect1 "0cc175b9c0f1b6a831c399e269772661")
  (is (== expect1 actual1))
  # Test single byte
  (def actual2 (md5/digest "\x00"))
  (def expect2 "93b885adfe0da089cdf634904fd59f71")
  (is (== expect2 actual2))
  # Test at 55 bytes (one byte before padding in first block)
  (def actual3 (md5/digest (string/repeat "a" 55)))
  (def expect3 "ef1772b6dff9a122358552954ad0df65")
  (is (== expect3 actual3))
  # Test at 56 bytes (forces length into second block)
  (def actual4 (md5/digest (string/repeat "a" 56)))
  (def expect4 "3b0c8ac703f828b04c6c197006d17218")
  (is (== expect4 actual4))
  # Test at 64 bytes (exactly one block)
  (def actual5 (md5/digest (string/repeat "a" 64)))
  (def expect5 "014842d480b571495a4a0363793f7367")
  (is (== expect5 actual5)))

(run-tests!)

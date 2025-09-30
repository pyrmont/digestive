(use ../deps/testament)

(import ../lib/sha2 :as sha2)

(deftest original
  # Test empty string
  (def actual1 (sha2/digest :384 ""))
  (def expect1 "38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (sha2/digest :384 "The quick brown fox jumps over the lazy dog"))
  (def expect2 "ca737f1014a48f4c0b6dd43cb177b0afd9e5169367544c494011e3317dbf9a509cb1e5dc1e85a941bbee3d7f2afbc9b1")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (sha2/digest :384 "The quick brown fox jumps over the lazy dog."))
  (def expect3 "ed892481d8272ca6df370bf706e4d7bc1b5739fa2177aae6c50e946678718fc67a7af2819a021c2fc34e91bdb63409d7")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (sha2/digest :384 "hello"))
  (def expect4 "59e1748777448c69de6b800d7a33bbfb9ff1b463e44354c3553bcdb9c666fa90125a3c79f90397bdf5f6a13de828684f")
  (is (== expect4 actual4)))

(deftest fips-180-2
  # Test empty string
  (def actual1 (sha2/digest :384 ""))
  (def expect1 "38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b")
  (is (== expect1 actual1))
  # Test "abc"
  (def actual2 (sha2/digest :384 "abc"))
  (def expect2 "cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7")
  (is (== expect2 actual2))
  # Test "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
  (def actual3 (sha2/digest :384 "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"))
  (def expect3 "3391fdddfc8dc7393707a65b1b4709397cf8b1d162af05abfe8f450de5f36bc6b0455a8520bc4e6f5fe95b1fe3c8452b")
  (is (== expect3 actual3)))

(deftest standard-vectors
  # Test "message digest"
  (def actual1 (sha2/digest :384 "message digest"))
  (def expect1 "473ed35167ec1f5d8e550368a3db39be54639f828868e9454c239fc8b52e3c61dbd0d8b4de1390c256dcbb5d5fd99cd5")
  (is (== expect1 actual1))
  # Test lowercase alphabet
  (def actual2 (sha2/digest :384 "abcdefghijklmnopqrstuvwxyz"))
  (def expect2 "feb67349df3db6f5924815d6c3dc133f091809213731fe5c7b5f4999e463479ff2877f5f2936fa63bb43784b12f3ebb4")
  (is (== expect2 actual2))
  # Test alphanumeric
  (def actual3 (sha2/digest :384 "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"))
  (def expect3 "1761336e3f7cbfe51deb137f026f89e01a448e3b1fafa64039c1464ee8732f11a5341a6f41e0c202294736ed64db1a84")
  (is (== expect3 actual3))
  # Test numbers
  (def actual4 (sha2/digest :384 "12345678901234567890123456789012345678901234567890123456789012345678901234567890"))
  (def expect4 "b12932b0627d1c060942f5447764155655bd4da0c9afa6dd9b9ef53129af1b8fb0195996d2de9ca0df9d821ffee67026")
  (is (== expect4 actual4)))

(deftest multi-block
  # Test string that requires multiple blocks (>128 bytes)
  (def input1 (string/repeat "a" 200))
  (def actual1 (sha2/digest :384 input1))
  (def expect1 "0691b6e978614b67d60557b2a2cddd53406508522efa21c624dbbfa8ab6e726d5c586b489c7c09f24109a64c10211d48")
  (is (== expect1 actual1))
  # Test file with 1500 bytes
  (def input2 (string/repeat "a" 1500))
  (def actual2 (sha2/digest :384 input2))
  (def expect2 "dad3a060218102ba2861b78596241969eaef0ed0acc18038c4533ce4a79047b21c1629de0be1de93bdeb9afbac86fad9")
  (is (== expect2 actual2)))

(deftest boundary-cases
  # Test single character
  (def actual1 (sha2/digest :384 "a"))
  (def expect1 "54a59b9f22b0b80880d8427e548b7c23abd873486e1f035dce9cd697e85175033caa88e6d57bc35efae0b5afd3145f31")
  (is (== expect1 actual1))
  # Test single byte
  (def actual2 (sha2/digest :384 "\x00"))
  (def expect2 "bec021b4f368e3069134e012c2b4307083d3a9bdd206e24e5f0d86e13d6636655933ec2b413465966817a9c208a11717")
  (is (== expect2 actual2))
  # Test at 55 bytes (one byte before padding in first block)
  (def input3 (string/repeat "a" 111))
  (def actual3 (sha2/digest :384 input3))
  (def expect3 "3c37955051cb5c3026f94d551d5b5e2ac38d572ae4e07172085fed81f8466b8f90dc23a8ffcdea0b8d8e58e8fdacc80a")
  (is (== expect3 actual3))
  # Test at 56 bytes (forces length into second block)
  (def input4 (string/repeat "a" 112))
  (def actual4 (sha2/digest :384 input4))
  (def expect4 "187d4e07cb306103c69967bf544d0dfbe9042577599c73c330abc0cb64c61236d5ed565ee19119d8c31779a38f791fcd")
  (is (== expect4 actual4))
  # Test at 64 bytes (exactly one block)
  (def input5 (string/repeat "a" 128))
  (def actual5 (sha2/digest :384 input5))
  (def expect5 "edb12730a366098b3b2beac75a3bef1b0969b15c48e2163c23d96994f8d1bef760c7e27f3c464d3829f56c0d53808b0b")
  (is (== expect5 actual5)))

(run-tests!)

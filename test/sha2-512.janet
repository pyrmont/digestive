(use ../deps/testament)

(import ../lib/sha2-512 :as sha2-512)

(deftest digest
  # Test empty string
  (def actual1 (sha2-512/digest ""))
  (def expect1 "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (sha2-512/digest "The quick brown fox jumps over the lazy dog"))
  (def expect2 "07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (sha2-512/digest "The quick brown fox jumps over the lazy dog."))
  (def expect3 "91ea1245f20d46ae9a037a989f54f1f790f0a47607eeb8a14d12890cea77a1bbc6c7ed9cf205e67b7f2b8fd4c7dfd3a7a8617e45f3c463d481c7e586c39ac1ed")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (sha2-512/digest "hello"))
  (def expect4 "9b71d224bd62f3785d96d46ad3ea3d73319bfbc2890caadae2dff72519673ca72323c3d99ba5c11d7c7acc6e14b8c5da0c4663475c2e5c3adef46f73bcdec043")
  (is (== expect4 actual4)))

(run-tests!)

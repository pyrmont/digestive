(use ../deps/testament)

(import ../lib/sha2-512 :as sha2-512)

(deftest original
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

(deftest fips-180-2
  # Test empty string
  (def actual1 (sha2-512/digest ""))
  (def expect1 "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e")
  (is (== expect1 actual1))
  # Test "abc"
  (def actual2 (sha2-512/digest "abc"))
  (def expect2 "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f")
  (is (== expect2 actual2))
  # Test "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
  (def actual3 (sha2-512/digest "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"))
  (def expect3 "204a8fc6dda82f0a0ced7beb8e08a41657c16ef468b228a8279be331a703c33596fd15c13b1b07f9aa1d3bea57789ca031ad85c7a71dd70354ec631238ca3445")
  (is (== expect3 actual3)))

(deftest standard-vectors
  # Test "message digest"
  (def actual1 (sha2-512/digest "message digest"))
  (def expect1 "107dbf389d9e9f71a3a95f6c055b9251bc5268c2be16d6c13492ea45b0199f3309e16455ab1e96118e8a905d5597b72038ddb372a89826046de66687bb420e7c")
  (is (== expect1 actual1))
  # Test lowercase alphabet
  (def actual2 (sha2-512/digest "abcdefghijklmnopqrstuvwxyz"))
  (def expect2 "4dbff86cc2ca1bae1e16468a05cb9881c97f1753bce3619034898faa1aabe429955a1bf8ec483d7421fe3c1646613a59ed5441fb0f321389f77f48a879c7b1f1")
  (is (== expect2 actual2))
  # Test alphanumeric
  (def actual3 (sha2-512/digest "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"))
  (def expect3 "1e07be23c26a86ea37ea810c8ec7809352515a970e9253c26f536cfc7a9996c45c8370583e0a78fa4a90041d71a4ceab7423f19c71b9d5a3e01249f0bebd5894")
  (is (== expect3 actual3))
  # Test numbers
  (def actual4 (sha2-512/digest "12345678901234567890123456789012345678901234567890123456789012345678901234567890"))
  (def expect4 "72ec1ef1124a45b047e8b7c75a932195135bb61de24ec0d1914042246e0aec3a2354e093d76f3048b456764346900cb130d2a4fd5dd16abb5e30bcb850dee843")
  (is (== expect4 actual4)))

(deftest multi-block
  # Test string that requires multiple blocks (>128 bytes)
  (def input1 (string/repeat "a" 200))
  (def actual1 (sha2-512/digest input1))
  (def expect1 "4b11459c33f52a22ee8236782714c150a3b2c60994e9acee17fe68947a3e6789f31e7668394592da7bef827cddca88c4e6f86e4df7ed1ae6cba71f3e98faee9f")
  (is (== expect1 actual1))
  # Test file with 1500 bytes
  (def input2 (string/repeat "a" 1500))
  (def actual2 (sha2-512/digest input2))
  (def expect2 "e0bbf0f9d8ad7353e6991891eab5738f5fd6c3d6d8dc07b6dfba6b6da526844601e146f52a04a8d1164e4c65588396724a6feaf021a1ee81237986fc8f20bed3")
  (is (== expect2 actual2)))

(deftest boundary-cases
  # Test single character
  (def actual1 (sha2-512/digest "a"))
  (def expect1 "1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f5302860c652bf08d560252aa5e74210546f369fbbbce8c12cfc7957b2652fe9a75")
  (is (== expect1 actual1))
  # Test single byte
  (def actual2 (sha2-512/digest "\x00"))
  (def expect2 "b8244d028981d693af7b456af8efa4cad63d282e19ff14942c246e50d9351d22704a802a71c3580b6370de4ceb293c324a8423342557d4e5c38438f0e36910ee")
  (is (== expect2 actual2))
  # Test at 111 bytes (one byte before padding in first block)
  (def input3 (string/repeat "a" 111))
  (def actual3 (sha2-512/digest input3))
  (def expect3 "fa9121c7b32b9e01733d034cfc78cbf67f926c7ed83e82200ef86818196921760b4beff48404df811b953828274461673c68d04e297b0eb7b2b4d60fc6b566a2")
  (is (== expect3 actual3))
  # Test at 112 bytes (forces length into second block)
  (def input4 (string/repeat "a" 112))
  (def actual4 (sha2-512/digest input4))
  (def expect4 "c01d080efd492776a1c43bd23dd99d0a2e626d481e16782e75d54c2503b5dc32bd05f0f1ba33e568b88fd2d970929b719ecbb152f58f130a407c8830604b70ca")
  (is (= 128 (length actual4)))
  # Test at 128 bytes (exactly one block)
  (def input5 (string/repeat "a" 128))
  (def actual5 (sha2-512/digest input5))
  (def expect5 "b73d1929aa615934e61a871596b3f3b33359f42b8175602e89f7e06e5f658a243667807ed300314b95cacdd579f3e33abdfbe351909519a846d465c59582f321")
  (is (= 128 (length actual5))))

(run-tests!)

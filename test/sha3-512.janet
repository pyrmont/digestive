(use ../deps/testament)

(import ../lib/sha3-512 :as sha3-512)

(deftest original
  # Test empty string
  (def actual1 (sha3-512/digest ""))
  (def expect1 "a69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (sha3-512/digest "The quick brown fox jumps over the lazy dog"))
  (def expect2 "01dedd5de4ef14642445ba5f5b97c15e47b9ad931326e4b0727cd94cefc44fff23f07bf543139939b49128caf436dc1bdee54fcb24023a08d9403f9b4bf0d450")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (sha3-512/digest "The quick brown fox jumps over the lazy dog."))
  (def expect3 "18f4f4bd419603f95538837003d9d254c26c23765565162247483f65c50303597bc9ce4d289f21d1c2f1f458828e33dc442100331b35e7eb031b5d38ba6460f8")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (sha3-512/digest "hello"))
  (def expect4 "75d527c368f2efe848ecf6b073a36767800805e9eef2b1857d5f984f036eb6df891d75f72d9b154518c1cd58835286d1da9a38deba3de98b5a53e5ed78a84976")
  (is (== expect4 actual4)))

(deftest nist-vectors
  # Test empty string
  (def actual1 (sha3-512/digest ""))
  (def expect1 "a69f73cca23a9ac5c8b567dc185a756e97c982164fe25859e0d1dcc1475c80a615b2123af1f5f94c11e3e9402c3ac558f500199d95b6d3e301758586281dcd26")
  (is (== expect1 actual1))
  # Test "abc"
  (def actual2 (sha3-512/digest "abc"))
  (def expect2 "b751850b1a57168a5693cd924b6b096e08f621827444f70d884f5d0240d2712e10e116e9192af3c91a7ec57647e3934057340b4cf408d5a56592f8274eec53f0")
  (is (== expect2 actual2))
  # Test longer test vector
  (def actual3 (sha3-512/digest "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu"))
  (def expect3 "afebb2ef542e6579c50cad06d2e578f9f8dd6881d7dc824d26360feebf18a4fa73e3261122948efcfd492e74e82e2189ed0fb440d187f382270cb455f21dd185")
  (is (== expect3 actual3)))

(deftest standard-vectors
  # Test "keccak"
  (def actual1 (sha3-512/digest "keccak"))
  (def expect1 "b02c86976d3ceed98ca1fc81aee2e6862440dad3110633044cfcfabea27160cdf58a355e2fc364b109968c5b01e4bf20f8f61b8983e38f39e73248af6dbebc5d")
  (is (== expect1 actual1))
  # Test "SHA-3"
  (def actual2 (sha3-512/digest "SHA-3"))
  (def expect2 "bfed1572ccb87f8632ee6d5b9bde69034e12bcfea2852a118150c28007aba176483f50acb0a9c610d2bb91bbf710641a08bade3d4cabf51fb1655d041f2a291e")
  (is (== expect2 actual2))
  # Test lowercase alphabet
  (def actual3 (sha3-512/digest "abcdefghijklmnopqrstuvwxyz"))
  (def expect3 "af328d17fa28753a3c9f5cb72e376b90440b96f0289e5703b729324a975ab384eda565fc92aaded143669900d761861687acdc0a5ffa358bd0571aaad80aca68")
  (is (== expect3 actual3))
  # Test alphanumeric
  (def actual4 (sha3-512/digest "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"))
  (def expect4 "d1db17b4745b255e5eb159f66593cc9c143850979fc7a3951796aba80165aab536b46174ce19e3f707f0e5c6487f5f03084bc0ec9461691ef20113e42ad28163")
  (is (== expect4 actual4))
  # Test numbers
  (def actual5 (sha3-512/digest "12345678901234567890123456789012345678901234567890123456789012345678901234567890"))
  (def expect5 "9524b9a5536b91069526b4f6196b7e9475b4da69e01f0c855797f224cd7335ddb286fd99b9b32ffe33b59ad424cc1744f6eb59137f5fb8601932e8a8af0ae930")
  (is (== expect5 actual5)))

(deftest multi-block
  # Test string that requires multiple blocks (>72 bytes for SHA3-512)
  (def input1 (string/repeat "a" 100))
  (def actual1 (sha3-512/digest input1))
  (def expect1 "b47924f5e11cda9c1ecf7e5364a77f68827efa9932870ee0781ccf9a48f733dffc5c4d67029c8f024a4a44de5dfa0f273c03938f74feb13e5e99aa7d6b991824")
  (is (== expect1 actual1))
  # Test file with 1200 bytes
  (def input2 (string/repeat "a" 1200))
  (def actual2 (sha3-512/digest input2))
  (def expect2 "e6f7185d8b680975c19acbad9a0b8718eb968304fff4f4944199222948c74d55e97c6aac1e9bb25c9d03212951a24eb6ede7ca6b19ac8b2ebdf71b763450338c")
  (is (== expect2 actual2)))

(deftest boundary-cases
  # Test single character
  (def actual1 (sha3-512/digest "a"))
  (def expect1 "697f2d856172cb8309d6b8b97dac4de344b549d4dee61edfb4962d8698b7fa803f4f93ff24393586e28b5b957ac3d1d369420ce53332712f997bd336d09ab02a")
  (is (== expect1 actual1))
  # Test single byte
  (def actual2 (sha3-512/digest "\x00"))
  (def expect2 "7127aab211f82a18d06cf7578ff49d5089017944139aa60d8bee057811a15fb55a53887600a3eceba004de51105139f32506fe5b53e1913bfa6b32e716fe97da")
  (is (== expect2 actual2))
  # Test at 71 bytes (one byte before rate boundary for SHA3-512)
  (def input3 (string/repeat "a" 71))
  (def actual3 (sha3-512/digest input3))
  (def expect3 "070faf98d2a8fddf8ed886408744dc06456096c2e045f26f3c7b010530e6bbb3db535a54d636856f4e0e1e982461cb9a7e8e57ff8895cff1619af9f0e486e28c")
  (is (== expect3 actual3))
  # Test at 72 bytes (exactly one rate)
  (def input4 (string/repeat "a" 72))
  (def actual4 (sha3-512/digest input4))
  (def expect4 "a8ae722a78e10cbbc413886c02eb5b369a03f6560084aff566bd597bb7ad8c1ccd86e81296852359bf2faddb5153c0a7445722987875e74287adac21adebe952")
  (is (== expect4 actual4))
  # Test at 73 bytes (one byte over rate boundary)
  (def input5 (string/repeat "a" 73))
  (def actual5 (sha3-512/digest input5))
  (def expect5 "23e6a8815f8201dbbf6a5463be8dcadb1acea9df5f8998954e59ac9565cf6d29b17aa27a5e8b0fc06343db6122d6e544d27583ddc78504d08203217e7e65b6bd")
  (is (== expect5 actual5))
  # Test at 144 bytes (exactly two rates)
  (def input6 (string/repeat "a" 144))
  (def actual6 (sha3-512/digest input6))
  (def expect6 "446cd4d7ba19510dcc776b21045bc68d424b5b840e14685e149bb238b5f473c0356b69e04f0f5785eefce20ff09e678b080d8aac64568c5edf001cd32b2ed7a8")
  (is (== expect6 actual6)))

(run-tests!)

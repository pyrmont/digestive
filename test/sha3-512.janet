(use ../deps/testament)

(import ../lib/sha3-512 :as sha3-512)

(deftest digest
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

(run-tests!)

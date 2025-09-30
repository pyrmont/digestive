(use ../deps/testament)

(import ../lib/sha3-256 :as sha3-256)

(deftest original
  # Test empty string
  (def actual1 (sha3-256/digest ""))
  (def expect1 "a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a")
  (is (== expect1 actual1))
  # Test "The quick brown fox jumps over the lazy dog"
  (def actual2 (sha3-256/digest "The quick brown fox jumps over the lazy dog"))
  (def expect2 "69070dda01975c8c120c3aada1b282394e7f032fa9cf32f4cb2259a0897dfc04")
  (is (== expect2 actual2))
  # Test "The quick brown fox jumps over the lazy dog."
  (def actual3 (sha3-256/digest "The quick brown fox jumps over the lazy dog."))
  (def expect3 "a80f839cd4f83f6c3dafc87feae470045e4eb0d366397d5c6ce34ba1739f734d")
  (is (== expect3 actual3))
  # Test "hello"
  (def actual4 (sha3-256/digest "hello"))
  (def expect4 "3338be694f50c5f338814986cdf0686453a888b84f424d792af4b9202398f392")
  (is (== expect4 actual4)))

(deftest nist-vectors
  # Test empty string
  (def actual1 (sha3-256/digest ""))
  (def expect1 "a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a")
  (is (== expect1 actual1))
  # Test "abc"
  (def actual2 (sha3-256/digest "abc"))
  (def expect2 "3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532")
  (is (== expect2 actual2))
  # Test longer test vector
  (def actual3 (sha3-256/digest "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu"))
  (def expect3 "916f6061fe879741ca6469b43971dfdb28b1a32dc36cb3254e812be27aad1d18")
  (is (== expect3 actual3)))

(deftest standard-vectors
  # Test "keccak"
  (def actual1 (sha3-256/digest "keccak"))
  (def expect1 "0973dfe900f9e4b4dbd86d71f68cb842545d9738b81dfbdded40a7ca5426994e")
  (is (== expect1 actual1))
  # Test "SHA-3"
  (def actual2 (sha3-256/digest "SHA-3"))
  (def expect2 "c97020d0ac70548080ad0d1601d263c48f98a2f348cc07bdc0750e5a38d89076")
  (is (== expect2 actual2))
  # Test lowercase alphabet
  (def actual3 (sha3-256/digest "abcdefghijklmnopqrstuvwxyz"))
  (def expect3 "7cab2dc765e21b241dbc1c255ce620b29f527c6d5e7f5f843e56288f0d707521")
  (is (== expect3 actual3))
  # Test alphanumeric
  (def actual4 (sha3-256/digest "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"))
  (def expect4 "a79d6a9da47f04a3b9a9323ec9991f2105d4c78a7bc7beeb103855a7a11dfb9f")
  (is (== expect4 actual4))
  # Test numbers
  (def actual5 (sha3-256/digest "12345678901234567890123456789012345678901234567890123456789012345678901234567890"))
  (def expect5 "293e5ce4ce54ee71990ab06e511b7ccd62722b1beb414f5ff65c8274e0f5be1d")
  (is (== expect5 actual5)))

(deftest multi-block
  # Test string that requires multiple blocks (>136 bytes for SHA3-256)
  (def input1 (string/repeat "a" 200))
  (def actual1 (sha3-256/digest input1))
  (def expect1 "cce34485baf2bf2aca99b94833892a4f52896d3d153f7b840cc4f9fe695f1387")
  (is (== expect1 actual1))
  # Test file with 2200 bytes
  (def input2 (string/repeat "a" 2200))
  (def actual2 (sha3-256/digest input2))
  (def expect2 "269f06ed8b76388032894880ec1858a8f5ec2720f459517e2c916ebae9b4a707")
  (is (== expect2 actual2)))

(deftest boundary-cases
  # Test single character
  (def actual1 (sha3-256/digest "a"))
  (def expect1 "80084bf2fba02475726feb2cab2d8215eab14bc6bdd8bfb2c8151257032ecd8b")
  (is (== expect1 actual1))
  # Test single byte
  (def actual2 (sha3-256/digest "\x00"))
  (def expect2 "5d53469f20fef4f8eab52b88044ede69c77a6a68a60728609fc4a65ff531e7d0")
  (is (== expect2 actual2))
  # Test at 135 bytes (one byte before rate boundary for SHA3-256)
  (def input3 (string/repeat "a" 135))
  (def actual3 (sha3-256/digest input3))
  (def expect3 "8094bb53c44cfb1e67b7c30447f9a1c33696d2463ecc1d9c92538913392843c9")
  (is (== expect3 actual3))
  # Test at 136 bytes (exactly one rate)
  (def input4 (string/repeat "a" 136))
  (def actual4 (sha3-256/digest input4))
  (def expect4 "3fc5559f14db8e453a0a3091edbd2bc25e11528d81c66fa570a4efdcc2695ee1")
  (is (== expect4 actual4))
  # Test at 137 bytes (one byte over rate boundary)
  (def input5 (string/repeat "a" 137))
  (def actual5 (sha3-256/digest input5))
  (def expect5 "f8d6846cedd2ccfadf15c5879ef95af724d799eed7391fb1c91f95344e738614")
  (is (== expect5 actual5))
  # Test at 272 bytes (exactly two rates)
  (def input6 (string/repeat "a" 272))
  (def actual6 (sha3-256/digest input6))
  (def expect6 "a490357b9b3fb39d0a89a117734e5b020b1f33c7bf3fa3575c396425432003d3")
  (is (== expect6 actual6)))

(run-tests!)

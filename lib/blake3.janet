(import ./bitops :as ops)

# Helpers

# 32-bit values as buffers
(def- b0 (buffer/new-filled 4))
(def- b1 (buffer/push-word @"" 1))

# Same as SHA2-256's initial hash values
(def- init-value
      [0x6A09E667 0xBB67AE85 0x3C6EF372 0xA54FF53A
       0x510E527F 0x9B05688C 0x1F83D9AB 0x5BE0CD19])

# Message permutation (reorders message words between rounds)
(def- perms [2 6 3 10 7 0 4 13 1 11 12 5 9 14 15 8])

# Domain separation flags
(def- fl-cbegin 1)
(def- fl-cend 2)
(def- fl-parent 4)
(def- fl-root 8)
(def- fl-khash 16)
(def- fl-dkc 32)
(def- fl-dkm 64)

# Block and chunk sizes
(def- block-len 64)
(def- chunk-len 1024)

# Add multiple values together and get first 4 bytes (32-bit word)
(defn- add [& xs]
  (def total (ops/badd ;xs))
  (if (<= (length total) 4)
    total
    (buffer/slice total 0 4)))

# Get a 32-bit word from a buffer at word index i
(defn- get-word [b i]
  (def begin (* i 4))
  (if (>= begin (length b))
    (buffer/new-filled 4)
    (do
      (def end (min (+ begin 4) (length b)))
      (def res (buffer/slice b begin end))
      # Pad with zeros if needed
      (while (< (length res) 4)
        (buffer/push res 0))
      res)))

# Set a 32-bit word in a buffer at word index i
(defn- set-word [b i word]
  (buffer/push-at b (* i 4) word))

# Core BLAKE3 Operations

# G function: the mixing function that operates on 4 words of the state
# state: 16-word (64-byte) buffer
# a, b, c, d: indices into the state (0-15)
# mx, my: two message words (4 bytes each)
(defn- g [state a b c d mx my]
  (set-word state a (add (get-word state a) (get-word state b) mx))
  (set-word state d (ops/brrot (ops/bxor (get-word state d) (get-word state a)) 16))
  (set-word state c (add (get-word state c) (get-word state d)))
  (set-word state b (ops/brrot (ops/bxor (get-word state b) (get-word state c)) 12))
  (set-word state a (add (get-word state a) (get-word state b) my))
  (set-word state d (ops/brrot (ops/bxor (get-word state d) (get-word state a)) 8))
  (set-word state c (add (get-word state c) (get-word state d)))
  (set-word state b (ops/brrot (ops/bxor (get-word state b) (get-word state c)) 7))
  state)

# Round function: performs one round of mixing (calls G 8 times)
# state: 16-word buffer
# msg: 16-word message buffer
(defn- round [state msg]
  # Mix columns
  (g state 0 4 8 12 (get-word msg 0) (get-word msg 1))
  (g state 1 5 9 13 (get-word msg 2) (get-word msg 3))
  (g state 2 6 10 14 (get-word msg 4) (get-word msg 5))
  (g state 3 7 11 15 (get-word msg 6) (get-word msg 7))
  # Mix diagonals
  (g state 0 5 10 15 (get-word msg 8) (get-word msg 9))
  (g state 1 6 11 12 (get-word msg 10) (get-word msg 11))
  (g state 2 7 8 13 (get-word msg 12) (get-word msg 13))
  (g state 3 4 9 14 (get-word msg 14) (get-word msg 15))
  state)

# Permute message words according to perms
(defn- permute [msg]
  (def res (buffer/new-filled 64))
  (for i 0 16
    (def perm-idx (get perms i))
    (set-word res i (get-word msg perm-idx)))
  res)

# Compression function: the core of BLAKE3
# cv: chaining value (8 words = 32 bytes)
# block: message block (16 words = 64 bytes)
# counter: chunk counter (as buffer)
# block-len: length of the block in bytes
# flags: domain separation flags
(defn- compress [cv block counter block-len flags]
  # Initialize state with chaining value, init-value, counter, block-len, and flags
  (def state (buffer/new-filled 64))
  # First 8 words: chaining value
  (for i 0 8
    (set-word state i (get-word cv i)))
  # Next 4 words: first 4 words of init-value
  (for i 0 4
    (set-word state (+ i 8) (buffer/push-word @"" (get init-value i))))
  # Word 12: counter (low 32 bits)
  (set-word state 12 counter)
  # Word 14: block length
  (set-word state 14 (buffer/push-word @"" block-len))
  # Word 15: flags
  (set-word state 15 (buffer/push-word @"" flags))
  # Perform 7 rounds
  (var msg block)
  (for i 0 7
    (round state msg)
    (set msg (permute msg)))
  # XOR the two halves of state together to produce output
  (for i 0 8
    (set-word state i (ops/bxor (get-word state i) (get-word state (+ i 8)))))
  state)

# Output Structure
# Represents the state needed to extract output bytes
(defn- new-output [cv block counter block-len flags]
  @{:cv cv
    :block block
    :counter counter
    :block-len block-len
    :flags flags})

# Get chaining value from output (first 32 bytes)
(defn- output-chaining-value [output]
  (def compressed (compress (output :cv)
                            (output :block)
                            (output :counter)
                            (output :block-len)
                            (output :flags)))
  (buffer/slice compressed 0 32))

# Extract root output bytes from output
(defn- output-root-bytes [output out-len]
  (def result @"")
  (var output-block-counter 0)
  (while (< (length result) out-len)
    (def words (compress (output :cv)
                         (output :block)
                         (buffer/push-word @"" output-block-counter)
                         (output :block-len)
                         (bor (output :flags) fl-root)))
    (def end (min (- out-len (length result)) 64))
    (buffer/push-string result (buffer/slice words 0 end))
    (++ output-block-counter))
  (buffer/slice result 0 out-len))

# Chunk State Management

# Create a new chunk state
# key: 8-word chaining value (32 bytes), starts with init-value
# chunk-counter: which chunk this is (0 for first chunk)
# flags: persistent flags to apply to all compressions
(defn- new-chunk-state [key chunk-counter flags]
  @{:cv key
    :chunk-counter chunk-counter
    :block @""
    :block-len 0
    :blocks-compressed 0
    :flags flags})

# Get the length of data in the chunk so far
(defn- chunk-len-so-far [chunk-state]
  (+ (* (chunk-state :blocks-compressed) block-len)
     (chunk-state :block-len)))

# Get start flag if this is the first block
(defn- chunk-start-flag [chunk-state]
  (if (zero? (chunk-state :blocks-compressed)) fl-cbegin 0))

# Update chunk state with input data
# Note: This does NOT finalize the chunk, even if it reaches chunk-len
(defn- chunk-update [chunk-state input]
  (var offset 0)
  (def input-len (length input))
  (while (< offset input-len)
    # If block buffer is full, compress it (without CHUNK_END flag)
    (when (= (chunk-state :block-len) block-len)
      (def flags (bor (chunk-state :flags) (chunk-start-flag chunk-state)))
      (def new-cv (compress (chunk-state :cv)
                            (chunk-state :block)
                            (chunk-state :chunk-counter)
                            block-len
                            flags))
      (put chunk-state :cv (buffer/slice new-cv 0 32))
      (put chunk-state :blocks-compressed (+ (chunk-state :blocks-compressed) 1))
      (buffer/clear (chunk-state :block))
      (put chunk-state :block-len 0))
    # Copy input bytes into block buffer
    (def taken (min (- block-len (chunk-state :block-len)) (- input-len offset)))
    (buffer/push-string (chunk-state :block)
                        (buffer/slice input offset (+ offset taken)))
    (put chunk-state :block-len (+ (chunk-state :block-len) taken))
    (+= offset taken))
  chunk-state)

# Finalize a chunk and return an Output
(defn- chunk-output [chunk-state]
  # Pad block with zeros to 64 bytes
  (def block-copy (buffer/slice (chunk-state :block)))
  (while (< (length block-copy) block-len)
    (buffer/push block-copy 0))
  (new-output (chunk-state :cv)
              block-copy
              (chunk-state :chunk-counter)
              (chunk-state :block-len)
              (bor (chunk-state :flags) (chunk-start-flag chunk-state) fl-cend)))

# Parent Node Operations

# Create a parent output by combining two child chaining values
# left-cv: left child chaining value (32 bytes)
# right-cv: right child chaining value (32 bytes)
# key: the original key/init-value
# flags: persistent domain flags
(defn- parent-output [left-cv right-cv key flags]
  # Parent block is left child || right child (64 bytes total)
  (def block @"")
  (buffer/push-string block (buffer/slice left-cv 0 32))
  (buffer/push-string block (buffer/slice right-cv 0 32))
  (new-output key block b0 block-len (bor fl-parent flags)))

# Hasher with Tree Logic

# Initialize hasher with optional flags
(defn- init-hasher [&opt flags]
  (default flags 0)
  (def key (buffer/new-filled 32))
  (for i 0 8
    (set-word key i (buffer/push-word @"" (get init-value i))))
  @{:key key
    :chunk-state (new-chunk-state key b0 flags)
    :cv-stack @[]  # Stack of chaining values for tree
    :flags flags})

# Add a chunk's chaining value to the tree
(defn- add-chunk-cv [hasher cv total-chunks]
  (var new-cv cv)
  (var chunks total-chunks)
  # Merge with existing subtrees while total-chunks is even
  (while (and (> (length (hasher :cv-stack)) 0)
              (not (buffer/bit chunks 0)))
    (set chunks (ops/brushift chunks 1))
    (def left-cv (array/pop (hasher :cv-stack)))
    (def parent-out (parent-output left-cv new-cv (hasher :key) (hasher :flags)))
    (set new-cv (output-chaining-value parent-out)))
  # Push the (possibly merged) CV onto the stack
  (array/push (hasher :cv-stack) new-cv))

# Update hasher with input data
(defn- hasher-update [hasher input]
  (var offset 0)
  (def input-len (length input))
  (while (< offset input-len)
    # If current chunk is complete, finalize it and start a new one
    (when (>= (chunk-len-so-far (hasher :chunk-state)) chunk-len)
      (def chunk-out (chunk-output (hasher :chunk-state)))
      (def cv (output-chaining-value chunk-out))
      (def total-chunks (ops/badd ((hasher :chunk-state) :chunk-counter) b1))
      (add-chunk-cv hasher cv total-chunks)
      (put hasher :chunk-state (new-chunk-state (hasher :key)
                                                total-chunks
                                                (hasher :flags))))
    # Compress input bytes into current chunk
    (def chunk-space (- chunk-len (chunk-len-so-far (hasher :chunk-state))))
    (def taken (min chunk-space (- input-len offset)))
    (chunk-update (hasher :chunk-state) (buffer/slice input offset (+ offset taken)))
    (+= offset taken))
  hasher)

# Finalize hasher and produce output
(defn- hasher-finalize [hasher out-len]
  # Get output from current chunk
  (var output (chunk-output (hasher :chunk-state)))
  # If there are no parent nodes, this chunk is the root
  (if (zero? (length (hasher :cv-stack)))
    # Single chunk case: extract root output directly
    (output-root-bytes output out-len)
    # Multi-chunk case: merge up the tree
    (do
      # Keep merging with parent nodes from the stack
      (var parent-nodes-remaining (length (hasher :cv-stack)))
      (while (> parent-nodes-remaining 0)
        (-- parent-nodes-remaining)
        (def left-cv (get (hasher :cv-stack) parent-nodes-remaining))
        (def right-cv (output-chaining-value output))
        (set output (parent-output left-cv right-cv (hasher :key) (hasher :flags))))
      # Extract root output bytes
      (output-root-bytes output out-len))))

(defn digest-256
  ```
  Calculates a 256-bit digest of `input` using the BLAKE3 algorithm
  ```
  [input]
  (def hasher (init-hasher))
  (hasher-update hasher input)
  (-> (hasher-finalize hasher 32)
      (ops/bstring)))

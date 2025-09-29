(import ./bitops :as ops)

# SHA-3/Keccak constants

# Round constants (Table 1 of specification)
(def- RC [
  (ops/bjoin 0x00000000 0x00000001)  #  RC[0]: 0x0000000000000001
  (ops/bjoin 0x00000000 0x00008082)  #  RC[1]: 0x0000000000008082
  (ops/bjoin 0x80000000 0x0000808a)  #  RC[2]: 0x800000000000808a
  (ops/bjoin 0x80000000 0x80008000)  #  RC[3]: 0x8000000080008000
  (ops/bjoin 0x00000000 0x0000808b)  #  RC[4]: 0x000000000000808b
  (ops/bjoin 0x00000000 0x80000001)  #  RC[5]: 0x0000000080000001
  (ops/bjoin 0x80000000 0x80008081)  #  RC[6]: 0x8000000080008081
  (ops/bjoin 0x80000000 0x00008009)  #  RC[7]: 0x8000000000008009
  (ops/bjoin 0x00000000 0x0000008a)  #  RC[8]: 0x000000000000008a
  (ops/bjoin 0x00000000 0x00000088)  #  RC[9]: 0x0000000000000088
  (ops/bjoin 0x00000000 0x80008009)  # RC[10]: 0x0000000080008009
  (ops/bjoin 0x00000000 0x8000000a)  # RC[11]: 0x000000008000000a
  (ops/bjoin 0x00000000 0x8000808b)  # RC[12]: 0x000000008000808b
  (ops/bjoin 0x80000000 0x0000008b)  # RC[13]: 0x800000000000008b
  (ops/bjoin 0x80000000 0x00008089)  # RC[14]: 0x8000000000008089
  (ops/bjoin 0x80000000 0x00008003)  # RC[15]: 0x8000000000008003
  (ops/bjoin 0x80000000 0x00008002)  # RC[16]: 0x8000000000008002
  (ops/bjoin 0x80000000 0x00000080)  # RC[17]: 0x8000000000000080
  (ops/bjoin 0x00000000 0x0000800a)  # RC[18]: 0x000000000000800a
  (ops/bjoin 0x80000000 0x8000000a)  # RC[19]: 0x800000008000000a
  (ops/bjoin 0x80000000 0x80008081)  # RC[20]: 0x8000000080008081
  (ops/bjoin 0x80000000 0x00008080)  # RC[21]: 0x8000000000008080
  (ops/bjoin 0x00000000 0x80000001)  # RC[22]: 0x0000000080000001
  (ops/bjoin 0x80000000 0x80008008)  # RC[23]: 0x8000000080008008
])

# Rotation offsets r[x,y] (Table 2 of specification)
(def- rho [
  [ 0  1 62 28 27]  # y=0
  [36 44  6 55 20]  # y=1
  [ 3 10 43 25 39]  # y=2
  [41 45 15 21  8]  # y=3
  [18  2 61 56 14]  # y=4
])

# SHA3-256 auxiliary functions

(defn- get-lane
  [state x y]
  (def idx (+ (* y 5) x))
  (ops/bword64 state idx))

(defn- set-lane
  [state x y lane]
  (def idx (+ (* y 5) x))
  (def start (* idx 8))
  (for i 0 8
    (put state (+ start i) (get lane i))))

# θ (theta) step: C[x] = A[x,0] ⊕ ... ⊕ A[x,4], D[x] = C[x-1] ⊕ rot(C[x+1],1)
(defn- theta-step
  [A]
  # Calculate column parities C[x]
  (def C @[])
  (for x 0 5
    (var col (get-lane A x 0))
    (for y 1 5
      (set col (ops/bxor col (get-lane A x y))))
    (array/push C col))
  # Calculate D[x] = C[x-1] ⊕ rot(C[x+1], 1)
  (def D @[])
  (for x 0 5
    (def c-prev (C (% (+ x 4) 5)))  # C[x-1] with wraparound
    (def c-next-rot (ops/blrot (C (% (+ x 1) 5)) 1))  # rot(C[x+1], 1)
    (array/push D (ops/bxor c-prev c-next-rot)))
  # Apply D to all lanes: A[x,y] = A[x,y] ⊕ D[x]
  (for y 0 5
    (for x 0 5
      (def current (get-lane A x y))
      (set-lane A x y (ops/bxor current (D x)))))
  A)

# ρ and π steps: B[y,2*x+3*y] = rot(A[x,y], r[x,y])
(defn- rho-pi-step
  [A]
  (def B (buffer/new-filled 200))
  (for y 0 5
    (for x 0 5
      (def lane (get-lane A x y))
      (def rotation ((rho y) x))
      (def rotated-lane (ops/blrot lane rotation))
      # π step: new position is [y, (2*x + 3*y) mod 5]
      (def new-x y)
      (def new-y (% (+ (* 2 x) (* 3 y)) 5))
      (set-lane B new-x new-y rotated-lane)))
  B)

# χ step: A[x,y] = B[x,y] ⊕ ((¬B[x+1,y]) ∧ B[x+2,y])
(defn- chi-step
  [B]
  (def A (buffer/new-filled 200))
  (for y 0 5
    (for x 0 5
      (def b-xy (get-lane B x y))
      (def b-x1y (get-lane B (% (+ x 1) 5) y))
      (def b-x2y (get-lane B (% (+ x 2) 5) y))
      (def not-b-x1y (ops/bnot b-x1y))
      (def and-result (ops/band not-b-x1y b-x2y))
      (def result (ops/bxor b-xy and-result))
      (set-lane A x y result)))
  A)

# ι step: A[0,0] = A[0,0] ⊕ RC[i]
(defn- iota-step
  [A round]
  (def rc (RC round))
  (def lane-00 (get-lane A 0 0))
  (set-lane A 0 0 (ops/bxor lane-00 rc))
  A)

# Keccak-f[1600] permutation (24 rounds)
(defn- keccak-f
  [initial]
  (var state initial)
  (for round 0 24
    (set state (theta-step state))
    (set state (rho-pi-step state))
    (set state (chi-step state))
    (set state (iota-step state round)))
  state)

# Keccak padding: M || d || 00...00 || 10000000 where d=0x06 for SHA3
(defn- keccak-pad
  [M rate]
  # Add domain separation suffix d=0x06 for SHA-3
  (buffer/push M 0x06)
  # Calculate padding length
  (def len (length M))
  (def pad-len (% (- rate len) rate))
  # Add zeros
  (for i 0 (- pad-len 1)
    (buffer/push M 0x00))
  # Add final 0x80 byte (sets high bit)
  (buffer/push M 0x80)
  M)

(defn digest
  ```
  Calculates a digest of `input` using the SHA3-256 algorithm
  ```
  [input]
  # SHA-3-256 parameters
  (def rate 136) # r = 1088 bits / 8 = 136 bytes
  (def output-len 32) # 256 bits / 8 = 32 bytes
  # Initialize state S[x,y] = 0 for all (x,y)
  (var S (buffer/new-filled 200))
  # Pad input
  (def P (keccak-pad (buffer input) rate))
  # Absorbing phase
  (var pos 0)
  (while (< pos (length P))
    # XOR block into state: S[x,y] = S[x,y] ⊕ Pi[x+5*y] for x+5*y < r/w
    (for i 0 rate
      (when (< (+ pos i) (length P))
        (def old-byte (get S i))
        (def new-byte (get P (+ pos i)))
        (put S i (bxor old-byte new-byte))))
    # Apply Keccak-f[1600] permutation
    (set S (keccak-f S))
    (set pos (+ pos rate)))
  # Squeezing phase: extract first 256 bits
  (def Z (buffer/slice S 0 output-len))
  (ops/bstring Z))

from eth_utils.encoding import (
    int_to_big_endian
)

from eth_keys.backends.native.ecdsa import (
    ecdsa_raw_verify,
    private_key_to_public_key,
)

from eth_keys.constants import (
    SECPK1_N as N
)

def pad32(value: bytes) -> bytes:
    return value.rjust(32, b'\x00')


# The input variables:
private_key = 0x1
private_key_bytes = private_key.to_bytes(32, 'big')

public_key_bytes = private_key_to_public_key(private_key_bytes)

k = ((N - 1) // 2)

v = 28
r = 0x00000000000000000000003b78ce563f89a0ed9414f5aa28ad0d96d6795f9c63  # 
s = 0x45a8811907fd65c04c718943c33d54a1bed7fc23a1de2852fec9439bb4c74562  # generated with input address 0xDe0476793ff6BBf931B5FD8586E275B43Be195C2

# Signature generation algorithm
# ------------------------------
# Input: x, m
# --------------
# Select a random k from [1, ..., q-1]

# Define:
# -------
#     X = gk mod p
#     r = X mod q
#     e = Hash(m)
#     s = k^-1 * (e + xr) mod N

# Return signature:
# -----------------
#     (r, s)

# From this we can deduce the following:
#          s = k^-1 * (e + xr) mod N
#      s * k = 1 * (e + xr) mod N
#      s * k = e + xr mod N
# s * k - xr = e mod N
#
# And given that the private key is 0x1, we can simplify this to:
# s * k - r = e mod N

e = ((s * k) - r) % N

e_bytes = pad32(int_to_big_endian(e))
print(f"Signature hash is 0x{e_bytes.hex()}")

# Verify our solution is correct

is_correct = ecdsa_raw_verify(e_bytes, (r, s), public_key_bytes)
print(f"Signature is correct: {is_correct}")

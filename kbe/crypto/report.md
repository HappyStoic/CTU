```python
# EXERCISE 1.0

def bin2txt(arg: bytes) -> str:
    return arg.decode("utf-8")

def bin2hex(arg) -> str:
    return arg.hex()

def txt2bin(arg) -> bytes:
    return arg.encode()

def hex2bin(arg) -> bytes:
    return bytes.fromhex(arg)

def hex2txt(arg) -> str:
    return bin2txt(hex2bin(arg))

def txt2hex(arg) -> str:
    return bin2hex(txt2bin(arg))

t, b, h = "foo", b"foo", "666f6f"
print(bin2txt(b))
print(bin2hex(b))
print(txt2bin(t))
print(txt2hex(t))
print(hex2bin(h))
print(hex2txt(h))
```

    foo
    666f6f
    b'foo'
    666f6f
    b'foo'
    foo



```python
# EXERCISE 1.1

tm, m = txt2bin("everything remains raw"), txt2bin("the world is yours")
tk, k = txt2bin("word up"), txt2bin("illmatic")
tc = "121917165901181e01154452101d16061c1700071100"

def xor(msg: bytes, key: bytes) -> bytes:
    multiple = (len(msg) // len(key)) + 1
    return bytes([x^y for x,y in zip(msg, key*multiple)])

print(f"{tc} == {bin2hex(xor(tm, tk))}     {bin2hex(xor(tm, tk)) == tc}")
print(f"{m} ^ {k} = {bin2hex(xor(m, k))}")

```

    121917165901181e01154452101d16061c1700071100 == 121917165901181e01154452101d16061c1700071100     True
    b'the world is yours' ^ b'illmatic' = 1d04094d161b1b0f0d4c051e410d06161b1f



```python
# EXERCISE 1.2

# There are repeating groups of bytes in hex-encoded ciphertext,
# thus revealing position of same characters/words 
# (3 times double 'l', 3 spaces separating, 2 same words)
bin2txt(xor(hex2bin("404b48484504404b48484504464d4848045d4b"), b"$"))
```




    'dolla dolla bill yo'




```python
# EXERCISE 1.3|1.4

import string
from collections import Counter

def is_english(txt: str, diff = 5):
    allowed = lambda arg: all([char in string.printable for char in arg])
    if not allowed(txt):
        return False
    
    EN_FREQ = {
        'E' : 12.0,'T' : 9.10,'A' : 8.12,'O' : 7.68,
        'I' : 7.31,'N' : 6.95,'S' : 6.28,'R' : 6.02,
        'H' : 5.92,'D' : 4.32,'L' : 3.98,'U' : 2.88,
        'C' : 2.71,'M' : 2.61,'F' : 2.30,'Y' : 2.11,
        'W' : 2.09,'G' : 2.03,'P' : 1.82,'B' : 1.49,
        'V' : 1.11,'K' : 0.69,'X' : 0.17,'Q' : 0.11,
        'J' : 0.10,'Z' : 0.07 }

    letters = ''.join([x for x in txt.upper() if x in string.ascii_uppercase])
    counter = Counter(letters)
    
    freq = {k: (100*v)/len(letters) for k,v in counter.items()}
    
    for en_k, en_v in EN_FREQ.items():
        if en_k not in freq:
            continue

        if abs(en_v - freq[en_k]) > diff:
            return False
    return True
        

with open("text1.hex") as f:
    c = hex2bin(f.read())

for l in string.ascii_uppercase:
    decrypted = bin2txt(xor(c, l.encode()))
    if not is_english(decrypted):
        continue
        
    print(decrypted.split("\n")[0])

    
```

    Busta Rhymes up in the place, true indeed



```python
# EXERCISE 1.5

with open("text2.hex") as f:
    c = hex2bin(f.read())

KEY_LENGTH = 10
enc_chunks = [c[i::KEY_LENGTH] for i in range(KEY_LENGTH)]
key = []
for enc_chunk in enc_chunks:
    candidates = []
    for l in string.printable:
        dec = xor(enc_chunk, l.encode())
        if is_english(bin2txt(dec), diff=10):
            candidates.append(l)
    key.append(candidates)

if all([len(candidates) == 1 for candidates in key]):
    key = bytes([ord(x[0]) for x in key])
    dec = bin2txt(xor(c, key))
    print(f"Key: {key}")
    print("_"*50)
    print(dec[:dec.index("\n", 200)])
    print("...")
elif any([len(candidates) == 0 for candidates in key]):
    print(f"---")
else:
    print(f"MULTIPLE OPTIONS {key}")

```

    Key: b'SupremeNTM'
    __________________________________________________
    C'est le nouveau, phenomenal, freestyle du visage pale
    Le babtou est de retour, achtung!
    C'est parti, ca vient de Saint Denis
    Direct issu de la generation Fonky-Tacchini
    Pas de soucis, non pas de tiepis ici, pas de chichis
    ...



```python
# EXERCISE 1.6

with open("text3.hex") as f:
    c = hex2bin(f.read())

# A bit of bruteforcing
for key_length in range(2, 128):
    enc_chunks = [c[i::key_length] for i in range(key_length)]
    key = []
    for enc_chunk in enc_chunks:
        candidates = []
        for l in string.printable:
            dec = xor(enc_chunk, l.encode())
            if is_english(bin2txt(dec), diff=8):
                candidates.append(l)
        key.append(candidates)

    if all([len(candidates) == 1 for candidates in key]):
        key = bytes([ord(x[0]) for x in key])
        dec = bin2txt(xor(c, key))
        print(f"Key: {key}")
        print("_"*50)
        print(dec[:dec.index("\n", 200)])
        print("...")
        break
    elif any([len(candidates) == 0 for candidates in key]):
        print(f"{key_length}: ---")
    else:
        print(f"{key_length}: MULTIPLE OPTIONS {key}")

```

    2: ---
    3: ---
    4: ---
    5: ---
    6: ---
    7: ---
    8: ---
    9: ---
    10: ---
    11: ---
    12: ---
    13: ---
    14: ---
    15: ---
    Key: b'CL4SS!C_TIM3L35S'
    __________________________________________________
    And now for my next number I'd like to return to the...
    Classic
    Uh, uh, - timeless
    Live straight classic
    Classic
    Live, straight classic
    Timeless
    I'd like to return to the classic
    Kanye West
    I'm Rakim, the fiend of a microphone
    ...



```python
# EXERCISE 1.7

# "CL4SS!C_TIM3L35S" is also Bonus task password
print(open("philosophy.txt", "r").read())
```

    PMbELEUfmIA
    



```python
# EXERCISE 2.1 

# I, Martin Řepa, understand that cryptography is easy to mess up, and
# that I will not carelessly combine pieces of cryptographic ciphers to
# encrypt my users' data. I will not write crypto code myself, but defer to
# high-level libaries written by experts who took the right decisions for me,
# like NaCL.
```

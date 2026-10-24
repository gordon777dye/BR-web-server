---
title: Encryption
file: Encryption.md
category: 10-language
subcategory: 10-language/data-manipulation/system-functions
kind: function
related: [ENCRYPT, DECRYPT, internal functions, ENCRYPT$, DECRYPT$]
---
(As of 4.30)

**Encryption** encompasses a number of different operations.  These operations can be used independently or in combination to meet different needs.  We use industry standard encryption available through OpenSSL.  Three technologies are widely used for encrypting data. BR supports the first two listed below through its `ENCRYPT` and `DECRYPT` `internal functions`. 

==Overview of Two Encryption Methods==

1. **Symmetric key ciphers** – where the same key is used to encrypt and decrypt data. You can specify a key to encrypt some data and later use the same key to decrypt the data.

2. **Hashing routines** – one way routines that take data and convert it to a hash value.  Sometimes these are thought of as checksums such as MD5 sum.  Hash values are always the same length regardless of how big the hashed data is.  A 10 gb file will have a hash result that is the same length as a 200 byte file. Hashing routines have a number of specific uses, including:
*Verify that data has not changed.
*Verifying that two files are the same.
*Validating passwords – this is based on the concept that if two values have the same hash value the values are equal.  Using this technique improves security because it allows a server to store passwords in an unrecoverable format.  Even the server software is unable to regenerate the original password.  It is only capable of checking if the hash of a password matches the stored password hash.

==Symmetric Key Ciphers==
There are two encryption functions in the BR language, `ENCRYPT$` and `DECRYPT$`.

- ENCRYPT$(Data$ [,Key$ [,Encryption-type$ [,Initialization-vector$]]])
- DECRYPT$(Data$ [,Key$ [,Encryption-type$ [,Initialization-vector$]]])

Data$ - The data to be encrypted

Key$ - The secret key to be used for encryption.  If not specified this value will come from an OPTION 66 statement.

Encryption-type$ - The type of encryption to be done.  If not specified, a common high strength encryption type will be employed.  This is described in more detail below, but is generally only useful for interfacing with other typically non-BR programs.

Initialization-vector$ - This is an arcane part of encryption standards. It exists to prevent attackers from being able to tell whether the unencrypted data has changed. This is described in more detail below, but is general only needed when interfacing with other non-BR programs.

== Interfacing With Other Programs (encryption type and initialization vector)==
There are a number of different types of encryption that BR supports through OpenSSL:  AES, BLOWFISH, DES, triple DES, RC4 and RC2.  Most symmetric key ciphers are block ciphers meaning that they encrypt one block at a time. This means if you have a bit message, it is broken up into multiple blocks and each block is encrypted. The block size can be set as (128, 192, 256) bits. Some encryption types don't support all of these values so STATUS ENCRYPTION should be checked to see what encryption types are available in BR. Besides block size, there are also various schemes for blocking data. One might expect that using 256 bit blocking would simply take every 32 bytes and call it a block.  This is not done though because there is a possibility that this would cause patterns in the encrypted data. To prevent this, there are various schemes known as codebooks which change the way data is blocked. Wikipedia explains this in more detail. 

If the encryption type is not specified, AES:256:CBC:128 will be used. To be compatible with other programs, the entire encryption type must be specified in the format: `cipher:key-length:codebook:iv-length` (example: `AES:256:CBC:128`).

**Important:** IV length requirements vary by algorithm and mode. ECB modes do not use an IV (specify 0); CBC/CFB/OFB modes typically require 8 or 16 bytes depending on the cipher's block size. Stream ciphers like RC4 do not use an IV. Use **STATUS ENCRYPTION** to verify which encryption type combinations are valid for your build.

Initialization-vector – this is used to cause the same data encrypted with the same key to have a different encrypted result. This is significant because otherwise an attacker looking at data seeing the same encrypted result twice would know that the key and the unencrypted data have not changed. Regardless of whether or not you are concerned about this potential security issue, the standard encryption methods require this value so interfacing with other programs may require you to use it. It is a common practice to use a random number for this value and store the value at the beginning of (ahead of) the encrypted result. This is what BR does if this parameter is omitted.

As an example:
 ENCRYPT$(“test”,“key”) 
Produces a string containing “random number initialization vector”&”encrypted result”.

If the initialization vector is explicitly specified as in:
ENCRYPT$(“test”,“key”,“AES:256:CBC:128”,“RANDOM”) 
the result would be simply “encrypted result”.

DECRYPT$ has the same arguments as ENCRYPT$ with the exception of the first parameter which is the encrypted data. DECRYPT$ expects to be used with the same key$, encryption-type$, and initialization-vector$ as was used to encrypt the data.  As with ENCRYPT$, if key$ is not specified, the value from the OPTION statement will be used. If encryption-type$ is not specified, “AES:256:CBC:128” will be used. If the initialization vector is not specified, it will be assumed that the encrypted data starts with an initialization vector.

==Result Formats and Lengths==

===ENCRYPT$ Result Structure===

The output of ENCRYPT$ varies depending on whether an initialization vector (IV) is auto-generated or explicitly provided:

**Case 1: IV Auto-Generated (IV$ parameter omitted or empty)**

When you do not specify an IV parameter, BR generates a random IV and **prepends it** to the encrypted data:

 Result = [Random IV] + [Encrypted Data]

The IV length is determined by the encryption type specification (the last number in cipher:key-length:mode:iv-length).

**Example:**
<pre>
encrypted$ = ENCRYPT$(“Hello World”, “mykey”, “AES:256:CBC:128”)
! Result structure: 16 bytes of random IV + encrypted “Hello World” data
! Total length ≈ 16 bytes (IV) + 16 bytes (padded/encrypted block) = ~32 bytes
</pre>

**Case 2: IV Explicitly Specified**

When an IV is explicitly provided, only the encrypted data is returned (no IV prepending):

 Result = [Encrypted Data]

**Example:**
<pre>
my_iv$ = “1234567890123456”  ! 16 bytes for AES
encrypted$ = ENCRYPT$(“Hello World”, “mykey”, “AES:256:CBC:128”, my_iv$)
! Result: just encrypted “Hello World”, no IV prepended
! Total length ≈ 16 bytes (single AES block)
</pre>

===ENCRYPT$ Result Length Calculation===

For **symmetric ciphers**, output length depends on plaintext size due to block padding:

* **Block ciphers (DES, AES, etc.):** Output = ceiling(plaintext_length / block_size) × block_size
  - DES, DES-EDE, DES-EDE3, BF, CAST5, IDEA: 8-byte blocks
  - AES, CAMELLIA, SEED: 16-byte (128-bit) blocks
  - If IV is auto-generated, add IV length to total (e.g., AES with auto-IV: 16 + encrypted_data)

* **Stream ciphers (RC4):** Output = plaintext_length (no padding)

**Examples:**
<pre>
! DES with 8-byte block: “test” (4 bytes) → 8 bytes encrypted
encrypted$ = ENCRYPT$(“test”, “key”, “DES:64:CBC:64”)
LEN(encrypted$) = 8 (with auto-IV) or 16 total (8 IV + 8 encrypted)

! AES with 16-byte block: “Hello” (5 bytes) → 16 bytes encrypted  
encrypted$ = ENCRYPT$(“Hello”, “key”, “AES:256:CBC:128”)
LEN(encrypted$) = 16 (with explicit IV) or 32 total (16 IV + 16 encrypted)

! RC4 stream cipher: “Hello” (5 bytes) → 5 bytes encrypted (no padding)
encrypted$ = ENCRYPT$(“Hello”, “key”, “RC4:128:STREAM:0”)
LEN(encrypted$) = 5
</pre>

===DECRYPT$ Result Structure===

DECRYPT$ reverses the process:
* If IV was **auto-generated**, DECRYPT$ expects the encrypted data to **start with the IV** and extracts it automatically
* If IV was **explicitly provided**, DECRYPT$ uses the provided IV to decrypt

**Important:** Use identical parameters for decryption as were used for encryption, except for the encrypted data itself.

**Example:**
<pre>
! Encryption with auto-IV
plaintext$ = “Secret Message”
encrypted$ = ENCRYPT$(plaintext$, “key1”, “AES:256:CBC:128”)
! encrypted$ contains: [16-byte random IV] + [encrypted message]

! Decryption without specifying IV (auto-extracted from encrypted$)
recovered$ = DECRYPT$(encrypted$, “key1”, “AES:256:CBC:128”)
! Result: “Secret Message” (length = 14, spaces and padding removed)

! Alternative: manually extract and provide IV
iv_extracted$ = encrypted$(1:16)
encrypted_only$ = encrypted$(17:LEN(encrypted$))
recovered$ = DECRYPT$(encrypted_only$, “key1”, “AES:256:CBC:128”, iv_extracted$)
! Result: same as above
</pre>

===Hash Result Lengths===

Hash/digest algorithms produce **fixed-length output regardless of input size:**

| Algorithm | Output Length (bytes) | Output Format |
|-----------|----------------------|---------------|
| MD5 | 16 | 32 hex characters (if displayed as hex) |
| SHA (original) | 20 | 40 hex characters (if displayed as hex) |
| SHA-1 | 20 | 40 hex characters (if displayed as hex) |
| DSS | 20 | 40 hex characters (if displayed as hex) |
| DSS-1 | 20 | 40 hex characters (if displayed as hex) |
| MDC-2 | 16 | 32 hex characters (if displayed as hex) |
| RIPEMD-160 | 20 | 40 hex characters (if displayed as hex) |

**Note:** The output is **binary data**, not hex-encoded. To display or transmit as readable hex, use `UNHEX$()`.

**Examples:**
<pre>
! Hash with auto-generated result
hash_result$ = ENCRYPT$(“password123”, “”, “MD5”)
LEN(hash_result$) = 16 bytes (binary)

! Display as hex (readable)
hex_hash$ = UNHEX$(hash_result$)
! Now 32 characters representing the 16-byte MD5

! Another example: SHA-1
sha1_result$ = ENCRYPT$(“data”, “”, “SHA-1”)
LEN(sha1_result$) = 20 bytes (binary)
hex_sha1$ = UNHEX$(sha1_result$)
! Now 40 hex characters
</pre>

==Hashing Routines==
Multiple hashing algorithms are available in BR. These are provided through the ENCRYPT$ function by specifying a null key$ value:

 ENCRYPT$(data$, “”, “MD5”)
 ENCRYPT$(data$, “”, “SHA”)
 ENCRYPT$(data$, “”, “SHA-1”)
 ENCRYPT$(data$, “”, “DSS”)
 ENCRYPT$(data$, “”, “DSS-1”)
 ENCRYPT$(data$, “”, “MDC-2”)
 ENCRYPT$(data$, “”, “RIPEMD-160”)

Hashing is also referred to as Message Digests or digests. This is what the MD in MD5 means. There is no way to restore data that has been hashed. Hashing is a one-way function so DECRYPT$ will return error **BRENODECRYPTENCRYPT** if attempted on a hashed value.

**Note:** SHA is available for backward compatibility but SHA-1 or stronger algorithms are recommended for new code.

==Asymmetric Encryption==
Asymmetric key encryption is also known as public/private key encryption.

Public/private keys are created as a pair by a key generator.  They are a pair, and it is not possible to have two public keys for the same private key or vice versa. With regard to public/private key pairs, what one key encrypts the other key can decrypt, and neither key can decrypt what it has encrypted.  When a private key is used to encrypt data, the result is called a signature because everyone who has the public key can decrypt it.

This technique is used for:

Signing (using certificates) – A private key can be used to sign data. The result of such signing can be tested/validated with the corresponding public key.

Data encryption – A public key can be used to encrypt data. This data can then only be decrypted by the corresponding private key.

Hashes and signing are different but used together.  Rather than signing a large block of data which would create a large signature, only the hash is signed to create much smaller fixed length signature data.  When verifying a large block of signed data, the data is used to create a hash value and the hash value is compared to a decrypted signature.

Asymmetric encryption is not accessible through the BR ENCRYPT$, DECRYPT$ functions. However, it is used by our SSL client server connections and HTTPS. Certificates are most commonly used by SSL and HTTPS and are less useful for other application processes. 

In the Client Server model the client knows the server’s public key and the server uses its private key to encrypt and decrypt.  BRclient.exe connects to BRListener.exe by opening an SSL socket on the server using DHE_RSA-AES256-SHA Encryption. Handshaking is performed using a private key stored on the server within BRListener. Once authenticated, the socket is then passed to BRServer.exe for actual data processing.

Encryption is invoked by Business Rules HTTP support as follows:

 CONFIG HTTPS port-number   [ LOG file-pathname ] [CERT= cert-file-basename]
 CONFIG OPTION  66   private-key-file-encryption-password
 OPEN #400: “HTTP=SERVER”, DISPLAY, OUTIN

The BRSERVER executable directory must contain two files:

 https-private.pem
 https-cert.pem

These files are made by the following commands under Linux, MAC and cygwin for Windows: openssl req -new -x509 -out httpserver.pem -days 10000

(this will prompt for the OPTION 66 password)

 mv privkey.pem   https-private.pem
 mv httpserver.pem   https-cert.pem

This port specific service can then be accessed with browsers. When the specified port is accessed through a browser, BR establishes an HTTPS connection rather than an HTTP connection.

==Signing and Certificate Processing Industry Standards==
The purpose of certificates is to verify the authenticity of unencrypted data. 

Certain companies are authorized by the government to act as a Certificate Authority (CA). These companies (e.g. Verisign) issue electronic certificates which can be used to issue second level certificates. Certificates can have expiration dates and the line of authority extends from a CA to any number of levels (but a chain is only as strong as its weakest link). Certificates contain a list of signatures (described below) that trace back to a CA as follows: 

When a company needs to obtain a certificate from a CA, it prepares its own certificate and sends it to the CA for signature. Creating a certificate requires the pre-production of a private and public key pair. The certificate text properly identifies the signing authority, the owner of the certificate, and the owner’s public key. The signing authority externally verifies the identity of the owner before signing it.  The CA provides the signature and the CA’s own public key for validating it. 

Browsers know the CA identities and their public keys. A browser can verify a CA signed cert by hashing it, decrypting the signature with the known public key and matching the decrypted signature against the hash total. 
 
Any company that is issued a (self-prepared authority signed) certificate by a CA can sign second level certificates issued to third parties. A second level cert contains the parent (CA issued) certificate, and includes the public keys of the issuer and the recipient. The signature is essentially the encrypted hash total of ‘itself plus all of its ancestors’. Additional levels each contain the chain of certificates leading from a CA issued cert to itself. By including public keys along with the identities of the owners, certificates become tools for validating the signatures of their owners. When signed data (with an encrypted hash total) is sent to clients the signatures insure that the data has not been altered along the way. 

Ostensibly, a certificate cannot be counterfeited because it requires the signature of its parent which can only be produced with its parent’s private key.  By providing both public keys ( signer and recipient ) in all certs along with signatures, a non-forgeable or alterable chain is established. 

====Example:====
CA public key – known to browser
certificate 1 (signed by CA – contains owner’s public key)
certificate 2 (signed by second level - includes certificate 1 - contains owner’s public key)
final certificate (signed by third level - includes certificate 2 - contains owner’s public key)
 
A browser would find the CA information in the certificate and check to see if it is in the browser’s internal list. If not, it fails. Then it verifies that certificate 1 (which ends up being part of the final certificate) has been signed by the CA. After that it checks certificate 2 and verifies that it has been signed by the owner of certificate 1. Finally it checks the final certificate and verifies that it has been signed by the owner of certificate 2.

To assure the line authority of any certificate, the public keys are associated with signers, not with documents. 

==**Encryption Support by Version**==

BR encryption support has evolved over time. The sections below distinguish between currently supported legacy algorithms, deprecated (removed) algorithms, and newer additions.

==Old List (Still Supported)==

The following algorithms are supported for backward compatibility and remain available in current versions:

===Symmetric Key Ciphers===
<pre>
DES (ECB, CBC, CFB1, CFB8, CFB64, OFB)
DES-EDE / DES-EDE3 (Triple DES) (ECB, CBC, CFB1, CFB8, CFB64, OFB)
RC4 (40, 128 in STREAM mode)
RC2 (40, 64, 128 with ECB, CBC, CFB64, OFB modes)
BF (Blowfish, 128-bit; ECB, CBC, CFB64, OFB)
CAST5 (128-bit; ECB, CBC, CFB64, OFB)
AES (128, 192, 256-bit; ECB, CBC, CFB1, CFB8, CFB128, OFB)
IDEA (128-bit; ECB, CFB64, OFB, CBC) — not available on Mac OS X
CAMELLIA (128, 192, 256-bit; ECB, CBC, CFB1, CFB8, CFB128, OFB) — not available on Mac OS X
SEED (128-bit; ECB, CBC, CFB128, OFB) — not available on Mac OS X
</pre>

===Message Digest Algorithms===
<pre>
MD5
SHA   (original algorithm; use SHA-1 for new code — SHA-256 is not exposed in BR, see Wishlist below)
SHA-1
DSS   (Digital Signature Standard)
DSS-1
MDC-2
RIPEMD-160
</pre>

==Deprecated (Removed / No Longer Available)==

The following algorithms were available in earlier versions but are no longer exposed in current builds:

<pre>
(None currently — all previously deprecated algorithms have been restored or remain available)
</pre>

==STATUS ENCRYPTION==

The command:

<pre>
STATUS ENCRYPTION
</pre>

displays the encryption and digest algorithms supported by the currently running BR executable. This is the **authoritative source** for determining which algorithms, modes, and key lengths are available. Algorithm availability may vary by platform (e.g., IDEA, CAMELLIA, and SEED are unavailable on Mac OS X).

==Notes==

* Default encryption: `AES:256:CBC:128`
* If no initialization vector is provided, BR prepends a random IV to the encrypted output.
* DECRYPT$ must use the same parameters (key, encryption-type, IV) as were used for ENCRYPT$.
* Attempting to use an unsupported encryption type or mode combination will return an error. Use STATUS ENCRYPTION to verify availability.
* Error `BRENODECRYPTENCRYPT` is returned when attempting DECRYPT$ on a hashed value (one-way digests cannot be reversed).

==Common Use Cases and Examples==

===Example 1: Basic Encryption/Decryption with Auto-IV (Recommended)===

<pre>
! Simple, secure encryption using defaults
plaintext$ = "Sensitive data"
key$ = "MySecretKey"

! Encrypt (IV auto-generated and prepended)
encrypted$ = ENCRYPT$(plaintext$, key$)
! Result: ~32 bytes (16-byte IV + 16-byte padded data for AES-256-CBC)

! Decrypt (IV auto-extracted)
recovered$ = DECRYPT$(encrypted$, key$)
! Result: "Sensitive data" (padding removed, original plaintext recovered)
</pre>

===Example 2: Consistent Encryption (Same Output Each Time)===

<pre>
! When you need deterministic output (same plaintext = same ciphertext)
plaintext$ = "Important"
key$ = "MySecretKey"
fixed_iv$ = "FixedIV1234567890"  ! 16 bytes for AES

! Encrypt with explicit IV (output is consistent)
encrypted$ = ENCRYPT$(plaintext$, key$, "AES:256:CBC:128", fixed_iv$)
! Result: ~16 bytes (only encrypted data, no IV prepended)

! Encrypt same data again with same key/IV
encrypted2$ = ENCRYPT$(plaintext$, key$, "AES:256:CBC:128", fixed_iv$)
! Result: identical to encrypted$ (useful for comparing stored values)

! Decrypt using same IV
recovered$ = DECRYPT$(encrypted$, key$, "AES:256:CBC:128", fixed_iv$)
</pre>

===Example 3: Password Hashing (MD5, SHA-1)===

<pre>
! One-way hashing for password validation
password$ = "UserPassword123"

! Create hash (16 bytes binary)
password_hash$ = ENCRYPT$(password$, "", "MD5")
! Store password_hash$ in database

! Later, verify by re-hashing login attempt
login_attempt$ = "UserPassword123"
attempt_hash$ = ENCRYPT$(login_attempt$, "", "MD5")

IF attempt_hash$ = password_hash$ THEN
   PRINT "Password matches!"
ELSE
   PRINT "Incorrect password"
END IF
</pre>

===Example 4: Working with Hash Output (Convert to Hex Display)===

<pre>
! SHA-1 hash and display as hex string
data$ = "Message to hash"
hash_binary$ = ENCRYPT$(data$, "", "SHA-1")  ! 20 bytes binary
LEN(hash_binary$)  ! = 20

! Convert to hex for display/logging
hash_hex$ = UNHEX$(hash_binary$)
PRINT "SHA-1 Hash: " & hash_hex$
! Output: SHA-1 Hash: ABC123DEF456... (40 hex characters)
</pre>

===Example 5: Interoperability with External Systems===

<pre>
! Encrypt data to send to a non-BR system
! System expects: AES-128 CBC mode with explicit 16-byte IV, no IV prepending

plaintext$ = "System Integration"
key$ = "16-byte-key12345"     ! Exactly 16 bytes for AES-128
my_iv$ = "InitVect16bytes"    ! Exactly 16 bytes

! Encrypt with explicit params (IV not prepended)
encrypted$ = ENCRYPT$(plaintext$, key$, "AES:128:CBC:128", my_iv$)
! Result: ~16 bytes (single AES block)

! Send to external system as: [my_iv$] + [encrypted$]
output$ = my_iv$ & encrypted$

! To receive and decrypt from external system:
received$ = ... ! Data from other system (IV + encrypted)
received_iv$ = received$(1:16)
received_encrypted$ = received$(17:LEN(received$))
recovered$ = DECRYPT$(received_encrypted$, key$, "AES:128:CBC:128", received_iv$)
</pre>

===Example 6: Working with Large Data (Output Length)===

<pre>
! Encrypting data larger than one block
large_data$ = "This is a longer message that spans multiple blocks"
! Length = 51 bytes

key$ = "MyKey"

! AES has 16-byte blocks; 51 bytes → 64 bytes encrypted (4 blocks)
encrypted$ = ENCRYPT$(large_data$, key$)
! With auto-IV: LEN(encrypted$) = 16 (IV) + 64 (encrypted) = 80 bytes

! DES has 8-byte blocks; 51 bytes → 56 bytes encrypted (7 blocks)
encrypted_des$ = ENCRYPT$(large_data$, key$, "DES:64:CBC:64")
! With auto-IV: LEN(encrypted_des$) = 8 (IV) + 56 (encrypted) = 64 bytes

! Stream cipher (RC4) has no padding
encrypted_rc4$ = ENCRYPT$(large_data$, key$, "RC4:128:STREAM:0")
! With auto-IV: LEN(encrypted_rc4$) = 0 (RC4 has no IV) + 51 = 51 bytes
</pre>

==Wishlist: Future Encryption Types==

The following modern algorithms are supported by OpenSSL but not currently exposed in BR:

* SHA-256 (message digest)
* SHA-512 (message digest)
* AES:128:GCM:96
* AES:192:GCM:96
* AES:256:GCM:96
* HMAC-SHA-256
* HMAC-SHA-512
* ChaCha20-Poly1305
* PBKDF2 (password hashing)

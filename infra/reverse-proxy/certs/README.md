# Certificate and key for the master

The `master.crt` and `master.key` files have been created using this command:

```
openssl req -newkey rsa:4096 -nodes -sha256 -keyout master.key -x509 -days 365 -out master.crt
Generating a 4096 bit RSA private key
............................................................................................++
........................................................................................++
writing new private key to 'master.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:DE
State or Province Name (full name) [Some-State]:Example State
Locality Name (eg, city) []:Example City
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Example Company
Organizational Unit Name (eg, section) []:Example Organization Unit
Common Name (e.g. server FQDN or YOUR name) []:master.example.com
Email Address []:admin@master.example.com
```


# How to list the contents of one of the certificates

```bash
openssl x509 -in master.crt -text
```

Output

```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            6a:58:4a:2a:a5:bf:3a:9a:92:a2:a0:ca:14:6b:d3:88:29:8e:c4:2c
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = DE, ST = Example State, L = Example City, O = Example Company, OU = Example Organizational Unit, CN = master.example.com, emailAddress = admin@master.example.com
        Validity
            Not Before: Jan 28 08:01:12 2021 GMT
            Not After : Jan 28 08:01:12 2022 GMT
        Subject: C = DE, ST = Example State, L = Example City, O = Example Company, OU = Example Organizational Unit, CN = master.example.com, emailAddress = admin@master.example.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (4096 bit)
                Modulus:
                    00:f8:ff:72:5f:c9:13:b6:3d:c5:1e:bb:db:70:62:
                    d2:1f:ca:bb:86:c0:1d:4e:58:62:5a:d4:76:21:d2:
                    ec:8b:6f:6f:79:40:37:93:49:ba:3c:71:4f:fc:53:
                    84:e0:a7:b2:9a:c6:a1:cc:74:e6:b8:34:8b:2e:8a:
                    91:24:4c:1d:7e:4e:da:52:46:dd:76:0b:48:09:c3:
                    e9:6a:43:e0:d9:3f:d9:85:37:ab:4b:bf:e1:3b:33:
                    2e:13:77:2e:d1:8d:f4:03:a2:0b:ff:83:dc:c9:99:
                    c3:bf:3a:80:4d:ea:27:c1:fa:96:04:41:c5:d6:93:
                    a0:56:a2:62:ae:4a:a5:99:a9:a0:d4:cd:7a:1f:63:
                    3e:85:3a:fc:02:e5:79:fc:17:ed:fa:f2:f6:79:2b:
                    ff:ed:bf:58:df:0e:8d:ed:2d:d6:20:ac:99:5e:87:
                    a8:a9:85:91:c2:34:e7:31:47:e9:85:58:90:81:38:
                    12:c0:fd:52:70:d7:b8:6e:73:e9:fd:7b:b5:a4:1d:
                    ff:ec:43:1d:08:f3:82:75:90:6d:33:47:c1:60:83:
                    33:59:69:fa:d7:0c:e3:2a:9b:12:69:50:55:ba:51:
                    3a:88:a0:40:23:6a:e6:05:f0:d1:a3:0c:a1:68:7d:
                    1d:72:af:a9:c1:58:9a:27:d4:9b:7a:47:f6:f3:06:
                    4f:33:f3:31:bf:85:9e:22:8b:8c:04:5f:2d:89:aa:
                    26:0f:88:5d:1f:fa:a7:fb:e7:83:f1:d8:e4:05:aa:
                    80:cb:a4:ac:24:e1:35:38:35:3b:ea:d3:18:07:5d:
                    29:ae:0f:6d:f0:26:f6:ea:2f:bf:7b:54:94:8d:59:
                    0d:71:f9:04:37:99:fd:00:10:ad:21:14:51:c5:92:
                    3a:af:43:5e:a8:63:91:17:57:80:2e:43:cd:c5:c5:
                    58:97:66:82:3a:5e:34:09:e5:a7:8d:12:88:f7:16:
                    c2:99:cd:bd:b0:a9:c1:fa:b7:3b:d8:ed:d3:f8:ab:
                    f2:4e:bf:a7:7f:33:39:4e:61:2f:1c:b6:dc:f3:e7:
                    32:d3:36:38:b9:ba:40:25:5d:e3:47:63:3e:34:ae:
                    93:a4:9b:9c:78:b4:a1:29:b6:c7:53:16:18:91:5b:
                    44:6c:04:3f:14:c1:90:b0:43:20:5d:74:04:9c:eb:
                    c5:d9:39:e4:be:12:e6:ae:4d:a3:f0:0c:5d:41:52:
                    47:2f:f7:1a:e6:c6:70:29:fb:ad:3a:6c:4b:83:67:
                    4e:49:e1:03:fd:f3:81:72:51:14:a3:2a:74:28:3c:
                    58:39:85:5f:b4:6a:73:60:53:82:cf:e7:8c:2a:e2:
                    26:3a:e8:5c:16:23:02:3e:35:f0:eb:8e:50:87:5a:
                    29:70:13
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                27:1C:E9:F1:DA:80:CE:A6:DF:F0:5F:82:2F:26:C7:A6:9A:93:56:2F
            X509v3 Authority Key Identifier: 
                keyid:27:1C:E9:F1:DA:80:CE:A6:DF:F0:5F:82:2F:26:C7:A6:9A:93:56:2F

            X509v3 Basic Constraints: critical
                CA:TRUE
    Signature Algorithm: sha256WithRSAEncryption
         f5:4c:42:0f:a8:2e:a3:71:6e:2d:40:67:8a:2e:2e:b2:11:cc:
         c9:73:cd:45:d3:eb:5e:51:16:60:da:5b:11:ec:ad:86:12:5c:
         2c:bf:15:3e:be:bb:a9:2e:b8:38:2c:35:36:5d:a2:5d:67:10:
         98:6f:82:96:e8:45:da:b9:96:ae:b1:ff:d7:95:d2:3b:f0:1a:
         4f:68:10:30:e3:72:da:5a:f7:45:f1:67:64:96:1c:9d:b9:00:
         c2:cb:1f:d4:47:a1:e8:90:f7:bc:35:58:f0:f2:a5:61:b9:77:
         6c:30:a0:df:4d:20:c3:0f:33:dc:e4:9e:68:96:47:19:fd:f4:
         7f:3b:96:2f:67:f5:a8:d8:24:28:7f:ce:a8:9a:e0:51:7c:3c:
         f1:d4:28:98:17:99:2b:49:d9:51:59:50:1e:7e:67:f4:6f:fe:
         68:82:75:95:98:74:c1:b2:bb:8b:39:9b:5e:7a:a6:b6:57:1c:
         49:8f:0d:56:32:38:b2:e1:e8:0e:c1:aa:58:7b:f2:fa:b5:d8:
         92:2f:56:fb:fd:33:c5:08:9b:1f:0c:92:1f:a6:34:1a:16:c1:
         2b:be:ab:ff:69:3e:6f:52:3d:9a:33:36:18:f7:2c:bd:28:b4:
         8e:22:e2:c7:47:b9:a7:87:8f:20:da:d3:bb:20:a2:23:84:33:
         d7:d4:3a:ac:11:3b:b9:ff:ea:82:2c:2f:94:b4:44:65:ee:0a:
         f8:6e:c1:41:1a:09:b8:1a:22:ba:4e:40:ea:be:ce:48:54:e6:
         50:27:ec:7d:fc:fc:b8:98:8c:3a:04:e9:29:c2:d1:c4:bf:41:
         1a:7b:f6:8d:b4:8f:34:44:b1:8d:f3:f0:82:de:7a:1b:1b:58:
         77:63:45:9c:67:eb:95:34:0b:3f:78:ad:07:26:c3:e0:b8:72:
         28:73:5b:85:f7:f8:4d:35:c6:0b:c2:d0:82:cf:dd:ae:7e:51:
         3a:d0:76:22:25:19:8d:03:d8:4c:88:18:1d:0f:fc:d6:5d:b1:
         2a:d4:1b:56:99:21:5b:19:f4:03:95:5b:23:34:51:3e:c3:87:
         44:c0:65:27:4d:fe:24:87:7e:32:3f:e0:37:32:fc:a6:83:bb:
         9c:15:77:65:7a:a5:38:55:e1:2e:50:eb:a1:72:89:0a:0d:95:
         66:58:95:4c:77:83:88:a5:af:87:a5:1b:cf:07:46:8b:55:ee:
         77:97:b5:48:bd:35:c7:a5:a5:2d:f8:29:fd:ac:ca:38:00:b6:
         71:67:2c:47:2f:5b:3a:f3:93:44:1c:ca:54:92:89:a9:4c:56:
         43:cc:07:ce:30:f3:a4:e3:39:c3:8e:51:af:13:79:bc:f6:f2:
         c8:cd:c4:21:31:d8:b2:63
-----BEGIN CERTIFICATE-----
MIIGZzCCBE+gAwIBAgIUalhKKqW/OpqSoqDKFGvTiCmOxCwwDQYJKoZIhvcNAQEL
BQAwgcIxCzAJBgNVBAYTAkRFMRYwFAYDVQQIDA1FeGFtcGxlIFN0YXRlMRUwEwYD
VQQHDAxFeGFtcGxlIENpdHkxGDAWBgNVBAoMD0V4YW1wbGUgQ29tcGFueTEkMCIG
A1UECwwbRXhhbXBsZSBPcmdhbml6YXRpb25hbCBVbml0MRswGQYDVQQDDBJtYXN0
ZXIuZXhhbXBsZS5jb20xJzAlBgkqhkiG9w0BCQEWGGFkbWluQG1hc3Rlci5leGFt
cGxlLmNvbTAeFw0yMTAxMjgwODAxMTJaFw0yMjAxMjgwODAxMTJaMIHCMQswCQYD
VQQGEwJERTEWMBQGA1UECAwNRXhhbXBsZSBTdGF0ZTEVMBMGA1UEBwwMRXhhbXBs
ZSBDaXR5MRgwFgYDVQQKDA9FeGFtcGxlIENvbXBhbnkxJDAiBgNVBAsMG0V4YW1w
bGUgT3JnYW5pemF0aW9uYWwgVW5pdDEbMBkGA1UEAwwSbWFzdGVyLmV4YW1wbGUu
Y29tMScwJQYJKoZIhvcNAQkBFhhhZG1pbkBtYXN0ZXIuZXhhbXBsZS5jb20wggIi
MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQD4/3JfyRO2PcUeu9twYtIfyruG
wB1OWGJa1HYh0uyLb295QDeTSbo8cU/8U4Tgp7KaxqHMdOa4NIsuipEkTB1+TtpS
Rt12C0gJw+lqQ+DZP9mFN6tLv+E7My4Tdy7RjfQDogv/g9zJmcO/OoBN6ifB+pYE
QcXWk6BWomKuSqWZqaDUzXofYz6FOvwC5Xn8F+368vZ5K//tv1jfDo3tLdYgrJle
h6iphZHCNOcxR+mFWJCBOBLA/VJw17huc+n9e7WkHf/sQx0I84J1kG0zR8FggzNZ
afrXDOMqmxJpUFW6UTqIoEAjauYF8NGjDKFofR1yr6nBWJon1Jt6R/bzBk8z8zG/
hZ4ii4wEXy2JqiYPiF0f+qf754Px2OQFqoDLpKwk4TU4NTvq0xgHXSmuD23wJvbq
L797VJSNWQ1x+QQ3mf0AEK0hFFHFkjqvQ16oY5EXV4AuQ83FxViXZoI6XjQJ5aeN
Eoj3FsKZzb2wqcH6tzvY7dP4q/JOv6d/MzlOYS8cttzz5zLTNji5ukAlXeNHYz40
rpOkm5x4tKEptsdTFhiRW0RsBD8UwZCwQyBddASc68XZOeS+EuauTaPwDF1BUkcv
9xrmxnAp+606bEuDZ05J4QP984FyURSjKnQoPFg5hV+0anNgU4LP54wq4iY66FwW
IwI+NfDrjlCHWilwEwIDAQABo1MwUTAdBgNVHQ4EFgQUJxzp8dqAzqbf8F+CLybH
ppqTVi8wHwYDVR0jBBgwFoAUJxzp8dqAzqbf8F+CLybHppqTVi8wDwYDVR0TAQH/
BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAgEA9UxCD6guo3FuLUBnii4ushHMyXPN
RdPrXlEWYNpbEeythhJcLL8VPr67qS64OCw1Nl2iXWcQmG+CluhF2rmWrrH/15XS
O/AaT2gQMONy2lr3RfFnZJYcnbkAwssf1Eeh6JD3vDVY8PKlYbl3bDCg300gww8z
3OSeaJZHGf30fzuWL2f1qNgkKH/OqJrgUXw88dQomBeZK0nZUVlQHn5n9G/+aIJ1
lZh0wbK7izmbXnqmtlccSY8NVjI4suHoDsGqWHvy+rXYki9W+/0zxQibHwySH6Y0
GhbBK76r/2k+b1I9mjM2GPcsvSi0jiLix0e5p4ePINrTuyCiI4Qz19Q6rBE7uf/q
giwvlLREZe4K+G7BQRoJuBoiuk5A6r7OSFTmUCfsffz8uJiMOgTpKcLRxL9BGnv2
jbSPNESxjfPwgt56GxtYd2NFnGfrlTQLP3itBybD4LhyKHNbhff4TTXGC8LQgs/d
rn5ROtB2IiUZjQPYTIgYHQ/81l2xKtQbVpkhWxn0A5VbIzRRPsOHRMBlJ03+JId+
Mj/gNzL8poO7nBV3ZXqlOFXhLlDroXKJCg2VZliVTHeDiKWvh6UbzwdGi1Xud5e1
SL01x6WlLfgp/azKOAC2cWcsRy9bOvOTRBzKVJKJqUxWQ8wHzjDzpOM5w45RrxN5
vPbyyM3EITHYsmM=
-----END CERTIFICATE-----
```

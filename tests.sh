#!/bin/bash

step ca health
echo "Health shoould have responded ok"

echo ""
echo "Get the root cert"
step ca root root.crt

echo "Get a Cert. Will need the password to the Intermediate Cert"
step ca certificate myservice myservice.crt myservice.key --san myservice.internal.mycompany.net --not-after 24h
 
#Single Use Token
TOKEN=$(step ca token internal.example.com)
echo $TOKEN

step ca certificate internal.example.com internal.crt internal.key --token $TOKEN

TOKEN=$(step ca token internal.example.com)

step ca certificate internalX.example.com internal.crt internal.key --token $TOKEN
## token subject 'internal.example.com' and argument 'internalX.example.com' do not match



step certificate fingerprint .step/certs/root_ca.crt 
# ed47d6de4ac58d71dc7f2e90c820f4229caf0812bac47e0e12ffc2c0580b4a50




 step certificate install .step/certs/root_ca.crt 
#[sudo] password for jradley: 
#Certificate .step/certs/root_ca.crt has been installed.
#X.509v3 Root CA Certificate (ECDSA P-256) [Serial: 2204...2352]
#  Subject:     jsrsoftuk Root CA
#  Issuer:      jsrsoftuk Root CA
#  Valid from:  2022-05-05T17:51:51Z
#          to:  2032-05-02T17:51:51Z


 echo $TOKEN | step crypto jwt inspect --insecure
{
  "header": {
    "alg": "ES256",
    "kid": "_1enVs8LMFL2GhfjGgofPAAN_oHl7uDQ4ssNLHp76rc",
    "typ": "JWT"
  },
  "payload": {
    "aud": "https://jsrsoft.uk:2443/1.0/sign",
    "exp": 1651783697,
    "iat": 1651783397,
    "iss": "jsrsoftuk-jwk1",
    "jti": "ca53abe388ff9982237e6ffed8e6acad82af6af4d00c8d7fca184bf0eafd36f7",
    "nbf": 1651783397,
    "sans": [
      "internalY.example.com"
    ],
    "sha": "ed47d6de4ac58d71dc7f2e90c820f4229caf0812bac47e0e12ffc2c0580b4a50",
    "sub": "internalY.example.com"
  },
  "signature": "QNI6j6CnuX3YUJDIj4jqdT4m_v2mqi9QDxdG0Oh3UIfTKzFMLJjDvrRWOAIH2BrwrLAuCBJ-rvlsjqB3Wl098Q"
}



 step ca provisioner list
[
   {
      "type": "JWK",
      "name": "jsrsoftuk-jwk1",
      "key": {
         "use": "sig",
         "kty": "EC",
         "kid": "_1enVs8LMFL2GhfjGgofPAAN_oHl7uDQ4ssNLHp76rc",
         "crv": "P-256",
         "alg": "ES256",
         "x": "GI0dsDbjkNoLNxCMzg5IIPCdTY1WbjgBIc4EcYHEdmE",
         "y": "NvQVvf0fkDVKnCe-Y7sjUEfEthLUw8V7Eoe94HZETNI"
      },
      "encryptedKey": "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjEwMDAwMCwicDJzIjoiaDNodi1GRFdVWjk0d2dPbWhuaVh0dyJ9.sQWtjHt6hynxGq4EVKJtH7YJaunWa9UJ0CzjJ-ejpAUjp5fVVIsejQ.2fQx-jYy2kLUdFco._b0kXz5ilUOdDpOb_hGLzf6Z4l5CmoO1t9X8ZWjuYt1FKDIE2HZddE_umhfiPPquS4wFWYTIo1MgkUH5iO4SORXCLDZMd3q6jADzBvIjsh8EO_sA7L04BAe8b9P-BAjNNeNw0AExsACG5TKuTwhhhkJE6MkEJ0RIvN3dImu_grNwX5qU9eaOem-RATEj7JYCYRyAOTOR1cgxII6qxmdMKa7L026LSslyqBwaAypw_xph6HD-84BybwrdhZOBdE4TK1Y4MbDHjW9e85Di6FrOARA-h0il4gdd-oZdNO1HzXTyDHf5gYH5zBuL_qd5DCtia8BlCaFVG10mU0kKHhM._H2i0S9YxiaWfrpK4Vib4w",
      "claims": {
         "enableSSHCA": true
      }
   },
   {
      "type": "SSHPOP",
      "name": "sshpop",
      "claims": {
         "enableSSHCA": true
      }
   }
]



NEEDS to run on CA Server

step ca provisioner add jsrsoft-jwk2 --ca-config /etc/step-ca/config/ca.json --create




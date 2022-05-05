# Smallstep Personal Utilities

Smallstep is a suite of software to manage SSH User and Host certificates.
See https://smallstep.com and https://github.com/smallstep

It offers an alternative to SSH Keys
The software is available as both Binaries and Packages

Here, are install and upgrade scripts that offer the latest Packages as found on their Github project.

Also, install-ca.sh - Scripted install instead of being interactive

Example CA Install Log

Installing Step CA...
Current Step Path is: /home/<name>/.step

Generating root certificate... done!
Generating intermediate certificate... done!
Generating user and host SSH certificate signing keys... done!

✔ Root certificate: /home/<name>/.step/certs/root_ca.crt
✔ Root private key: /home/<name>/.step/secrets/root_ca_key
✔ Root fingerprint: <3720c3f6eb1ac3c2a2-long-string-460ef898d297ffa56dde2f17278c8e2>
✔ Intermediate certificate: /home/<name>/.step/certs/intermediate_ca.crt
✔ Intermediate private key: /home/<name>/.step/secrets/intermediate_ca_key
✔ SSH user public key: /home/<name>/.step/certs/ssh_user_ca_key.pub
✔ SSH user private key: /home/<name>/.step/secrets/ssh_user_ca_key
✔ SSH host public key: /home/<name>/.step/certs/ssh_host_ca_key.pub
✔ SSH host private key: /home/<name>/.step/secrets/ssh_host_ca_key
✔ Database folder: /home/<name>/.step/db
✔ Templates folder: /home/<name>/.step/templates
✔ Default configuration: /home/<name>/.step/config/defaults.json
✔ Certificate Authority configuration: /home/<name>/.step/config/ca.json

Your PKI is ready to go. To generate certificates for individual services see 'step help ca'.


Example defaults.json

:~/.step/config$ cat defaults.json 
{
	"ca-url": "https://<url>:443",
	"ca-config": "/home/<name>/.step/config/ca.json",
	"fingerprint": "<3720c3f6eb1ac3c2a2-long-string-460ef898d297ffa56dde2f17278c8e2>",
	"root": "/home/<name>/.step/certs/root_ca.crt"
}


Example TREE

~/.step$ tree
.
├── certs
│   ├── intermediate_ca.crt
│   ├── root_ca.crt
│   ├── ssh_host_ca_key.pub
│   └── ssh_user_ca_key.pub
├── config
│   ├── ca.json
│   └── defaults.json
├── db
├── secrets
│   ├── intermediate_ca_key
│   ├── root_ca_key
│   ├── ssh_host_ca_key
│   └── ssh_user_ca_key
└── templates
    └── ssh
        ├── ca.tpl
        ├── config.tpl
        ├── known_hosts.tpl
        ├── sshd_config.tpl
        ├── step_config.tpl
        └── step_includes.tpl

6 directories, 16 files


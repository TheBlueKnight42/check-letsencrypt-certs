# check-letsencrypt-certs
LetsEncrypt certificate monitoring script

## **Example**
![Example](images/check-letsencrypt-certs.png)

## **Requirements**
* OpenSSL
* Let's Encrypt x509 Certificates

## **Execution**
The script can be run directly or sourced. The user must have execute permissions for openssl and read access to the certificates. The script uses openssl to read the expiration date from the certificate and then displays the result with color coding. Green means the certificate expiration is more than 14 days away. Yellow means the cert will expire within 14 days. Red means the certificate is already expired. Run it directly from its location under /etc/letsencrypt/scripts i.e. Since the script only reads the certificates, *root* permissions should not be needed.
```
/etc/letsencrypt/scripts/check-letsencrypt-certs.sh
```

## **Install Instructions.**
#### Copy method (default)
By copying the script into place, you won't need to keep the cloned version of the repo. In this method, the install script copies the script to /etc/letsencrypt/scripts. Run the install.sh script as *root*. i.e.
```
git clone https://github.com/TheBlueKnight42/check-letsencrypt-certs.git
cd check-letsencrypt-certs
sudo ./install.sh
cd ..
rm -r check-letsencrypt-certs
```

#### Link method (recommended)
Linking to the script in your cloned version of the repo makes keeping the script up to date easy by pulling the GitHub repository. In this method, the install script links from /etc/letsencrypt/scripts/check-letsencrypt-certs.sh to your cloned copy of the repo. Run the install.sh script as *root* with the `--link` parameter. i.e.
```
git clone https://github.com/TheBlueKnight42/check-letsencrypt-certs.git
cd check-letsencrypt-certs
sudo ./install.sh --link
```

#### Manual install
Simply move, copy, or link the script where you want it.

# check-letsencrypt-certs
LetsEncrypt certificate monitoring script

## **Example**
![Example](images/check-letsencrypt-certs.png)

## **Requirements**
* OpenSSL
* x509 Certificates

## **Execution**
The script can be run directly or sourced. The user must have execute permissions for openssl and read access to the certificates. The script uses openssl to read the expiration date from the certificate and then displays the result with color coding. Green means the certificate expiration is more than 14 days away. Yellow means the cert will expire within 14 days. Red means the certificate is already expired.

## **Install Instructions.**
#### Link method (recommended)
Linking to the script in your cloned version of the repo makes keeping the script up to date easy by pulling the GitHub repository. Run the install.sh script as *root* with the `--link` parameter. i.e.
```
sudo ./install.sh --link
```

#### Copy method
Run the install.sh script as *root*. i.e.
```
sudo ./install.sh
```

#### Manual install
Simply move, copy, or link the script where you want it.

# README

The purpose of this repo is to try out Nginx with PQC settings.

Notice that this is only using PQC algorithms for key exchange, 
and not for certificates. The self-signed cert used for the tests
here are still your usual RSA-based x509 cert.

## Quick Start

This repo defines a simple docker image, built on Ubuntu 24.04 LTS.
The image builds the Open Quantum Safe (OQS) Provider for OpenSSL, and configures
the provider in OpenSSL, and then runs NGINX using a set of PQC curves.

Here are the list of curves NGINX with the OpenSSL OQS provider is configured to use:

* X25519MLKEM768 
* x25519
* secp384r1
* x448
* secp256r
* secp521r1

I'm using docker-compose here because it makes all of the port-forwarding between the host and guest,
extremely easy. 

To get started simply run:

```
docker compose up
```

And now in your host browser, or HTTPS client of choice, you can visit:
```
https://echo-pqc-1.lvh.me:8043
```

I'm using lvh.me as an external DNS service, that resolves to `127.0.0.1`.

The service is using a self-signed cert that was created with the Docker image.
So you will get an untrusted certificate error. If you want to not get this error,
you must import the self-signed cert, that is exposed to the host in `./certs_export/pqc.crt`.
But, since we are only using PQC for key-exchange, and not the certificate, it's not really all 
that important to import certificate. It is there if you care.

Now you can see if your browser or HTTPS-client, is using a PQC curve for key exchange.
The echo service, running in the container will, among other things, echo 
in the JSON output the `$ssl_curve` parameter used by NGINX.

Here is a sample output:

```
{
  "method": "GET",
  "request_ip": "172.18.0.1",
  "request_url": "/",
  "ssl_curve": "0x11ec",
  "now": {
    "utc_str": "2025-02-20 22:59:38 UTC",
    "iso_str": "2025-02-20 22:59:38 UTC"
  },
  "headers": {
    "x-real-ip": "172.18.0.1",
    "x-ssl-curve": "0x11ec",
    "host": "echo_pqc_1_backend",
    "connection": "close",
    "cache-control": "max-age=0",
    "sec-ch-ua": "\"Not(A:Brand\";v=\"99\", \"Google Chrome\";v=\"133\", \"Chromium\";v=\"133\"",
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": "\"Linux\"",
    "upgrade-insecure-requests": "1",
    "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36",
    "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "sec-fetch-site": "none",
    "sec-fetch-mode": "navigate",
    "sec-fetch-user": "?1",
    "sec-fetch-dest": "document",
    "accept-encoding": "gzip, deflate, br, zstd",
    "accept-language": "en-US,en;q=0.9",
    "cookie": "fezly.sid=s%3ABWDppu0uB9q20HkSY629w2-N-dY6KI2C.3QGzYk%2F9b2qGDh96h5y00gUcRUgiYRpcERNvtCmc0Rs"
  }
}
```

What you see above is the key `ssl_curve`, which returns a code indicating the curve used by NGINX.
Here the value of `0x11ec`, which is 4588 in hex, and translates to `X25519MLKEM768` according to this document: [IANA TLS Parameters](https://www.iana.org/assignments/tls-parameters/tls-parameters.xhtml#tls-parameters-8).

So at least for my Chrome browser, that is Chrome version 133, this indicates that we are using a hybrid PQC scheme.
And that's interesting.

## What about PQC certificates?

There are no PQC certificates involved here. 
What you will notice in the Dockerfile is that the self-signed certificate generated for this test, is a standard RSA certificate.
There is a folder exported by the container to the host, called `certs_export`, that allows the host to import the self-signed cert
to their HTTPS client for testing.

The only PQC happening here, or expected to happen here, is in the key-exchange, and NOT the certificate.

## External References

- https://www.linode.com/docs/guides/post-quantum-encryption-nginx-ubuntu2404/
- https://github.com/open-quantum-safe/oqs-provider
- https://blog.aegrel.ee/kyber-nginx.html


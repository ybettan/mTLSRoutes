# mTLSRoutes

## Kubernetes

#### Prerequsits
* openssl
* minikube
* kubectl

#### Guide

Move to correct repo
* `cd kubernetes`

Deploy the app
* `minikube start`
* `./setup.sh`

Test it
* requests without client-crt should fail: `curl https://meow.com/ -k`
* requests with client-crt should succeed: `curl https://meow.com/ --cert client.crt --key client.key -k`

## Sources
* https://medium.com/@awkwardferny/configuring-certificate-based-mutual-authentication-with-kubernetes-ingress-nginx-20e7e38fdfca

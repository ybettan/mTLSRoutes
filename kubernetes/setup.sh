
# enable ingress on minikube
echo enabling ingress...
minikube addons enable ingress

# generate the CA key and certificate
echo generating the CA key and certificate...
openssl req -x509 -sha256 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 356 \
    -nodes -subj '/CN=Fern Cert Authority'

# generate the server key, and certificate and sign with the CA certificate
echo generating server key and certificate...
openssl req -new -newkey rsa:4096 -keyout server.key -out server.csr -nodes -subj '/CN=meow.com'
echo signing server key with the CA certificate...
openssl x509 -req -sha256 -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

# generate the client key, and certificate and sign with the CA certificate
echo generating client key and certificate...
openssl req -new -newkey rsa:4096 -keyout client.key -out client.csr -nodes -subj '/CN=Fern'
echo signing client key with the CA certificate...
openssl x509 -req -sha256 -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 02 -out client.crt

# work in mtls-routes namespace
kubectl create namespace mtls-routes

# store ca-cert and server-cert as Secret in the cluster
echo storing ca-cert and server-cert as Secret in the cluster...
kubectl -n mtls-routes create secret generic my-certs \
    --from-file=tls.crt=server.crt \
    --from-file=tls.key=server.key \
    --from-file=ca.crt=ca.crt

# deploy and expose the app
echo deploying and expose the app...
kubectl apply -f manifests/

# add ingress address to /etc/hosts
hosted_ip=`cat /etc/hosts | grep meow.com | cut -d" " -f1`
minikube_ip=`minikube ip`
if [[ $hosted_ip != $minikube_ip ]]; then
    echo adding ingress address to /etc/hosts...
    sudo -- sh -c "echo $(minikube ip)  meow.com >> /etc/hosts"
fi

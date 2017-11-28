#!/bin/sh
set -e

if [ "${DOMAIN}" == "**None**" ]; then
    echo "Please set DOMAIN"
    exit 1
fi

cd ${MY_FILES}

if [ "${BASE_KEY}" ]
then
    curl -o "base.key" "${BASE_KEY}"
else
    openssl genrsa -out base.key 2048
fi

if [ "${DEVICE_KEY}" ]
then
    curl -o "device.key" "${DEVICE_KEY}"
else
    openssl genrsa -out device.key 2048
fi

if [ "${BASE_PEM}" ]
then
    curl -o "base.pem" "${BASE_PEM}"
else
    openssl req -new -x509 -nodes -key base.key -days 10000 -subj "/CN=${DOMAIN}" -out base.pem
fi

if [ "${DEVICE_CSR}" ]
then
    curl -o "device.csr" "${DEVICE_CSR}"
else
    openssl req -new -key device.key -subj "/CN=${DOMAIN}" -out device.csr
fi

if [ "${DEVICE_CRT}" ]
then
    curl -o "device.crt" "${DEVICE_CRT}"
    curl -o "base.srl" "${BASE_SRL}"
else
    openssl x509 -req -in device.csr -CA base.pem -CAkey base.key -CAcreateserial -days 10000 -out device.crt
fi

cp -r base.pem /ngrok/assets/client/tls/ngrokroot.crt

cd /ngrok
make release-server
GOOS=linux GOARCH=386 make release-client
GOOS=linux GOARCH=amd64 make release-client
GOOS=windows GOARCH=386 make release-client
GOOS=windows GOARCH=amd64 make release-client
GOOS=darwin GOARCH=386 make release-client
GOOS=darwin GOARCH=amd64 make release-client
GOOS=linux GOARCH=arm make release-client

cp -r /ngrok/bin ${MY_FILES}/bin

curl --upload-file /ngrok/bin/ngrok https://transfer.sh/ngrok
echo "build ok !"

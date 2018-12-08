touch /var/log/api-server.log
go get github.com/gorilla/mux
go install api-server
api-server 2>/var/log/api-server.log &
apt update 2&>/dev/null
/bin/bash
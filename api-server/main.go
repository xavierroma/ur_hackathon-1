package main

import (
	"log"
	"net/http"
)

func main() {

	router := NewRouter()

	log.Println(http.ListenAndServe(":80", router))
}

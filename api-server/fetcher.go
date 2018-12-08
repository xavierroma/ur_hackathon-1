package main

import (
	"net"
)

func createBuffer(network string, address string) {
	_, err := net.Dial("tcp", "ur-sim-container:30001")
	if err != nil {
		// handle error
	}

	//return bufio.NewReader(conn)
}


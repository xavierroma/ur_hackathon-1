package main

import (
	"bufio"
	"net"
)

func createBuffer(network string, address string) *Reader {
	conn, err := net.Dial("tcp", "ur-sim-container:30001")
	if err != nil {
		// handle error
	}

	return bufio.NewReader(conn)
}


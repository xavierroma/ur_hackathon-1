package main

import (
	"bufio"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

func Index(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Welcome!\n")
}




func TodoIndex(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(todos); err != nil {
		panic(err)
	}
}

func TodoShow(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	var todoId int
	var err error
	if todoId, err = strconv.Atoi(vars["todoId"]); err != nil {
		panic(err)
	}
	todo := RepoFindTodo(todoId)
	if todo.Id > 0 {
		w.Header().Set("Content-Type", "application/json; charset=UTF-8")
		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(todo); err != nil {
			panic(err)
		}
		return
	}

	// If we didn't find it, 404
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusNotFound)
	if err := json.NewEncoder(w).Encode(jsonErr{Code: http.StatusNotFound, Text: "Not Found"}); err != nil {
		panic(err)
	}

}

/*
Test with this curl command:

curl -H "Content-Type: application/json" -d '{"name":"New Todo"}' http://localhost:8080/todos

*/
func TodoCreate(w http.ResponseWriter, r *http.Request) {
	var todo Todo
	body, err := ioutil.ReadAll(io.LimitReader(r.Body, 1048576))
	if err != nil {
		panic(err)
	}
	if err := r.Body.Close(); err != nil {
		panic(err)
	}
	if err := json.Unmarshal(body, &todo); err != nil {
		w.Header().Set("Content-Type", "application/json; charset=UTF-8")
		w.WriteHeader(422) // unprocessable entity
		if err := json.NewEncoder(w).Encode(err); err != nil {
			panic(err)
		}
	}

	t := RepoCreateTodo(todo)
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusCreated)
	if err := json.NewEncoder(w).Encode(t); err != nil {
		panic(err)
	}
}


func SimTest(w http.ResponseWriter, r *http.Request) {

	conn, err := net.Dial("tcp", "ur-sim-container:30001")
	if err != nil {
		// handle error
	}


	connbuf := bufio.NewReader(conn)
	size := make([]byte, 4)
	_, _ = connbuf.Read(size)
	bytes := make([]byte, binary.BigEndian.Uint32(size[0:4])-4)
	_, _ = connbuf.Read(bytes)

	fmt.Println(bytes)
	fmt.Println(binary.BigEndian.Uint32(size[0:4])-4)

	size = make([]byte, 4)
	_, _ = connbuf.Read(size)
	bytes = make([]byte, binary.BigEndian.Uint32(size[0:4])-4)
	_, _ = connbuf.Read(bytes)

	fmt.Println(bytes)
	fmt.Println(binary.BigEndian.Uint32(size[0:4])-4)

	size = make([]byte, 4)
	_, _ = connbuf.Read(size)
	bytes = make([]byte, binary.BigEndian.Uint32(size[0:4])-4)
	_, _ = connbuf.Read(bytes)

	fmt.Println(bytes)
	fmt.Println(binary.BigEndian.Uint32(size[0:4])-4)

	size = make([]byte, 4)
	_, _ = connbuf.Read(size)
	bytes = make([]byte, binary.BigEndian.Uint32(size[0:4])-4)
	_, _ = connbuf.Read(bytes)

	fmt.Println(bytes)
	fmt.Println(binary.BigEndian.Uint32(size[0:4])-4)

	size = make([]byte, 4)
	_, _ = connbuf.Read(size)
	bytes = make([]byte, binary.BigEndian.Uint32(size[0:4])-4)
	_, _ = connbuf.Read(bytes)

	fmt.Println(bytes)
	fmt.Println(binary.BigEndian.Uint32(size[0:4])-4)

	size = make([]byte, 4)
	_, _ = connbuf.Read(size)
	bytes = make([]byte, binary.BigEndian.Uint32(size[0:4])-4)
	_, _ = connbuf.Read(bytes)

	fmt.Println(bytes)
	fmt.Println(binary.BigEndian.Uint32(size[0:4])-4)

	size = make([]byte, 4)
	_, _ = connbuf.Read(size)
	bytes = make([]byte, binary.BigEndian.Uint32(size[0:4])-4)
	_, _ = connbuf.Read(bytes)

	fmt.Println(bytes)
	fmt.Println(binary.BigEndian.Uint32(size[0:4])-4)

	size = make([]byte, 4)
	_, _ = connbuf.Read(size)
	bytes = make([]byte, binary.BigEndian.Uint32(size[0:4])-4)
	_, _ = connbuf.Read(bytes)

	fmt.Println(bytes)
	fmt.Println(binary.BigEndian.Uint32(size[0:4])-4)

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)
	/*if err := json.NewEncoder(w).Encode(todo); err != nil {
		panic(err)
	}*/

	err = conn.Close()
	if err != nil {
		fmt.Print(err)
	}
	return

}

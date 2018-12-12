package main

import (
	"bufio"
	"bytes"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"io"
	"io/ioutil"
	"net"
	"net/http"
	"strconv"
	"unsafe"
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

func getLog(w http.ResponseWriter, r *http.Request) {

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	b, err := ioutil.ReadFile("/var/log/api-server.log") // just pass the file name
	if err != nil {
		fmt.Print(err)
	}

	fmt.Fprint(w, string(b))

}

func getInfo(w http.ResponseWriter, r *http.Request) {

	var pkg_num int
	var err error

	vars := mux.Vars(r)

	if pkg_num, err = strconv.Atoi(vars["pkg_num"]); err != nil {
		panic(err)
	}

	parseInfo(pkg_num)

}

//https://golang.org/doc/articles/wiki/
func parseInfo(infoType int) {

	//var readType int
	var read_type = 0
	conn, err := net.Dial("tcp", "ur-sim-container:30001")
	if err != nil {
		// handle error
	}

	connbuf := bufio.NewReader(conn)

	var size_read uint32
	var pkg_size uint32 = 0
	var curr_size uint32 = 0

	for time := 0; time < 20; time++ {

		size := make([]byte, 4)
		_, _ = connbuf.Read(size)
		pkg_size = binary.BigEndian.Uint32(size)

		pkg_type, _ := connbuf.ReadByte()

		if pkg_type == 16 {
			curr_size = 0
			for curr_size < pkg_size {

				size = make([]byte, 4)
				_, _ = connbuf.Read(size)
				curr_size += binary.BigEndian.Uint32(size)
				pkg_type, _ = connbuf.ReadByte()
				read_type = int(pkg_type)

				bytes := make([]byte, binary.BigEndian.Uint32(size[0:4])-5)
				_, _ = connbuf.Read(bytes)
				size_read = binary.BigEndian.Uint32(size[0:4]) - 5

				if infoType == read_type {

					bytes := make([]byte, size_read)
					_, _ = connbuf.Read(bytes)
					preparestructure(read_type, bytes)
					return
				}

			}
		} else {
			bytes := make([]byte, binary.BigEndian.Uint32(size[0:4])-5)
			_, _ = connbuf.Read(bytes)

		}

	}

}

func preparestructure(structure int, information []byte) {

	switch structure {

	case RobotModeData:
		break
	case JointData:
		fmt.Println("Structure#: JointData information: ", information)

		fmt.Println(information)
		fmt.Println(len(information))
		estructura := [6]IndividualJoint{}

		bits := binary.BigEndian.Uint32(information[24:28])
		n2 := uint32(bits)
		f := *(*float32)(unsafe.Pointer(&n2))
		fmt.Println(f)

		err := binary.Read(bytes.NewBuffer(information), binary.BigEndian, &estructura)
		if err != nil {
			fmt.Println(err)
		}
		//fmt.Printf("vaal %d", estructura[0].ActJointCurrent)
		fmt.Println(information[0:8])
		break
	case ToolData:
		break
	case MasterboardData:
		break
	case CartesianData:
		break
	case KinematicsData:
		break
	case ConfigurationData:
		break
	case ForceModeData:
		break
	case AdditionalData:
		break
	case CalibrationData:
		break
	case SafetyData:
		break
	case ToolCommData:
		break

	}

}

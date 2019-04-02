import socket
import sys
import threading
import logging
import rtde
import rtde_config
from rtde import serialize
from time import sleep
import json

class RobotComunication:

    def __init__(self, data):
        self.data = data
        self.robot_connected = False

    def init_robot_com(self, HOST, ROBOT_PORT):
        logging.basicConfig(level=logging.INFO)

        conf = rtde_config.ConfigFile('record_configuration.xml')
        self.output_names, self.output_types = conf.get_recipe('out')

        self.robot_con = rtde.RTDE(HOST, ROBOT_PORT)

        try:
            self.robot_con.connect()

            # get controller version
            self.robot_con.get_controller_version()

            # setup recipes
            if not self.robot_con.send_output_setup(self.output_names, self.output_types, frequency=250):
                logging.error('Unable to configure output')
                return

            # start data synchronization
            if not self.robot_con.send_start():
                logging.error('Unable to start synchronization')
                return

            self.robot_connected = True

        except:
            logging.error("Can not connect to the robot")
            return

    def update_robot_data(self):

        keep_running = True
        while keep_running:

            try:
                state = self.robot_con.receive()
                if state is not None:
                    data = []
                    self.data.data = []
                    for i in range(len(self.output_names)):
                        size = serialize.get_item_size(self.output_types[i])
                        value = state.__dict__[self.output_names[i]]
                        if size > 1:
                            data.extend(value)
                        else:
                            data.append(value)
                        self.data.data.append(value)

                else:
                    self.robot_connected = False
                    return

            except KeyboardInterrupt:
                keep_running = False
                sys.exit(1)

        self.robot_con.send_pause()
        self.robot_con.disconnect()


class ClientComunication(threading.Thread):

    def __init__(self, conn, rob_com, data, server):
        threading.Thread.__init__(self)
        self.rob_com = rob_com
        self.data = data
        self.server = server
        self.conn = conn
        self.alive = threading.Event()
        self.alive.set()

    def run(self):

        while self.rob_com.robot_connected:

            try:
                command = self.conn.recv(1024).decode()
                # logging.info('Recieved: ' + str(command))

                if not command:
                    self.conn.close()
                    self.server.client_connexions.remove(self.conn)
                    break
                
                returnJson = False
                if '_json' in command:
                    returnJson = True
                    command = command.replace('_json', '')
                    response = self.data.get_data(command)
                if response == -1:
                    self.conn.send(str('ERROR').encode())
                elif (returnJson):
                    returnString = json.dump(json.load(response))
                    self.conn.send(str(returnString).encode())
                else:
                    self.conn.send(str(response).encode())

            except KeyboardInterrupt:
                self.server.close()
                sys.exit()

        logging.info("Client disconnected")

class Server(threading.Thread):

    def __init__(self, rob_com, data, CLIENTS_PORT):
        threading.Thread.__init__(self)
        self.sock_client_server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.client_connexions = []
        self.rob_com = rob_com
        self.data = data
        self.alive = threading.Event()
        self.alive.set()
        self._stop_event = threading.Event()

        while (True):
            try:
                self.sock_client_server.bind(('0.0.0.0', CLIENTS_PORT))
                self.sock_client_server.listen(64)
                break
            except:
                logging.error("Can not do the socket bind")
                sleep(0.5)

    def run(self):
        logging.info('Waiting for Clients...')
        while self.rob_com.robot_connected:
            try:
                conn, addr = self.sock_client_server.accept()
                logging.info('[CLIENT] Connected by' + str(addr))
                self.client_connexions.append(conn)

                client_com = ClientComunication(conn, self.rob_com, self.data, self)
                client_com.daemon = True
                client_com.start()

            except KeyboardInterrupt:
                self.close()
                sys.exit()
                
        self.close()

    def stopped(self):
        return self._stop_event.is_set()

    def stop(self):
        self._stop_event.set()
        
    def close(self):
        for conn in self.client_connexions:
            logging.info('Closing connection: ' + str(conn))
            conn.close()
            self.client_connexions.remove(conn)
        self.sock_client_server.close()
        self._stop_event.set()


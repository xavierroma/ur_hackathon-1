from firebase import firebase
import asyncio
import json
import logging
import websockets
import socket
from time import sleep

base = 'bash /root/services/alexa_server/alexa.sh -d "Robot" -e speak:'
logging.basicConfig()
firebase = firebase.FirebaseApplication('https://ur-hackathon.firebaseio.com/', None)

def handleStatusBit(safety, robot):
    if (safety == '1028'):
        return 'Parada de proteccion, hasta que me habilites en la interficie no me movere'
    elif (safety == '1216'):
        return 'Aviso, paro de emergencia, repito, paro de emergencia'
    elif (safety == '1536'):
        return 'Error critico, por favor consulta la interficie para mas informacion'
    elif (safety == '1'):
        return 'Ya estoy de nuevo en modo normal'
    else:
        return 'Estoy en un estado de proteccion desconocido.'

def updateFirebaseNotification():
    toStore = {}
    toStore['causer'] = 'Robot #23452'
    toStore['value'] = response
    firebase.push('/notifications/list', toStore)  
    firebase.set('/notifications/read_status', 0)

try:
    conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    safety_status = '0'
    robot_status = '0'
    logging.info('Starting service...')
    conn.connect(('localhost', 30100)) 
    while (True):
        try:
            conn.send(('safety_status_bits').encode())
            safety = conn.recv(4096).decode()
            conn.send(('robot_status_bits').encode())
            robot = conn.recv(4096).decode()
            if (safety_status != safety):
                response = handleStatusBit(safety, robot)
                jsonResponse = {}
                jsonResponse['action'] = 'speak'
                jsonResponse['value'] = response
                alexa = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                alexa.connect(('localhost', 30102)) 
                alexa.send((json.dumps(jsonResponse)).encode())
                alexa.close()
                logging.info('Changing status from ' + safety_status + ' to ' + safety)
                safety_status = safety
                logging.info('Sending to Alexa: ' + json.dumps(jsonResponse))
            sleep(0.5)
            
        except Exception as err:
            logging.error('Disconnecting due to exception ' + str(err))
    
except Exception as err:
    logging.error('Disconnecting due to exception ' + str(err))
    conn.close()
    
conn.close()
logging.info('Disconnecting...')

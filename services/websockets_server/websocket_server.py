import asyncio
import json
import logging
import websockets
import socket
from time import sleep

logging.basicConfig()

def handleCommand(command, conn):
    logging.info(command)
    conn.send(str(command).encode())
    return conn.recv(1024).decode()

async def handler(websocket, path):
    try: 
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s: 
            s.connect(('localhost', 30100)) 
            while True:
                command = await websocket.recv()
                response = handleCommand(command, s)
                await websocket.send(response)
    except Exception as err: 
        await websocket.send("Failed with error %s" %(err))

asyncio.get_event_loop().run_until_complete(
    websockets.serve(handler, '0.0.0.0', 30101))
asyncio.get_event_loop().run_forever()

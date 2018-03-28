#!/usr/bin/python
import obd, sys, subprocess, socket
from time import sleep

subprocess.Popen(["bash", "setNetwork.sh 1"])

UDP_IP = "192.168.1.2"
UDP_PORT = 5005
MESSAGE = "Hello World"

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

#conn = obd.OBD()
#c = obd.commands[1][13]
while True:
    #r = conn.query(c)
    #print(r)
    sock.sendto(MESSAGE, (UDP_IP, UDP_PORT))
    sleep(0.01)

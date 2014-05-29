#!/usr/bin/python

import serial
import os
import pprint

while True:
  port = None
  while port == None:
    for filename in os.listdir("/dev/"):
      if filename.startswith("tty.usbmodem"):
        port = "/dev/" + filename
  
  s = serial.Serial(port="/dev/tty.usbmodem621", baudrate = 115200)
  #s = serial.Serial(port= port, baudrate = 115200)
  try:  
    print "connected to " + port
    while True:
      line = s.readline()
      print line
  except Exception, e:
    pprint.pprint(e)
    pass


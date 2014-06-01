#!/usr/bin/python

import serial
import os
import pprint
import sys

while True:
  port = None
  if len(sys.argv) == 2:
    port = sys.argv[1]

  while port == None:
    for filename in os.listdir("/dev/"):
      if filename.startswith("tty.usbmodem"):
        port = "/dev/" + filename
  
  try:  
    s = serial.Serial(port = port, baudrate = 115200)
    print "connected to " + port
    while True:
      line = s.readline()
      print line
  except Exception, e:
    pprint.pprint(e)
    pass


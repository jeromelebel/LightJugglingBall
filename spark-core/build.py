#!/usr/bin/python

import os
import shutil
import sys

MY_SOURCE = "src"
SPARK_FIRMWARE = "core-firmware"
SUBMODULES = [ SPARK_FIRMWARE, "core-common-lib", "core-communication-lib" ]
SPARK_SOURCES = SPARK_FIRMWARE + "/src"
SPARK_HEADERS = SPARK_FIRMWARE + "/inc"
FILES = { ".cpp": { "destination": SPARK_SOURCES }, ".c": { "destination": SPARK_SOURCES }, ".h": { "destination": SPARK_HEADERS } }

def clean():
  os.system("git submodule update --init")
  current_dir = os.getcwd()
  os.chdir(SPARK_FIRMWARE)
  os.system("git checkout .")
  os.system("git clean -f")
  os.chdir(current_dir)
  for submodule in SUBMODULES:
    os.chdir(submodule)
    os.system("git checkout master")
    os.chdir(current_dir)
  os.chdir(SPARK_FIRMWARE + "/build")
  os.system("make clean")
  os.chdir(current_dir)

def copy_mysource():
  source_list = []
  for filename in os.listdir(MY_SOURCE):
    extension = os.path.splitext(filename)[1]
    if extension in FILES:
      destination = FILES[extension]["destination"]
      if os.path.exists(destination + "/" + filename):
        print(destination + "/" + filename + " already exists")
        break
      shutil.copy2(MY_SOURCE + "/" + filename, destination)
      if extension == ".cpp" or extension == ".c":
        source_list.append(filename)
  with open(SPARK_SOURCES + "/mysource.mk", "w") as file:
    for filename in source_list:
      file.write("CPPSRC += $(TARGET_SRC_PATH)/" + filename + "\n")
  with open(SPARK_SOURCES + "/build.mk", "a") as file:
    file.write("include ../src/mysource.mk\n")

if len(sys.argv) == 2 and "clean" == sys.argv[1]:
  clean()
elif len(sys.argv) == 2 and "cleanup" == sys.argv[1]:
  clean()
  copy_mysource()
else:
  os.system("rsync -a " + MY_SOURCE +"/ " + SPARK_SOURCES)
  os.chdir(SPARK_FIRMWARE)
  os.chdir("build")
  os.system("make")
  pass

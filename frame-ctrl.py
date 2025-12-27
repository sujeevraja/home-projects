#!/usr/bin/env python3

import os
import struct
import sys
import time
import usb.core
from usb.util import *

vendorId = 0x04e8
models = {
    'SPF-85H': (0x2012, 0x2013),
    'SPF-87H': (0x2033, 0x2034),
    'SPF-107H': (0x2027, 0x2028),
}

chunkSize = 0x4000
bufferSize = 0x20000

def expect(result, verifyList):
    # result from PyUSB is usually an array.array
    resultList = result.tolist()
    if resultList != verifyList:
        print(f"Warning: Expected {verifyList} but got {resultList}", file=sys.stderr)

def storageToDisplay(dev):
    print("Setting device to display mode")
    try:
        dev.ctrl_transfer(CTRL_TYPE_STANDARD | CTRL_IN | CTRL_RECIPIENT_DEVICE, 0x06, 0xfe, 0xfe, 254)
    except usb.core.USBError as e:
        errorStr = str(e)
        if 'No such device' not in errorStr:
            raise e

def displayModeSetup(dev):
    print("Sending setup commands to device")
    result = dev.ctrl_transfer(CTRL_TYPE_VENDOR | CTRL_IN | CTRL_RECIPIENT_DEVICE, 0x04, 0x00, 0x00, 1)
    expect(result, [0x03])

def paddedBytes(buf, size):
    diff = size - len(buf)
    # Ensure we are adding actual bytes
    return buf + (b'\x00' * diff)

def chunkyWrite(dev, buf):
    pos = 0
    while pos < bufferSize:
        dev.write(0x02, buf[pos:pos+chunkSize])
        pos += chunkSize

def writeImage(dev):
    # Important: Open files and stdin in Binary Mode ('rb')
    if len(sys.argv) < 2 or sys.argv[1] == "-":
        content = sys.stdin.buffer.read() 
    else:
        with open(sys.argv[1], 'rb') as f:
            content = f.read()

    size = struct.pack('I', len(content))
    header = b'\xa5\x5a\x09\x04' + size + b'\x46\x00\x00\x00'

    content = header + content

    pos = 0
    while pos < len(content):
        buf = paddedBytes(content[pos:pos+bufferSize], bufferSize)
        chunkyWrite(dev, buf)
        pos += bufferSize

found = False

for k, v in models.items():
    dev = usb.core.find(idVendor=vendorId, idProduct=v[0])
    if dev:
        print(f"Found {k} in storage mode")
        storageToDisplay(dev)
        time.sleep(1)
        dev = usb.core.find(idVendor=vendorId, idProduct=v[1])
        found = True
    
    if not dev:
        dev = usb.core.find(idVendor=vendorId, idProduct=v[1])
        
    if dev:
        print(f"Found {k} in display mode")
        dev.set_configuration()
        displayModeSetup(dev)
        writeImage(dev)
        found = True

if not found:
    print("No supported devices found", file=sys.stderr)
    sys.exit(-1)

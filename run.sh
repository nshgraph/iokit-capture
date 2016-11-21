#!/bin/bash

DYLD_FORCE_FLAT_NAMESPACE=1 DYLD_INSERT_LIBRARIES=build/iohid_capture.dylib /Applications/RemotePlay.app/Contents/MacOS/RemotePlay
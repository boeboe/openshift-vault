#!/bin/sh
#
# Small ready check script to check the status of this consul instance:
#
#  * we retry 5 seconds for port 8500 to be listening
#  * returns 1 if port 8500 not ready
#  * returns 0 if port 8500 ready
#
set -x

if netstat -ln | grep -q 8500 ; then return 0 ; fi
return 1

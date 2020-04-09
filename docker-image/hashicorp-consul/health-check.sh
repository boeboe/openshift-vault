#!/bin/sh
#
# Small health check script to check the status of this consul instance:
#
#  * we check for port 8500 to be listening
#  * if listening, we do a consul HTTP call to check the health
#  * returns 1 if port 8500 not ready
#  * returns 2 of health API returns issue
#  * returns 0 if health status is passing
#
set -x

if netstat -ln | grep -q 8500 ; then

    HEALTH=`curl http://localhost:8500/v1/health/node/${HOSTNAME}`

    if [ ! $? -eq 0 ] ; then return 2 ; fi

    if echo ${HEALTH} | jq '.[].Status' | grep -q "passing"; then
        return 0
    else
        return 2
    fi

fi

return 1

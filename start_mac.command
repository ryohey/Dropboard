#!/bin/bash
CURDIR=`dirname $0`
cd $CURDIR/node
killall node
./node_ server.js & open http://localhost:3141/
read WAIT
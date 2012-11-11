#!/bin/bash
CURDIR=`dirname $0`
cd $CURDIR
killall node_
./node_ server.js & open http://localhost:3141/
#!/bin/bash
cd $(dirname $0)
cd ../../../node
killall node
./node_ server.js & open http://localhost:3141/
read WAIT
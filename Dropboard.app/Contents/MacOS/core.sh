#!/bin/bash
killall node_
cd $(dirname $0)
cd ../Resources/node
ls
./node_ server.js & open http://localhost:3141/
read WAIT
#!/bin/bash

/init.sh 

exec supervisord -n

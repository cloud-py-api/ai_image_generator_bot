#!/bin/bash

if [ -f "/.installed_flag" ]; then
	exit 0
else
	exit 1
fi

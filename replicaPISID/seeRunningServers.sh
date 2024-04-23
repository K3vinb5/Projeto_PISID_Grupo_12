#!/bin/bash

lsof -i -P -n | grep LISTEN | grep "$(pgrep mongod)"

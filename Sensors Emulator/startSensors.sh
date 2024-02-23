#!/bin/bash

(trap 'kill 0' SIGINT; python simulalabirinto.py & python simulatemp.py)


#!/bin/bash

(trap 'kill 0' SIGINT; python3 simulalabirinto.py & python3 simulatemp.py)


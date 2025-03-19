#!/bin/bash
set -e

echo "Running python3 lib/fetch.py fetch-all"
python3 lib/fetch.py fetch-all

echo "Running python3 -u bin/srv.py"
python3 -u bin/srv.py

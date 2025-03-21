#!/bin/sh
set -e

echo "Running python3 lib/fetch.py fetch-all"
python3 /app/lib/fetch.py fetch-all

echo "Running python3 -u bin/srv.py"
python3 -u /app/bin/srv.py

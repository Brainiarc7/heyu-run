#! /bin/sh

echo "Compile and test..."
./scripts/run_test.sh
echo "Pushing script across..."
scp bin/heyu-run.js root@192.168.1.1:
scp lib/*js root@192.168.1.1:lib
echo "Test remote... "
ssh root@192.168.1.1 "js heyu-run.js --test"
echo "Run remote... " $*
ssh root@192.168.1.1 "js heyu-run.js --dry-run $*"
ssh root@192.168.1.1 "js heyu-run.js $* | sh"
ssh root@192.168.1.1 "js heyu-run.js --dry-run --state"

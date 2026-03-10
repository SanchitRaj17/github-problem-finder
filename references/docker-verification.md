# Docker Verification (exact commands)

Run these commands exactly and in order.
Expectations: base must pass, new must fail before solution; base and new must pass after solution.

```bash
git apply test.patch
docker build -t <<repo name>> .
docker run -t --network=none <<repo name>> ./test.sh base
docker run -t --network=none <<repo name>> ./test.sh new
git apply solution.patch
docker build -t <<repo name>> .
docker run -t --network=none <<repo name>> ./test.sh base
docker run -t --network=none <<repo name>> ./test.sh new
```
Replace <<repo name>> with actual repo name

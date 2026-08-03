# parallel-first-outcome-wins

This test scenario verifies that the auth requests to the configured `targets`
are issued **in parallel** and that the **first outcome counts**, whether it is
positive or negative.

How it works:

1. A mock android server (`mock/main.go`) is built and started in the
   background inside the container. It exposes two auth endpoints on localhost:
   - `127.0.0.1:18081` answers with authentication success **after 12 seconds**
   - `127.0.0.1:18082` answers with authentication success **immediately**
2. `alp.yaml` lists the **slow** endpoint first and the **fast** endpoint
   second.
3. An authentication attempt is made by running `su root`, which triggers the
   `alp auth` request through `pam_exec`.
4. The test asserts that:
   - the authentication **succeeds** (`su root` exit code 0), and
   - it completes in under 8 seconds, i.e. well before the slow endpoint's 12s
     delay. This proves the requests went out in parallel and the fast
     endpoint's (first) outcome won.

If the requests were executed sequentially, `su root` would only return after
the slow endpoint answered (~12s) and the test would fail the timing
assertion.

# snippet to run this test standalone
```
(cd linux && docker build . -f test/docker-scenarios/parallel-first-outcome-wins/Dockerfile -t test --progress=plain)
```
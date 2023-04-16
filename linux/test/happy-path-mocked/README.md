# happy-path-mocked

This test scenario sets up pam in a Docker Image build to use alp as the main authentication
mechanism.

Then, an authenication attempt is made by running the `su root` command.

The authentication should succeed (zero exit code of alp) because alp is called with the parameter `--mockSuccess true`).

# snippet to run this test standalone
```
(cd linux && docker build . -f test/happy-path-mocked/Dockerfile -t test --progress=plain)
```
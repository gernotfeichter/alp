# linux/test/fallback-to-password-prompt-bad-password

This test scenario sets up pam in a Docker Image build to use alp as the main authentication
mechanism.

Then, an authenication attempt is made by running the `sudo cat /etc/shadow` command.

The authentication should fail ( non-zero exit code of alp), whithin the 15s default timeout because
- alp is not connected to a real android device
- nor did the fallback authentication succeed (password prompt was answered with the wrong password).

# snippet to run this test standalone
```
(cd linux && docker build . -f test/docker-scenarios/fallback-to-password-prompt-bad-password/Dockerfile -t test --progress=plain)
```
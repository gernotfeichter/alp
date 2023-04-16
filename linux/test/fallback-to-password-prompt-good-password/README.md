# linux/test/fallback-to-password-prompt-good-password

This test scenario sets up pam in a Docker Image build to use alp as the main authentication
mechanism.

Then, an authenication attempt is made by running the `sudo cat /etc/shadow` command.

The authentication should succeed (zero exit code of alp) in the following authentication flow:
1. alp authentication will fail (whithin the 15s default timeout) because it is not connected to a real android device
2. the fallback authentication to using a password should succeed, since the password prompt is successfully answered.

# snippet to run this test standalone
```
(cd linux && docker build . -f test/fallback-to-password-prompt-good-password/Dockerfile -t test --progress=plain)
```

# alp - android-linux-pam

Alp is a convenient - yet secure - authentication method that lets you use your android device as a key for your linux machine.

# installation

## linux
TODO: Gernot

## android
TODO: Gernot

# authentication flow

> the following assumes that the user followed the standard installation method and uses alp in 'common-auth' (in linux PAM terms)

## success case
1. user does something on a linux machine that requires authentication, e.g. you log in to your desktop environment
2. on a previously paired android smartphone a notification pops up, where you may
   - approve
   - deny
   - time out

   the authentication request.

## error case
In case the user lets the authentication request time out, the authencation will fallback to the systems previous authentication method.
On 99% of installations, that will be a password prompt.

# reasons to use alp
- typing passwords sucks
- you own an android device
- you do not want or cannot use face unlock (e.g. [howdy](https://github.com/boltgolt/howdy)) for whatever reasons, for me those were
  - no webcam at each machine (main reason)
  - less secure than conventional passwords
  - you mostly stare at the screen - that means if an authentication prompt pops up and you do not explicitly look away - you will authorize whatever pops up.
    Nevertheless, reality teaches that there is a certain delay till the face is detected - which is normally enough to react and look away.
  Overall I can still recommend howdy as a valueable alternative solution.
- fingerprint sensor support on linux is bad and fingerprints in general have their problems.
  Do you want to secure your device with something that most likely always exists on the device you are trying to protect?

# a few words on security
- In alp you trust your android device, you can even think of your android device as a key to your linux device.
- The level of security will depend on the level of security of your android device.
- TLS (standard, banking-grade security mechanism) is used to protect the communication between your smartphone and your linux machine.
- Your linux passwords are NOT transferred to or known by your android device.

# components overview
- [linux](linux): go grpc client 
- [android](android): flutter grpc server

# license
[GNU GENERAL PUBLIC LICENSE - Version 2](LICENSE)

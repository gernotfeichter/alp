# alp - android-linux-pam

> DEVELOPMENT IS STILL ONGOING! NOT USABLE ATM!

Alp is a convenient - yet secure - authentication method that lets you use your android device as a key for your linux machine.

The idea of alp is, instead of typing a password on the linux machine, the user only clicks a button on an android device to confirm an authentication/authorisation request.

I realized that in traditional PC setups, the user is confronted with either
- using a secure password that is labour intensive to type or
- using a less secure password that is still annoying to be typed because of the frequency.

Alp attempts to solve that usability problem!

The solution proposed assumes that the user owns an android device that is on the same wifi network. The solution also works if the android phone is the hotspot of the linux machine.

> Note that alp does not "remove" your password. Per default the authentication and authorisation process tries to use alp, but as a fallback, the "traditional" fallback authentication and authorisation process - on most systems that will be a password promt - kicks in. Since alp is using https://github.com/linux-pam/linux-pam, quite something could be tweaked when having knowledge of pam.

This solution works on, and is intended for single user linux machines.
Thought it should also work for mac users.

In any case, the users also needs to have an android device.
If another maintainer is interested to compile/test/release an ios version, I am open for merging such a PR.

> It does not work for machines that are operated by different users, nor is such support currently planned - unless all users are okay to share the same super users password!

Apart from the described default solution, there is an even more innovative, but arguably less secure mode where even the button click is optional in the positive case. Read more on the [lazy auth mode](#lazy-auth-mode) below.

# installation

## linux | mac

⚠ The installation procedure hooks alp deeply into the main system authentication mechanism, creating a full system backup is recommended before installation!

In a terminal, perform the following steps:
1. Choose your platform
   ```
   ARCH=Darwin_arm64
   ARCH=Darwin_x86_64
   ARCH=Linux_arm64
   ARCH=Linux_i386
   ARCH=Linux_x86_64
   ```
   ⚠ Really choose one, do not execute all of the commands above!
2. Download and Install your package
   ```
   cd /tmp
   PACKAGE_FILE="alp_${ARCH}.tar.gz"
   wget "https://github.com/gernotfeichter/alp/releases/download/1.0.4/${PACKAGE_FILE}"
   tar -xvf "${PACKAGE_FILE}"
   sudo install -o root -g root -m 4755 ./alp /usr/sbin/alp
   ```
3. Initialize alp
   
   ⚠ Replace the `<IP>` parameter below with the IP:Port values from your android device in below code snippet.
   Hint: You find these in the settings screen of the [android alp app](#android)!
   ```
   sudo alp init -t <IP>:7654
   ```
   It is recomended that you use alp in a local wifi network and to reserve a dhcp lease in your router,
   such that you always get assigned a fixed IP address.
   Or, if your android phone is your hotspot, simply run:
   ```
   sudo alp init
   ```
4. Now proceed with the android part!
## android
TODO: Gernot

# authentication flow

> the following assumes that the user followed the standard installation thereby uses alp in 'common-auth' (in linux PAM terms)

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
- pre shared key based encyption (aes 256 gcm pbkdf2) is used to protect the communication between your smartphone and your linux machine.
- Your linux passwords are NOT transferred to or known by your android device.

## lazy auth mode

⚠ This mode is less secure and thereby NOT enabled per default.

According to ChatGPT (18.06.2023), there is no known authentication mechanism of this kind.

In this mode, the authentication request is
1. sent to the android phone
2. if the alp server running on the phone is reachable AND the user does not click `Deny` within the configured timeout, the auth request is approved.

This mode requires an "always on" mentality of the user, constantly observing the state of the smartphone to be considered secure, which is certainly hard to achieve continously. However, since most useres will have their smartphone lying besides their linux machines anyway, maybe there is a group of users that finds this feature valuable.
Especially before sleep, one should not forget to disable wifi in this mode to not make oneself vulnerable when "always on" is certainly not possible.

You may enable this mode in the android app's settings if you feel you want to take the extra risk involved.

# components overview
- [linux](linux): go REST client
- [android](android): flutter REST server

# license
[GNU GENERAL PUBLIC LICENSE - Version 2](LICENSE)

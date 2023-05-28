# shared

Contains things that are shared among the android and linux subprojects.

# rest request logging
The used http libraries (both in linux and android part) seem to not offer built in support for request logging.
I am therefore using the following command/tool (adapt the interface name after -i!):
```
sudo tcpflow -p -c -i wlp8s0 port 7654
```
Draft readme, it will be expanded later.


Building the image
------------------

    $ docker build -t jcberthon/ntpd .
    Sending build context to Docker daemon 2.048 kB
    Step 1 : FROM ubuntu:16.04
     ---> 45bc58500fa3
    Step 2 : RUN apt-get update     && apt-get install -y --no-install-recommends ntp     && apt-get clean -q
     ---> Using cache
     ---> 0f5f582925db
    Step 3 : ENTRYPOINT /usr/sbin/ntpd
     ---> Running in 967ce652fadf
     ---> 8ac170521e9c
    Removing intermediate container 967ce652fadf
    Successfully built 8ac170521e9c

Running the image
-----------------

The ntp daemon needs to modify the system time of the host kernel. In addition, the daemon tries to lock some of its memory to avoid being swapped. Therefore, we need to provide a few privileges to our container if we want the daemon to control the clock on the host.

    $ docker run --cap-add SYS_TIME --cap-add SYS_RESOURCE jcberthon/ntpd -n


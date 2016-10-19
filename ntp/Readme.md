A NTP server in a container (docker variant)
============================================

While I'm trying to learn more about LXC (and LXD) and Docker with the goal to see the advantages and inconveniences of both solutions, I decided to try to put a NTP server (stratum 3) in a container and why not make it run on my Raspberry Pi to provide the time for my other LAN devices.

My first and current attempt is to run it on a standard PC (x86_64) and try to understand how to run it with the least privileges possible. I could simply run it as an unprivilege container, but then I won't learn much ;-)

I understand that in the end running a NTP server on a Raspberry Pi is not really smart. The Pi does not have a real-time clock (RTC), so if it loses synchronisation with the remote NTP server, the clock run really lose (possibly using the "frequency ticks" of the CPU, but with dynamic frequency that could be not so accurate). But anyway, the Pi is hackable and it is possible to add a RTC to it, and probably I could pick up an RTC component that is anyway better than those in most PC motherboards.

So in the release soon release often approach, I'm starting step-by-step. First make it run on x86_64. Then I will try to make it run on ARM on my Raspberry Pi 2. And then much later, I will think of adding a RTC component to my Pi.

_Note: the current container has been successfully tested on host (x86_64) running Docker 1.12.1 on Ubuntu 16.04 (AppArmor activated) and CentOS 7 (SELinux enabled). However, it fails on Fedora 24 with Docker 1.10.3 from Fedora official repository, or with Docker 1.12.1 from Docker official repository. On Fedora the failure is due to SELinux in case of Docker 1.10.3, but creating a policy using `sudo ausearch -c 'ntpd' --raw | sudo audit2allow -M my-ntpd; sudo semodule -X 300 -i my-ntpd.pp` solved that, however then we hit the same problem than when using Docker 1.12.1 on Fedora, the ntpd process running in our container is disallowed permission to run ntp_adjtime and step-systime. But nothing is reported in the log for a reason the permission is denied. It is like the capabilities given to the container are ignored in Fedora. I need to create a bug report... Will update soon._

Regarding the Pi, I've seen that Alpine Linux does not provide the ntp server from www.ntp.org but a variant named openntpd supported by the OpenBSD project. This is fully OK, but I know how to configure the ntp server from ntp.org, so I will start with that and first pick up another base image for the Raspberry Pi, probably Debian or Ubuntu (which ever is smaller).

Building the image
------------------

As a prerequisite, you need to have Docker properly installed (https://docs.docker.com/engine/installation/). I'm running Docker 1.12, but it should work on older version of Docker as well, at least the building instructions.

To build it, simply run the command below (the command is the line starting with `$ ` but don't type those leading characters). You can of course replace `jcberthon/ntpd` by whatever name you wish to give your image.

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

*Note: Currently the default NTPd configuration (from Ubuntu 16.04) is being used, so it just make sure your system synchronise to a pool of remote NTP server, but it can't yet provide time on your local network. That's the next step.*

The image expose the port 123 (the default NTP port) to other containers.

Running the image
-----------------

The ntp daemon needs to modify the system time of the host kernel. It is also a server running on port 123/UDP and therefore require privilege bind access. In addition, the daemon tries to lock some of its memory to avoid being swapped. Therefore, we need to provide a few privileges to our container if we want the daemon to control the clock on the host. We are going to use Linux capabilites for that, the support for this feature was added back in Docker 1.2 (https://github.com/docker/docker/blob/v1.2.0/CHANGELOG.md). And we will drop all other capabilities.

    $ docker run --name ntpd --cap-drop ALL --cap-add NET_BIND_SERVICE --cap-add SYS_TIME --cap-add SYS_RESOURCE jcberthon/ntpd -g -n -l /var/log/ntpd.log

*Note: the container run in foreground mode with this option (option `-n`), this is important for Docker so that it can keep track of the process and knows when the container should exit or not.*

In order to verify if your ntp server is running and if it is synchronised, you can use the `ntpq` command (see [ntpq man page](http://doc.ntp.org/4.2.8p4/ntpq.html) for more information).

    $ docker exec -it ntpd ntpq -pn

_Note: if you are just interested in trying out this container and run it in the foreground with logs displayed on the console, execute this instead: `docker run --rm -it --cap-drop ALL --cap-add NET_BIND_SERVICE --cap-add SYS_TIME --cap-add SYS_RESOURCE jcberthon/ntpd -g -n` and you can use Ctrl+C to stop the container. The container instance will be automatically deleted (due to the use of the `--rm` option)._

If you want to use the option `-N` (which tried to elevate the ntpd priority), with the above command you will get `set_process_priority: No way found to improve our priority`. The `ntpd` daemon will still be running, so it is not blocking, but if you want to add that capability, you need to add `--cap-add SYS_NICE` to the command line.

If you want to use this ntp server on your network, you can also publish the port by using the option `--publish 123:123/udp`.

Locally cached APT repository
=============================

The following container allow you to run a proxy for your package manager (tested with Raspbian and Ubuntu), it is based on the apt-cacher-ng application which is configured to run on a Ubuntu-based container.

It is advisable to only use it for proxying HTTP traffic. Doing the same thing for HTTPS is trickier, there are many options but none quite satisfactory (at least not in my eyes), check for yourself here: https://www.unix-ag.uni-kl.de/~bloch/acng/html/howtos.html#ssluse.

Anyway, this container will run a proxy service which will cache request to the official packages repositories of your distribution. So if you have more than one machine on your LAN, after the first download from the remote repository, all other downloads will happen locally. This can be very useful in many scenarios: your WAN connection (a.k.a. your internet or ISP connection) is extremely slow, your WAN connection is capped (e.g. you can download for free a given amount of bytes, above that limit this is either slower or you need to pay extra), or your WAN connection is not free and you pay a fee per bytes transfered.

So the container runs the proxy service, it uses the TCP port 3142 to publish it services and we need to re-publish this port on the local LAN when running the container. Finally, all clients need to be configured to go through the proxy, or nothing will change.

*Note: one cool thing about apt-cacher-ng is that if you have on one machine some locally cached packages (because you recently installed them), you can easily copy them in it and make this cached packages available to others on the LAN.*

Building the container image
----------------------------

Nothing really special, just build it.

    $ docker build -t jcberthon/pkg-proxy .

Note that the image contains a persistent file store (a data volume) which you can map to something on your host if you desire. It publishes the TCP port 3142, but unless you re-publish it to your local LAN, it will only be accessible by other Docker containers running on the same host (by default).

Running the container
---------------------

We are going to run the conainer unprivileged and in the background. I'm currently only testing it, so I did not use the `--restart` option to restart it automatically or when the host boot. I also did not mount any particular folder from my host in the container for the data volume. Again, for the moment I'm only testing the solution.

    $ docker run --detach -p 3142:3142 --name pkg-proxy jcberthon/pkg-proxy

Using the proxy service
-----------------------

This was only tested on Raspbian (the Raspberry Pi variant of Debian, so using the `armhf` architecture) and on Ubuntu 16.04. But for both the configuration is exactly the same.

There are many suitable ways of declaring the proxy. I decided to do it as an APT (the package manager of Debian and its derivates) configuration. The configuration file is in this repository, see the file 01proxy. It should be placed on your system configuration folder:

    $ sudo cp 01proxy /etc/apt/apt.conf.d/

This file is rather simple it contains the following instructions:

    Acquire::http { Proxy "http://containerhost:3142"; };
    Acquire::https::proxy "DIRECT";

The first line gives the information about the proxy, so its hostname (or IP address) and port number. You should replace `containerhost` by the real hostname or IP of your Docker containers host.  
The second line specify that HTTPS should not be proxied. If you remove this line, be sure to understand the impacts, without additional changes you will get such errors on the clients: `Received HTTP code 403 from proxy after CONNECT`. Please read the link given in the introduction to understand what removing HTTPS direct connection implies and what solutions exist to perform caching on repositories over HTTPS (in my humble opinion, I was not satisfied by any and actually I prefer not caching HTTPS website for security reasons).

Then if you call any commands using either `apt` or `apt-get` (or equivalent) to update your repository information, upgrade or install packages, it will either go to the remote server if not already cached or be provided directly by the container proxying service.

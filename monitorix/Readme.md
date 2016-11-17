Monitorix container
===================

Work in progress...

Build
-----

    $ docker build -t jcberthon/monitorix .

Run
---

    $ docker run --detach --restart always --privileged -p 8080:8080 -v /boot:/boot:ro -v $PWD/monitorix.conf:/etc/monitorix/monitorix.conf:ro -v $PWD/fs.conf:/etc/monitorix/conf.d/fs.conf:ro --name monitorix jcberthon/monitorix

*Note: The docker image provide a volume for the persistency of the collected data. The volume is `/var/lib/monitorix` and can be mapped to any local folder on your system.*

Use
---

Open the following link: http://localhost:8080/index.html


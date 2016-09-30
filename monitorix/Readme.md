Monitorix container
===================

Work in progress...

Build
-----

    $ docker build -t jcberthon/monitorix .

Run
---

    $ docker run --rm -it --privileged -p 8080:8080 -v /boot:/boot:ro --name monitorix jcberthon/monitorix

Use
---

Open the following link: http://localhost:8080/index.html


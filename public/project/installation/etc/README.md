# System integration

This directory contains examples of how to integrate the Samizdat application on a Ubuntu 20.04 installation.

#### /etc/systemd/system/samizdat.service - systemd configuration

<pre><code>
[Unit]
Description=Samizdat
After=network.target

[Service]
Type=forking
User=www-data
PIDFile=/sites/Samizdat/bin/samizdat.pid
ExecStart=hypnotoad /sites/Samizdat/bin/samizdat
ExecReload=hypnotoad /sites/Samizdat/bin/samizdat
KillMode=process

[Install]
WantedBy=multi-user.target
</code></pre>

Enable and start

<pre><code>
systemctl enable samizdat
systemctl start samizdat
</code></pre>
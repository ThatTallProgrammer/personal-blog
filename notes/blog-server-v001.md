# Works on My Machine Blog v1


## Overview

This is a basic blogging application built on the Ghost blogging platform running on a single EC2 instance. This is a pet server with three services running on a single compute instance, Nginx, Ghost, and MySQL. 


## Design Philosophy

This is a pet server configured by hand. This is intentional. The server will be iteratively improved using increasingly more modern techniques. 


## Setup

### Launching the instance

- Launch EC2 using Launch Template
- Associate EIP
- Attache MySQL EBS

### DNS

Route 53 entry for worksonmymachine.me that points to the EIP for the system. 

### SSL

SSL uses certbot to automatically configure an SSL certificate for Nginx. 

Requires certbot and Nginx plugin.
```
certbot --nginx -d worksonmymachine.me
```

### Nginx

Set up a proxy pass to 127.0.0.1:2368'
```
location /some/path/ {
    proxy_pass http://127.0.0.1:2368;
}
```

### Ghost
```
su ghost-user

ghost install
```
Do not opt to autoconfigure Nginx

### MySQL

MySQL data is stored on a secondary EBS volume. 

### Disaster Recovery

Lifecycle policy backing up the MySQL persistent EBS volume nightly. Three snapshots are retained. 

AMI has been created with working configuration manually. 

### Security Thus Far

- TLS via Let's Encrypt
- Encrypted filesystems
- Basic disaster recovery and backup strategy


## Known Issues

### Ghost assumes Ubuntu

Ghost provides installation automation for Nginx and MySQL. The Nginx setup does not work on Amazon Linux.


# References

- [Production Ghost installation docs](https://docs.ghost.org/install/ubuntu/)
- [Nginx Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [Nginx SSL Setup]()

# Works on My Machine Blog v1


## Overview

This is a basic blogging application built on the Ghost blogging platform running on a single EC2 instance. This is a pet server with three services running on a single compute instance, Nginx, Ghost, and MySQL. 


## Design Philosophy

This is a pet server configured by hand. This is intentional. The server will be iteratively improved using increasingly more modern techniques. 


## Setup

### Nginx

### Ghost
```
su ghost-user

ghost install
```
Do not opt to autoconfigure Nginx

### MySQL


## Known Issues

### Ghost assumes Ubuntu

Ghost provides installation automation for Nginx and MySQL. The Nginx setup does not work on Amazon Linux.


# References

- [Production Ghost installation docs](https://docs.ghost.org/install/ubuntu/)


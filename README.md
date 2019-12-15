# docker-tengine

## Installation

```
docker run -it -d -p 80:80 443:443 -v ./site_conf:/etc/nginx/sites-enabled/ woaiso/docker-tengine:latest
```


## Path

- default wwwroot dir is `/usr/share/nginx/html`
- default sslkey dir is `/etc/nginx/key`
- default site config dir is `/etc/nginx/sites-enabled`
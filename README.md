# nginx-resume.md
Easy way to host your resume on a website.

---

### Setup
1. Write your resume in markdown format matching the style of the sample.md
2. put your resume.md file in a ~/volume/ folder exposed to the docker
3. Get a [google analytics ID](https://www.google.com/analytics/sign_up.html) (completely optional)

---

### Run the server

2. Run with defaults: (localhost, readable template, sample.md)
```bash
docker run -d -p 80:80 trmitchell7/nginx-resume.md:latest
```
3. Test it at http://localhost:80
4. Run on your site: (don't put www in the NGINX_DOMAIN)
```bash
docker run -d -p 80:80 \
    -v /local/path/for/resume:/volume \
    -e NGINX_DOMAIN=mysite.com \
    -e ANALYTICS=UA-XXXXXXXX-1 \
    -e TEMPLATE=readable
    --name=resume_site trmitchell7/nginx-resume.md:latest
```
---

### Options

Environmental variables:

- $TEMPLATE (this can be: modern, blockish, unstyled, readable, swissen)
- $NGINX_DOMAIN (the name of your site, i.e. mysite.com or mysite.com/resume - you can give it a specific location)
- $ANALYTICS (Your google analytics ID, allowing you to easily count views)

---

### Deploying to your own website

1. We'll use Triton since it's convenient and cheaper than AWS
2. Go to [Triton](https://my.joyent.com/main/#!/docker/containers)
3. Create [new container host](https://my.joyent.com/main/#!/docker/container/create)
    - size: I chose the smallest available for this, it's cheaper that way ;)
    - image: trmitchell7/nginx-resume.md:latest
    - PORTS: 80 (otherwise all ports are open)
    - VOLUMES: http://www.dropbox.com/s/xxxxxxxxx/resume.md?dl=1:/volume
        - (dropbox is really easy here, just change the dl=0 to dl=1)
    - ENV: NGINX_DOMAIN=mysite.com/resume
        - (you can set it to an arbitrary location)
    - ENV: ANALYTICS=UA-XXXXXXXX-1
        - (This is only if you set an ID up)
    - NETWORK: bridge
4. Click **Start** and it'll take a minute then you're all set!
    - Just update your DNS with the public IP that Joyent assigns. :)

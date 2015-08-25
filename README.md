# nginx-resume.md
Docker to host a static resume page from any resume in markdown format, using github.com/there4/markdown-resume to generate html

> This was thrown together quickly so... no promises.

---

### Setup
1. Write your resume in markdown format matching the style of the sample.md
2. put your resume.md file in a ~/volume/ folder exposed to the docker
3. (sign up here)[https://www.google.com/analytics/sign_up.html] (completely optional)

---

### Run the server

2. Run with defaults: (localhost, readable template, sample.md)
```bash
docker run -d -p 80:80 trmitchell7/nginx-resume.md
```
3. Test it at http://localhost:80
4. Run on your site: (don't put www. in the NGINX_DOMAIN)
```bash
docker run -d -p 80:80 \
    -v /local/path/for/resume:/volume \
    -e NGINX_DOMAIN=mysite.com \
    -e ANALYTICS=UA-XXXXXXXX-1 \
    -e TEMPLATE=readable
    --name=resume_site trmitchell7/nginx-resume.md
```
5. deploy to Joyent triton with: ...

---

### Options

Environmental variables:

- $TEMPLATE (this can be: modern, blockish, unstyled, readable, swissen)
- $NGINX_DOMAIN (the name of your site, i.e. mysite.com or mysite.com/resume - you can give it a specific location)
- $ANALYTICS (Your google analytics ID, allowing you to easily count views)

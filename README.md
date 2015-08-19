# nginx-resume.md
Docker to host a static resume page from any resume in markdown format, using github.com/there4/markdown-resume to generate html

> This was thrown together quickly so... no promises.

---

### Requirements
1. resume in markdown format matching the style of the sample.md
2. volume exposed to the docker for the resume.md file
3. google analytics ID (actually optional)

---

### Setup

2. Run with defaults: (localhost, readable template, sample.md)
```bash
docker run -d -p 80:80 trmitchell7/nginx-resume.md
```
3. Test it at http://localhost:80
4. Run on your site: (don't put www. in the domain)
```bash
docker run -d -p 80:80 \
    -v /location/of/your/resume:/volume \
    -e NGINX_DOMAIN=mysite.com \
    -e ANALYTICS=UA-XXXXXXXX-1 \
    -e TEMPLATE=readable
    --name=resume_site trmitchell7/nginx-resume.md
```

---

### Options

Environmental variables:

- $TEMPLATE (this can be: modern, blockish, unstyled, readable, swissen)
- NGINX_DOMAIN (the name of your site, i.e. mysite.com or mysite.com/resume)
- ANALYTICS (Your google analytics ID, allowing you to easily count views. (sign up here)[https://www.google.com/analytics/sign_up.html] )

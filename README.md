# nginx-resume.md
Docker to generate nginx hosted page with markdown resume templates, using github.com/there4/markdown-resume

> This was thrown together quickly so... no promises.

##### Before running compare the layout of your resume.md to the sample and get that sorted. ;)

#### Run with defaults: (localhost and readable template)
```bash
docker run -d -p 80:80 trmitchell7/nginx-resume.md:latest
```

#### Run with options: (make sure you don't put www. in the domain)
```bash
docker run -d -p 80:80 --name=resume_site -e NGINX_DOMAIN=thomas.ninja -e TEMPLATE=swissen trmitchell7/nginx-resume.md:latest
```

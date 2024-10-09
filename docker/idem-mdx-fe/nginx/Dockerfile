FROM nginx:1.24
# Stable docker image used (29/01/2024)
LABEL Authors="Mario Di Lorenzo <mario.dilorenzo@garr.it>"
COPY --from=hairyhenderson/gomplate:v3.11.3 /gomplate /bin/gomplate

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
        build-essential python3 python3-pip vim procps git

COPY docker/idem-mdx-fe/nginx/requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Copy a configuration file from the current directory
COPY docker/idem-mdx-fe/nginx/nginx.conf.template /etc/nginx/

# Copy start command
COPY docker/idem-mdx-fe/nginx/start.sh /start.sh

WORKDIR /app

# Copy scripts folder
COPY docker/idem-mdx-fe/nginx/scripts/ /app/scripts

# Add MkDocs folder and build
COPY docs4users /docs
RUN cd /docs && mkdocs build -f config/en/mkdocs.yml
RUN cd /docs && mkdocs build -f config/it/mkdocs.yml

# Copy scripts folder
COPY docker/idem-mdx-fe/nginx/scripts/ /app/scripts

# Add MkDocs folder and build
COPY docs4users /docs
RUN cd /docs && mkdocs build -f config/en/mkdocs.yml
RUN cd /docs && mkdocs build -f config/it/mkdocs.yml

# Copy scripts folder
COPY docker/idem-mdx-fe/nginx/scripts/ /app/scripts

# Add MkDocs folder and build
COPY docs4users /docs
RUN cd /docs && mkdocs build -f config/en/mkdocs.yml
RUN cd /docs && mkdocs build -f config/it/mkdocs.yml

## add permissions for nginx user
RUN chown -R nginx:nginx /app && chmod -R 755 /app && \
        chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx
RUN touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid
RUN chmod 755 /start.sh

EXPOSE 80
EXPOSE 443

STOPSIGNAL SIGQUIT
CMD ["/start.sh"]

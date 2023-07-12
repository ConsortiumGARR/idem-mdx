FROM nginx:1.22 
#Stable docker image used (08/01/2023)

ARG fe_cert_path

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
        build-essential python3 python3-pip vim procps python3-sphinx
RUN pip install sphinx_rtd_theme
RUN pip install guzzle_sphinx_theme
RUN pip install recommonmark

# Remove the default Nginx configuration file
RUN rm -v /etc/nginx/nginx.conf

# Copy a configuration file from the current directory
ADD docker/idem-mdx-fe/nginx/nginx.conf /etc/nginx/

COPY ${fe_cert_path} /etc/nginx/certs

# Copy start command
COPY docker/idem-mdx-fe/nginx/start.sh /start.sh

WORKDIR /app

# Add sphinx folder
COPY docs/user_docs /docs
RUN cd /docs && make html

## add permissions for nginx user
RUN chown -R nginx:nginx /app && chmod -R 755 /app && \
        chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx
RUN touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid
RUN chmod 755 /start.sh

USER nginx

EXPOSE 8080
EXPOSE 8444

STOPSIGNAL SIGQUIT
CMD ["/start.sh"]

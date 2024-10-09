FROM debian:12-slim
LABEL Authors="Mario Di Lorenzo <mario.dilorenzo@garr.it>"
COPY --from=hairyhenderson/gomplate:v3.11.3 /gomplate /bin/gomplate

ARG key_path
ARG mdx_key

ENV TZ="Europe/Rome"

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get -q update && apt-get -y upgrade && apt-get install --no-install-recommends -y \
    locales python3 python3-venv python3-pip python3-dev \ 
    build-essential libxml2-dev libxslt-dev libz-dev \
    vim wget ca-certificates openssh-client rsync cron 

#Cron
COPY docker/idem-mdx-be/crsync/rsync-mdq.sh.template /usr/local/bin/rsync-mdq.sh.template
COPY docker/idem-mdx-be/crsync/mdq-crontab /etc/cron.d/mdq-cron
RUN chmod 0755 /etc/cron.d/mdq-cron
RUN touch /var/log/cron.log

#Create SSH key pair
RUN mkdir /ssh
RUN ssh-keygen -t rsa -N '' -f /ssh/mdqsync-key

#JWT Generation
RUN mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old
COPY docker/idem-mdx-be/crsync/requirements.txt /requirements.txt
RUN apt-get install -y \ 
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install -r /requirements.txt 
COPY docker/idem-mdx-be/crsync/idem_xml_to_jwt /opt/idem_xml_to_jwt
COPY docker/idem-mdx-be/crsync/jwt-cron /etc/cron.d/jwt-cron
RUN chmod 0755 -R /opt/idem_xml_to_jwt/

# Copy the MDX key for JWT creation
COPY ${key_path}/${mdx_key} /opt/idem_xml_to_jwt/${mdx_key}
RUN chmod 0600 /opt/idem_xml_to_jwt/${mdx_key}

COPY docker/idem-mdx-be/crsync/start.sh /start.sh
RUN chmod a+x /start.sh
CMD ["/start.sh"]

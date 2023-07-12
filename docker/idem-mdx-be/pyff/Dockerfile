FROM debian:11

ARG be_cert_path
ARG pyff_cert_name
ARG pyff_privkey
ARG mdx_pubkey

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get -q update && apt-get -y upgrade && apt-get install --no-install-recommends -y \
    locales python3 python3-venv python3-pip python3-dev build-essential libxml2-dev \
    libxslt-dev libz-dev swig vim wget ca-certificates openssh-client rsync cron procps

ENV TZ="Europe/Rome"

RUN pip3 install setuptools
RUN pip3 install --upgrade pip
# PyFF versions: STABLE 1.1.5, LATEST 2.0.0
RUN pip3 install pyFF==1.1.5
RUN pip3 install --upgrade pipdeptree pykcs11
RUN pipdeptree
 
ENV LOGLEVEL INFO
ENV PIPELINE mdx-batch.fd
ENV DATADIR /opt/pyff

# Add Certificate and ssh keys
COPY ${be_cert_path} /certs
ENV MDX_CERTNAME /certs/${pyff_cert_name}
ENV MDX_PUBKEY /certs/${mdx_pubkey}

# Copy pipelines for PyFF
COPY docker/idem-mdx-be/pyff/mdx-batch.fd /mdx-batch.fd
COPY docker/idem-mdx-be/pyff/idem-prod-batch.fd /opt/pyff/idem-prod-batch.fd
COPY docker/idem-mdx-be/pyff/edugain-batch.fd /opt/pyff/edugain-batch.fd
COPY docker/idem-mdx-be/pyff/idem-test-batch.fd /opt/pyff/idem-test-batch.fd
COPY docker/idem-mdx-be/pyff/prod-and-test-batch.fd /opt/pyff/prod-and-test-batch.fd

RUN sed -i "s/pyff_certname/${pyff_cert_name}/g" /mdx-batch.fd
RUN sed -i "s/pyff_certname/${pyff_cert_name}/g" /opt/pyff/idem-prod-batch.fd
RUN sed -i "s/pyff_certname/${pyff_cert_name}/g" /opt/pyff/edugain-batch.fd
RUN sed -i "s/pyff_certname/${pyff_cert_name}/g" /opt/pyff/idem-test-batch.fd
RUN sed -i "s/pyff_certname/${pyff_cert_name}/g" /opt/pyff/prod-and-test-batch.fd

RUN sed -i "s/pyff_privkey/${pyff_privkey}/g" /mdx-batch.fd
RUN sed -i "s/pyff_privkey/${pyff_privkey}/g" /opt/pyff/idem-prod-batch.fd
RUN sed -i "s/pyff_privkey/${pyff_privkey}/g" /opt/pyff/edugain-batch.fd
RUN sed -i "s/pyff_privkey/${pyff_privkey}/g" /opt/pyff/idem-test-batch.fd
RUN sed -i "s/pyff_privkey/${pyff_privkey}/g" /opt/pyff/prod-and-test-batch.fd

COPY docker/idem-mdx-be/pyff/start.sh /start.sh
RUN chmod a+x /start.sh
CMD ["/start.sh"]

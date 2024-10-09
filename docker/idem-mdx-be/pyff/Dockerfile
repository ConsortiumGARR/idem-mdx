FROM python:3.11-slim
LABEL Authors="Mario Di Lorenzo <mario.dilorenzo@garr.it>"
COPY --from=hairyhenderson/gomplate:v3.11.3 /gomplate /bin/gomplate

ARG be_cert_path
ENV LANG=C.UTF-8
ENV TZ="UTC"

ENV USER mdx
ENV PYTHONPATH /opt/python-pyff/bin/

RUN groupadd -g 5000 ${USER}
RUN useradd -u 5000 -g ${USER} -ms /bin/bash ${USER}

RUN apt-get update && apt-get install --no-install-recommends -y \
    locales libxml2-dev libxslt-dev libz-dev swig wget ca-certificates g++ vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p \
    /var/run/pyff \
    /opt/python-pyff \
    /pyff-data \
    /pyff-data/certs \
    /pyff-data/idem \
    /pyff-data/edugain \
    /pyff-data/idem-test \
    /pyff-data/idem/entities \
    /pyff-data/edugain/entities \
    /pyff-data/idem-test/entities
RUN chown -R ${USER}:${USER} /var/run/pyff /opt/python-pyff /pyff-data

USER ${USER}

RUN python3 -m venv /opt/python-pyff
RUN ${PYTHONPATH}pip install --upgrade pip
RUN ${PYTHONPATH}pip install --upgrade setuptools pipdeptree pykcs11

# Pyff performances drop drastically with cryptography >= 42.x.x
RUN ${PYTHONPATH}pip install cryptography==41.0.7
# Version 5.1.0 of lxml sometimes produce an error in schema validation
RUN ${PYTHONPATH}pip install lxml==5.0.1
RUN ${PYTHONPATH}pip install --upgrade pyFF

ENV LOGLEVEL INFO
ENV PIPELINE mdx-batch.fd
ENV DATADIR /pyff-data

# Add Certificate and ssh keys
COPY --chown=${USER}:${USER} ${be_cert_path} /certs

# Copy pipelines for PyFF
COPY --chown=${USER}:${USER} docker/idem-mdx-be/pyff/pipelines /pipelines
COPY docker/idem-mdx-be/pyff/xslt/idem.xsl /xslt/idem.xsl

COPY --chown=${USER}:${USER} docker/idem-mdx-be/pyff/start.sh /start.sh
RUN chmod a+x /start.sh
ENV PATH "${PYTHONPATH}:${PATH}"
WORKDIR ${DATADIR}
CMD ["/start.sh"]

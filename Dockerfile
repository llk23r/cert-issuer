FROM lncm/bitcoind:v22.0
MAINTAINER Kim Duffy "kimhd@mit.edu"

USER root

COPY . /cert-issuer

# Have a copy of conf.ini locally
COPY conf.ini /etc/cert-issuer/conf.ini

# Have a copy of pk_issuer.txt locally
COPY pk_issuer.txt /cert-issuer/pk_issuer.txt

RUN apk add --update \
    bash \
    ca-certificates \
    curl \
    gcc \
    gmp-dev \
    libffi-dev \
    libressl-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    make \
    musl-dev \
    python2 \
    python3 \
    python3-dev \
    tar \
    && curl https://sh.rustup.rs -sSf | sh -s -- -y \
    && source $HOME/.cargo/env \
    && rustup default stable \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip setuptools \
    && pip3 install Cython \
    && pip3 install wheel \
    && mkdir -p /etc/cert-issuer/data/unsigned_certificates \
    && mkdir /etc/cert-issuer/data/blockchain_certificates \
    && mkdir ~/.bitcoin \
    && echo $'[regtest]\nrpcuser=foo\nrpcpassword=bar\nrpcport=8332\nregtest=1\nrelaypriority=0\nrpcallowip=127.0.0.1\nrpcconnect=127.0.0.1\n' > /root/.bitcoin/bitcoin.conf \
    && pip3 install /cert-issuer/. \
    && pip3 install -r /cert-issuer/ethereum_requirements.txt \
    && rm -r /usr/lib/python*/ensurepip \
    && rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache
RUN ln -sf /usr/bin/python3 /usr/bin/python
RUN pip install --upgrade pip
RUN cd /cert-issuer && python setup.py experimental --blockchain=ethereum
RUN cp /cert-issuer/examples/data-testnet/unsigned_certificates/verifiable-credential.json /etc/cert-issuer/data/unsigned_certificates/
ENTRYPOINT bitcoind -daemon && bash

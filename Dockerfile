FROM alpine:3.13 as builder

RUN apk add --no-cache git make g++ boost-dev openssl-dev miniupnpc-dev zlib-dev autoconf db-dev automake libtool libevent-dev
RUN addgroup --gid 1000 bolivar
RUN adduser --disabled-password --gecos "" --home /bolivar --ingroup bolivar --uid 1000 bolivar

RUN git clone https://github.com/BOLI-Project/BolivarCoin.git /bolivar/BolivarCoin
WORKDIR /bolivar/BolivarCoin
RUN git checkout tags/v2.0.0.2
RUN ./autogen.sh
RUN ./configure --without-gui

RUN make

FROM alpine:3.13

RUN apk add --no-cache boost-dev db-dev miniupnpc-dev zlib-dev bash curl
RUN addgroup --gid 1000 bolivar
RUN adduser --disabled-password --gecos "" --home /bolivar --ingroup bolivar --uid 1000 bolivar

USER bolivar
COPY --from=builder /bolivar /bolivar
COPY ./entrypoint.sh /

RUN mkdir /bolivar/.Bolivarcoin
VOLUME /bolivar/.Bolivarcoin
ENTRYPOINT ["/entrypoint.sh"]

# P2P
EXPOSE 3893/tcp
# RPC
EXPOSE 3563/tcp


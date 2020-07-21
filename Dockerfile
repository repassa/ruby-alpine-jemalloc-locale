FROM ruby:2.7-alpine AS builder

# malloc(3) implementation that emphasizes fragmentation avoidance and scalable concurrency support
RUN apk add build-base
RUN wget -O - https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2 | tar -xj && \
    cd jemalloc-5.2.1 && \
    ./configure && \
    make && \
    make install

FROM ruby:2.7-alpine

# Setup Jemalloc
COPY --from=builder /usr/local/lib/libjemalloc.so.2 /usr/local/lib/
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

# Locales support for musl
ENV MUSL_LOCPATH=/usr/share/i18n/locales/musl
RUN apk update && apk upgrade --no-cache
RUN apk add --no-cache --update cmake make musl-dev gcc gettext-dev libintl
RUN wget https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip \
    && unzip musl-locales-master.zip \ 
    && cd musl-locales-master \
    && cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . \
    && make && make install \
    && cd .. && rm -r musl-locales-master

# Initial Setup
RUN apk update && apk upgrade --no-cache
RUN apk add --no-cache --update build-base git postgresql-dev bash tzdata

# Configura o Timezone
ENV TZ=America/Sao_Paulo

# Configura o Locale para pt_BR.UTF-8
ENV LANG=pt_BR.UTF-8 
ENV LC_ALL=pt_BR.UTF-8
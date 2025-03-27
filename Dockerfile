FROM alpine:latest

RUN adduser -D papermc

# Environment variables
ENV MC_VERSION="latest" \
    PAPER_BUILD="latest" \
    EULA="false" \
    MC_RAM="" \
    JAVA_OPTS=""

RUN apk update --no-cache && \
    apk upgrade --no-cache --available && \
    apk add --no-cache \
        libstdc++ \
        openjdk21-jre \
        bash \
        wget \
        jq \
        net-tools \
        ncurses \
        tmux

RUN mkdir -p /app/scripts /papermc && \
    chown -R papermc:papermc /app/scripts /papermc

COPY --chown=papermc:papermc papermc.sh /app/scripts/
RUN chmod +x /app/scripts/papermc.sh

USER papermc
WORKDIR /papermc

CMD ["/app/scripts/papermc.sh"]

EXPOSE 25565/tcp
VOLUME ["/papermc"]
FROM alpine:latest

RUN adduser -D papermc && \
    mkdir -p /papermc /app/scripts && \
    chown -R papermc:papermc /papermc /app/scripts /app

# Environment variables
ENV MC_VERSION="latest" \
    PAPER_BUILD="latest" \
    EULA="false" \
    MC_RAM="" \
    JAVA_OPTS=""

RUN apk add --no-cache \
        libstdc++ \
        openjdk21-jre \
        bash \
        wget \
        jq 

COPY --chown=papermc:papermc papermc.sh /app/scripts/
RUN chmod +x /app/scripts/papermc.sh

USER papermc
WORKDIR /papermc

ENTRYPOINT ["/app/scripts/papermc.sh"]

EXPOSE 25565/tcp
VOLUME ["/papermc"]
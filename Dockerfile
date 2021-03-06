ARG DISTRIB_CODENAME="focal"

FROM ubuntu:${DISTRIB_CODENAME} AS base
ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get --yes --quiet update \
 && apt-get --yes --quiet install --no-install-recommends ca-certificates curl libicu66 mediainfo sqlite3 \
 && apt-get --yes --quiet clean \
 && rm --recursive /var/lib/apt/lists/*


FROM ubuntu:${DISTRIB_CODENAME} AS build
ARG RADARR_VERSION

ADD ["https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64&version=${RADARR_VERSION}", "/root/Radarr.linux-core-x64.tar.gz"]

RUN tar --extract --file '/root/Radarr.linux-core-x64.tar.gz' --directory '/opt'


FROM base AS radarr
COPY --from=build --chown=root:root /opt/Radarr /opt/Radarr

RUN addgroup --gid 666 radarr \
 && adduser --disabled-password --uid 666 --gid 666 radarr \
 && chown --verbose radarr:radarr /opt/Radarr

USER radarr

RUN mkdir --verbose --parents /home/radarr/.config/Radarr

VOLUME /home/radarr/.config/Radarr

WORKDIR /opt/Radarr

CMD ["/opt/Radarr/Radarr", "-nobrowser", "-data=/home/radarr/.config/Radarr"]

ARG ImageVersion

FROM rockylinux/rockylinux:$ImageVersion

ARG ImageVersion

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox command" \
      org.opencontainers.image.authors="Magauer Lukas <lukas@magauer.eu>" \
      org.opencontainers.image.description="Base image for creating Rocky Linux toolbox containers" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.opencontainers.image.url="https://github.com/rocky-linux/rocky-toolbox-images" \
      org.opencontainers.image.vendor="Rocky Enterprise Software Foundation"

COPY README.md /

RUN sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf
RUN dnf -y update

COPY missing-docs /
RUN dnf -y reinstall $(<missing-docs)
RUN rm /missing-docs

COPY extra-packages* /tmp/
RUN dnf -y install $(</tmp/extra-packages-common)
RUN if [ -f /tmp/extra-packages-${ImageVersion} ]; then \
      dnf -y install $(</tmp/extra-packages-${ImageVersion}); \
    fi
RUN rm -f /tmp/extra-packages*

RUN dnf clean all

CMD /bin/sh

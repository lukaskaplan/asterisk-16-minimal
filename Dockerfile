FROM debian:bullseye-slim

ARG IMAGE_CREATED
ARG IMAGE_AUTHORS="Lukas Kaplan, lukas.kaplan@lkaplan.cz"
ARG IMAGE_URL="https://github.com/lukaskaplan/asterisk-16-minimal/"
ARG IMAGE_DOCUMENTATION="https://github.com/lukaskaplan/asterisk-16-minimal/blob/main/README.md"
ARG IMAGE_SOURCE="https://github.com/lukaskaplan/asterisk-16-minimal/tree/main"
ARG IMAGE_VERSION
ARG IMAGE_REVISION
ARG IMAGE_VENDOR="Lukas Kaplan (https://lkaplan.cz)"
ARG IMAGE_LICENSES="MIT"
ARG IMAGE_REF_NAME
ARG IMAGE_TITLE="Asterisk 16 minimal"
ARG IMAGE_DESCRIPTION="Basic image with Asterisk 16 minimal configuration. Intended as a foundation for further development."

LABEL org.opencontainers.image.created=${IMAGE_CREATED} \
    org.opencontainers.image.authors=${IMAGE_AUTHORS} \
    org.opencontainers.image.url=${IMAGE_URL} \
    org.opencontainers.image.documentation=${IMAGE_DOCUMENTATION} \
    org.opencontainers.image.source=${IMAGE_SOURCE} \
    org.opencontainers.image.version=${IMAGE_VERSION} \
    org.opencontainers.image.revision=${IMAGE_REVISION} \
    org.opencontainers.image.vendor=${IMAGE_VENDOR} \
    org.opencontainers.image.licenses=${IMAGE_LICENSES} \
    org.opencontainers.image.ref.name=${IMAGE_REF_NAME} \
    org.opencontainers.image.title=${IMAGE_TITLE} \
    org.opencontainers.image.description=${IMAGE_DESCRIPTION}

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends asterisk && \
	mkdir -p /var/run/asterisk && \
	# remove all default config files
	rm -rf /etc/asterisk/*

# Copy custom (minimized) config files
COPY ./asterisk_config_files /etc/asterisk

RUN \
	# Set filesystem permissions
	chown -R asterisk: /etc/asterisk > /dev/null 2>&1 && \
	chown -R asterisk: /usr/share/asterisk > /dev/null 2>&1 && \
	chown -R asterisk: /var/log/asterisk > /dev/null 2>&1 && \
	chown -R asterisk: /var/lib/asterisk > /dev/null 2>&1 && \
	chown -R asterisk: /var/run/asterisk > /dev/null 2>&1 && \
	chown -R asterisk: /var/spool/asterisk > /dev/null 2>&1 && \
	chmod -R 777 /tmp > /dev/null 2>&1 && \
	# Clean up to reduce image size
	apt-get clean -y && \
	apt-get autoclean -y && \
	apt-get autoremove -y && \
	rm -rf \
		/var/lib/apt/lists/* \
		/var/lib/log/* \
		/tmp/* \
		/var/tmp/*

EXPOSE 5060/udp

USER asterisk

CMD ["/usr/sbin/asterisk", "-T", "-W", "-p", "-vvvdddf"]


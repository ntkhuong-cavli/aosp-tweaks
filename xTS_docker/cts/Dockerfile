FROM cavli-test-docker:base

# Add Android CTS tools
RUN mkdir -p /opt/workspace/cts/
COPY android-cts-tools/ /opt/workspace/cts/

# Update version
RUN echo "cavli_cts-14.0_r11-media_1.5-cqs290_iot" > /etc/docker_image_version

WORKDIR /opt/workspace/cts

ENTRYPOINT ["/bin/bash", "-c", "bash /opt/scripts/env_init.sh && exec sleep infinity"]

CMD ["/bin/bash"]

FROM cavli-test-docker:base

# Add Android CTS tools
# stick/android-cts-tools/android-cts
RUN mkdir -p /opt/workspace/cts/
COPY android-cts-tools/ /opt/workspace/cts/

# VSDK CTS
# Comment out here, because the VSDK CTS testcases included in the CTS tools stick/android-cts-tools/android-cts
# COPY vsdk-cts-tools/testcases/ /opt/workspace/cts/android-cts/testcases/

# VTS
RUN mkdir -p /opt/workspace/vts/
COPY android-vts-tools/ /opt/workspace/vts/

# Update version
RUN echo "STICK-LA5.0_CTS-14-R11_VSDK-9a84f801_MEDIA-1.5_VTS-20260729" > /etc/docker_image_version

WORKDIR /opt/workspace

ENTRYPOINT ["/bin/bash", "-c", "bash /opt/scripts/env_init.sh && exec sleep infinity"]

CMD ["/bin/bash"]

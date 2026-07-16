FROM ortussolutions/commandbox:jdk17

# Copy the server.json so that CommandBox can pre-install the Adobe ColdFusion engine
# during the Docker build. This uses the FINALIZE_STARTUP flag to generate an authoritative
# startup script, which means CommandBox doesn't have to re-download the ColdFusion engine
# or re-evaluate the server configuration on every container start.
COPY ./server.json /app/server.json
RUN export FINALIZE_STARTUP=true && \
	$BUILD_DIR/run.sh && \
	unset FINALIZE_STARTUP

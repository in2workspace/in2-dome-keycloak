# Start with the official Keycloak image from Quay.io
FROM in2workspace/in2-keycloak-extension:v2.0.0-snapshot

# Create non-root user and group manually
USER root
RUN echo "nonroot:x:1000:1000:Non-root user:/home/nonroot:/sbin/nologin" >> /etc/passwd \
    && echo "nonroot:x:1000:" >> /etc/group \
    && mkdir -p /home/nonroot \
    && chown -R 1000:1000 /home/nonroot

# Define build argument for environment
ARG ENVIRONMENT=dev

# Copy the theme files into the image
COPY /themes /opt/keycloak/themes

# Copy realm files into the image
COPY /data/import/in2-dome-keycloak-realms.json in2-dome-keycloak-realms.json
COPY /data/import/in2-dome-keycloak-realms-prod.json in2-dome-keycloak-realms-prod.json

# Conditional copying of the realm file based on the ENVIRONMENT argument
RUN echo "Environment: $ENVIRONMENT" && \
    if [ "$ENVIRONMENT" = "prod" ]; then \
        echo "Copying prod realm file"; \
        cp in2-dome-keycloak-realms-prod.json /opt/keycloak/data/import/; \
    else \
        echo "Copying dev realm file"; \
        cp in2-dome-keycloak-realms.json /opt/keycloak/data/import/; \
    fi

# Command to start Keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start-dev", "--health-enabled=true", "--metrics-enabled=true", "--log-level=INFO", "--import-realm"]



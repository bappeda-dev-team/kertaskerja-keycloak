FROM quay.io/keycloak/keycloak:latest AS builder

# Enable health and metrics support
ARG KC_HEALTH_ENABLED=true
ENV KC_HEALTH_ENABLED=${KC_HEALTH_ENABLED}
ARG KC_METRICS_ENABLED=true
ENV KC_METRICS_ENABLED=${KC_METRICS_ENABLED}

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
ARG KC_DB=postgres
ENV KC_DB=${KC_DB}
ARG KC_DB_URL
ENV KC_DB_URL=${KC_DB_URL}
ARG KC_DB_USERNAME
ENV KC_DB_USERNAME=${KC_DB_USERNAME}
ARG KC_DB_PASSWORD
ENV KC_DB_PASSWORD=${KC_DB_PASSWORD}
ARG KC_HOSTNAME
ENV KC_HOSTNAME=${KC_HOSTNAME}

ARG KC_BOOTSTRAP_ADMIN_USERNAME
ENV KC_BOOTSTRAP_ADMIN_USERNAME=${KC_BOOTSTRAP_ADMIN_USERNAME}
ARG KC_BOOTSTRAP_ADMIN_PASSWORD
ENV KC_BOOTSTRAP_ADMIN_PASSWORD=${KC_BOOTSTRAP_ADMIN_PASSWORD}

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

ARG KC_VERSION=26.3

FROM quay.io/keycloak/keycloak:${KC_VERSION} AS builder

# Enable health and metrics support
ARG KC_HEALTH_ENABLED=true
ENV KC_HEALTH_ENABLED=${KC_HEALTH_ENABLED}
ARG KC_METRICS_ENABLED=true
ENV KC_METRICS_ENABLED=${KC_METRICS_ENABLED}

WORKDIR /opt/keycloak
# copy custom spi jar
COPY spi /opt/keycloak/providers
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:${KC_VERSION}
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
ARG KC_DB=postgres
ENV KC_DB=${KC_DB}

ARG KC_BOOTSTRAP_ADMIN_USERNAME
ENV KC_BOOTSTRAP_ADMIN_USERNAME=${KC_BOOTSTRAP_ADMIN_USERNAME}
ARG KC_BOOTSTRAP_ADMIN_PASSWORD
ENV KC_BOOTSTRAP_ADMIN_PASSWORD=${KC_BOOTSTRAP_ADMIN_PASSWORD}

EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

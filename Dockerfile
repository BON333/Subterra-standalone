FROM eclipse-temurin:17-jdk AS algorithms-build

WORKDIR /build
COPY algoritmos-java/ ./algoritmos-java/
RUN ./algoritmos-java/build.sh

FROM eclipse-temurin:17-jre AS java-runtime

FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends supervisor \
    && docker-php-ext-install pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

COPY --from=java-runtime /opt/java/openjdk /opt/java/openjdk
COPY app/ /var/www/html/
COPY --from=algorithms-build /build/algoritmos-java/build/subterra-algoritmos.jar /opt/subterra/subterra-algoritmos.jar
COPY deploy/container-entrypoint.sh /usr/local/bin/subterra-container-entrypoint
COPY deploy/supervisord.conf /etc/supervisor/conf.d/subterra.conf

RUN chmod 755 /usr/local/bin/subterra-container-entrypoint

ENV PATH="/opt/java/openjdk/bin:${PATH}"
ENV SUBTERRA_ALGORITHM_PORT=8787
ENV SUBTERRA_ALGORITHM_URL=http://127.0.0.1:8787

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/subterra-container-entrypoint"]
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

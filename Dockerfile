FROM alpine:3 AS base
WORKDIR /app/otel
RUN wget https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.11.1/opentelemetry-javaagent.jar

FROM busybox as otel-java-image
COPY --from=base /app/otel/opentelemetry-javaagent.jar /app/otel/
CMD [ "/bin/sh", "-c", "cp /app/otel/opentelemetry-javaagent.jar /opt/otel/" ]

# otel-java-initcontainer

This Docker image contains only one important file, that is the
opentelemetry-javaagent.jar that can be used for instrumenting
Java apps without making other changes.

We created it for instrumenting Spinnaker components, but it could
be used for other purposes.

# Spinnaker Usage

Add this to your halyard config foe every service you want to instrument:

```
    initContainers:
      spin-clouddriver:
        - name: otel-inject
          image: docker.flame.org/library/otel-java:latest
          imagePullPolicy: Always
          volumeMounts:
          - name: otel-jars
            mountPath: /opt/otel
```

Add this to every `default/service-settings/*.yml` file you wish to instrument:

Example for `default/service-settings/clouddriver.yml`:

```
env:
  JAVA_OPTS: "-XX:MaxRAMPercentage=100.0 -javaagent:/opt/otel/opentelemetry-javaagent.jar -Dotel.resource.attributes=service.name=clouddriver -Dotel.traces.exporter=jaeger -Dotel.exporter.jaeger.endpoint=http://jaeger-collector.jaeger.svc.cluster.local:14250"
kubernetes:
  volumes:
  - id: otel-jars
    mountPath: /opt/otel
    type: emptyDir
```

You will need to add to existing JAVA_OPTS if any.  In this case, we set the max
RAM usage as well.

For each service, also set the `service.name` for each service.

Lastly, use an exporter.  This example is for Jaeger.

# MCRouter Docker

## Docker

```bash
docker run -it --rm -p 11211:11211 leandrocarneiro/mcrouter:ubuntu-18.04 \
    --config-str='{"pools":{"A":{"servers":["memcached-node1:11211","memcached-node2:11211"]}},"route":"PoolRoute|A"}' \
    -p 11211
```

## Kubernetes simple Deployment and Service

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: mcrouter
---
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    application-description: "Balancer for MemCached Servers by Facebook"
    application-name: "mcrouter"
    impact-level: "5"
    maintainers: "leandro.carneiro"
  labels:
    app: mcrouter
    tribe: infra
    squad: sre
    cost-center: Infra
  name: mcrouter
  namespace: mcrouter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mcrouter
  template:
    metadata:
      annotations:
        application-description: "Balancer for MemCached Servers by Facebook"
        application-name: "mcrouter"
        impact-level: "5"
        maintainers: "leandro.carneiro"
      labels:
        app: mcrouter
        tribe: infra
        squad: sre
        cost-center: Infra
    spec:
      containers:
        - name: mcrouter
          image: leandrocarneiro/mcrouter:ubuntu-18.04
          imagePullPolicy: IfNotPresent
          args:
            - |
              --config-str={
                  "pools": {
                    "A": {
                      "servers": [
                        "memcached-node1:11211",
                        "memcached-node2:11211"
                      ]
                    }
                  },
                  "route": "PoolRoute|A"
                }
            - -p 11211
          livenessProbe:
            exec:
              command:
                - /bin/bash
                - -c
                - "pidof mcrouter"
            initialDelaySeconds: 5
            periodSeconds: 5
          readinessProbe:
            exec:
              command:
                - /bin/bash
                - -c
                - "pidof mcrouter"
            initialDelaySeconds: 5
            periodSeconds: 5
          ports:
            - containerPort: 11211
              name: memcached
              protocol: TCP
          resources:
            requests:
              memory: 250Mi
              cpu: 100m
            limits:
              memory: 500Mi
              cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    application-description: "Balancer for MemCached Servers by Facebook"
    application-name: "mcrouter"
    impact-level: "5"
    maintainers: "leandro.carneiro"
  labels:
    app: mcrouter
    tribe: infra
    squad: sre
    cost-center: Infra
  name: mcrouter
  namespace: mcrouter
spec:
  ports:
    - name: memcached
      port: 11211
      protocol: TCP
      targetPort: 11211
  selector:
    app: mcrouter
  type: ClusterIP
```

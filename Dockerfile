FROM quay.io/operator-framework/helm-operator:v0.16.0

LABEL name="sysdig-operator"
LABEL summary="Sysdig is a unified platform for container and microservices monitoring, troubleshooting, security and forensics. Sysdig platform has been built on top of Sysdig tool and Sysdig Inspect open-source technologies."
LABEL description="This operator installs the Sysdig Agent for Sysdig Monitor and Sysdig Secure to all nodes in your cluster via a DaemonSet."
LABEL vendor="Sysdig"

COPY LICENSE /licenses/

COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts/ ${HOME}/helm-charts/

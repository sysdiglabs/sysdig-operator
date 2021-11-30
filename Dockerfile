# Build the manager binary
FROM quay.io/operator-framework/helm-operator:v1.15.0

# Labels for RH certification
LABEL name="sysdig-operator"
LABEL summary="Sysdig is a unified platform for container and microservices monitoring, troubleshooting, security and forensics. Sysdig platform has been built on top of Sysdig tool and Sysdig Inspect open-source technologies."
LABEL description="This operator installs the Sysdig Agent for Sysdig Monitor and Sysdig Secure to all nodes in your cluster via a DaemonSet."
LABEL vendor="Sysdig"
COPY LICENSE /licenses/

ENV HOME=/opt/helm
COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts  ${HOME}/helm-charts
WORKDIR ${HOME}

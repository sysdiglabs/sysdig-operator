# Sysdig Helm Operator

The Sysdig operator is a Helm operator for the [`sysdig` chart](https://github.com/sysdiglabs/charts/tree/master/charts/sysdig)

# Usage

This operator is a Helm-based operator using the [Operator SDK](https://sdk.operatorframework.io/). The resource spec is the same as the [values](https://github.com/sysdiglabs/charts/blob/master/charts/sysdig/values.yaml) used to configure the Helm chart.

```yaml
apiVersion: sysdig.com/v1
kind: SysdigAgent
metadata:
  name: sysdig-agent
spec:
  <Helm values>
```

# Building

## Operator

Update the `VERSION` and build a new docker image using `make docker-build`.

## OLM Bundle

To update the bundle to the current state of the kustomize manifests in `config/`, run `make bundle`.

### Testing

The operator deployment can be tested with `make deploy`. `make undeploy` cleans up.

To test using the `ClusterServiceVersion` similar to an OperatorHub deployment, build a bundle image with `make bundle-build`. Push it to an image registry and use the operator-sdk to deploy it to your cluster with `operator-sdk run bundle <bundle_image> --timeout 3m`

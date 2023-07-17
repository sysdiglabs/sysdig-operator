
---

> **Warning**
> This project is deprecated, as now we are supporting the [helm chart](https://github.com/sysdiglabs/charts) as default installation strategy for the Sysdig Agent.
>
> Sysdig will not provide any mantainance or support for this project.

---
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

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

# Updates

There are two parts that can be updated: the operator image and the bundle. Ideally, these two parts would be in sync.

To manually perform a chart update:
```
cd charts
git checkout tags/sysdig-<version>
```

and commit changes. Update the `VERSION` in the Makefile to the checked out chart version, and build the operator and bundle.

If the bundle alone must be updated without updating the chart, the bundle version will be out of sync with the chart version. At the moment, a bundle update requires a version bump in order to publish.

# Building

## Operator

Update the `VERSION` and build a new docker image using `make docker-build`.

## OLM Bundle

To update the bundle to the current state of the kustomize manifests in `config/`, run `make bundle`.

### Testing

The operator deployment can be tested with `make deploy`. `make undeploy` cleans up.

To test using the `ClusterServiceVersion` similar to an OperatorHub deployment, build a bundle image with `make bundle-build`. Push it to an image registry and use the operator-sdk to deploy it to your cluster with `operator-sdk run bundle <bundle_image> --timeout 3m`

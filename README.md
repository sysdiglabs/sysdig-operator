# Sysdig Agent Operator

The Sysdig Agent Operator for Kubernetes provides an easy way to deploy Sysdig

[Sysdig](https://www.sysdig.com/) is a unified platform for container and microservices monitoring, troubleshooting, security and forensics. Sysdig platform has been built on top of [Sysdig tool](https://sysdig.com/opensource/sysdig/) and [Sysdig Inspect](https://sysdig.com/blog/sysdig-inspect/) open-source technologies.

This operator deploys the Sysdig agent for [Sysdig Monitor](https://sysdig.com/product/monitor/) and [Sysdig Secure](https://sysdig.com/product/secure/) to all nodes in your cluster via a DaemonSet.

## Quickstart

To quickly try out **just** the Sysdig Agent Operator inside a cluster, run the following command:

```shell
kubectl apply -f https://raw.githubusercontent.com/sysdiglabs/sysdig-operator/master/bundle.yaml
```

This command deploys the operator itself and its dependencies: Custom Resource Definitions, ServiceAccount and its ClusterRoleBinding.

## Settings

This operator, uses the same options than the [Helm Chart](https://hub.helm.sh/charts/stable/sysdig), please take a look to all the options in the following table:

| Parameter                       | Description                                                            | Default                                     |
| ---                             | ---                                                                    | ---                                         |
| `image.registry`                | Sysdig agent image registry                                            | `docker.io`                                 |
| `image.repository`              | The image repository to pull from                                      | `sysdig/agent`                              |
| `image.tag`                     | The image tag to pull                                                  | `0.89.0`                                    |
| `image.pullPolicy`              | The Image pull policy                                                  | `IfNotPresent`                              |
| `image.pullSecrets`             | Image pull secrets                                                     | `nil`                                       |
| `resources.requests.cpu`        | CPU requested for being run in a node                                  | `100m`                                      |
| `resources.requests.memory`     | Memory requested for being run in a node                               | `512Mi`                                     |
| `resources.limits.cpu`          | CPU limit                                                              | `200m`                                      |
| `resources.limits.memory`       | Memory limit                                                           | `1024Mi`                                    |
| `rbac.create`                   | If true, create & use RBAC resources                                   | `true`                                      |
| `serviceAccount.create`         | Create serviceAccount                                                  | `true`                                      |
| `serviceAccount.name`           | Use this value as serviceAccountName                                   | ` `                                         |
| `daemonset.updateStrategy.type` | The updateStrategy for updating the daemonset                          | `RollingUpdate`                             |
| `ebpf.enabled`                  | Enable eBPF support for Sysdig instead of `sysdig-probe` kernel module | `false`                                     |
| `ebpf.settings.mountEtcVolume`  | Needed to detect which kernel version are running in Google COS        | `true`                                      |
| `sysdig.accessKey`              | Your Sysdig Monitor Access Key                                         | `Nil` You must provide your own key         |
| `sysdig.settings`               | Settings for agent's configuration file                                | `{}`                                        |
| `secure.enabled`                | Enable Sysdig Secure                                                   | `false`                                     |
| `customAppChecks`               | The custom app checks deployed with your agent                         | `{}`                                        |
| `tolerations`                   | The tolerations for scheduling                                         | `node-role.kubernetes.io/master:NoSchedule` |

For example, if you want to deploy a DaemonSet with eBPF and with Sysdig Secure
enabled:

```yaml
apiVersion: sysdig.com/v1alpha1
kind: SysdigAgent
metadata:
  name: agent-with-ebpf-and-secure
spec:
  ebpf:
    enabled: true
  secure:
    enabled: true
  sysdig:
    accessKey: XXX
```

Please, notice that `sysdig.accessKey` is mandatory. Once you have provided the
accessKey, you can apply this file with `kubectl apply -f`

And then you can see you pods with the Sysdig Agent deployed:

```shell
$ kubectl get pods
NAME                                                              READY   STATUS    RESTARTS   AGE
agent-with-ebpf-and-secure-9wexzni4dib601y2ik5kc1vi5-sysdi2w9m4   1/1     Running   0          2m
agent-with-ebpf-and-secure-9wexzni4dib601y2ik5kc1vi5-sysdil8d9q   1/1     Running   0          2m
agent-with-ebpf-and-secure-9wexzni4dib601y2ik5kc1vi5-sysdiv2vgs   1/1     Running   0          2m
sysdig-agent-operator-7f6cf49bb4-cwxcn                            1/1     Running   0          2m
```

## Removal

Just run the `kubectl delete` command to remove the operator and its dependencies.

```shell
kubectl delete -f https://raw.githubusercontent.com/sysdiglabs/sysdig-operator/master/bundle.yaml
```

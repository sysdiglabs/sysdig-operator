# Sysdig Agent Operator

The Sysdig Agent Operator for Kubernetes provides an easy way to deploy Sysdig

[Sysdig](https://www.sysdig.com/) is a unified platform for container and microservices monitoring, troubleshooting, security and forensics. Sysdig platform has been built on top of [Sysdig tool](https://sysdig.com/opensource/sysdig/) and [Sysdig Inspect](https://sysdig.com/blog/sysdig-inspect/) open-source technologies.

This operator deploys the Sysdig agent for [Sysdig Monitor](https://sysdig.com/product/monitor/) and [Sysdig Secure](https://sysdig.com/product/secure/) to all nodes in your cluster via a DaemonSet.

## Pre-requisites

* Cluster-admin access to Kubernetes/OpenShift
* [Host requirements](https://docs.sysdig.com/en/host-requirements-for-agent-installation.html)
* [Sysdig agent access key](https://docs.sysdig.com/en/agent-installation--overview-and-key.html)

### Minimum required cluster config / cluster resources

At a minimum, each Sysdig agent requires 2% of total CPU of the host and 512 MiB of memory.

Default limits and requests are detailed in the table below, these parameters are customizable:

| Parameter                   | Description                              | Default  |
| ---                         | ---                                      | ---      |
| `resources.requests.cpu`    | CPU requested for being run in a node    | `100m`   |
| `resources.requests.memory` | Memory requested for being run in a node | `512Mi`  |
| `resources.limits.cpu`      | CPU limit                                | `200m`   |
| `resources.limits.memory`   | Memory limit                             | `1024Mi` |

### Architecture support

* The Sysdig agent currently supports x86/AMD64 architectures

### Storage requirements

* The Sysdig agent doesn't require any additional persistent volumes containing stateful data

## Quickstart

To quickly try out **just** the Sysdig Agent Operator inside a cluster, run the following command:

```shell
kubectl apply -f https://raw.githubusercontent.com/sysdiglabs/sysdig-operator/master/bundle.yaml
```

This command deploys the operator itself and its dependencies: Custom Resource Definitions, ServiceAccount and its ClusterRoleBinding.

## Installation walkthrough

Access the OperatorHub inside the OpenShift interface (`Operators -> OperatorHub`). Searching by `sysdig` you will see the Sysdig Operator:

![OperatorHub Sysdig](https://github.com/sysdiglabs/sysdig-operator/blob/master/images/operatorhub-sysdig.png)

Then you will need to configure the operator subscrption:

![Operator Subscription](https://github.com/sysdiglabs/sysdig-operator/blob/master/images/operator-subscription.png)

You need to specify a specify namespace on the cluster where the agent will be installed and an approval strategy if you want to automatically upgrade the running version of the operator without human intervention.

Next you can check the operator is successfully installed.

![Operator Installed](https://github.com/sysdiglabs/sysdig-operator/blob/master/images/operator-installed.png)

Or even check the events happened while the operator was installing:

![Operator Events](https://github.com/sysdiglabs/sysdig-operator/blob/master/images/operator-events.png)

So, next step is to instruct our operator to deploy the Sysdig Agent. Click in Create SysdigAgent button:

![SysdigAgent Installation](https://github.com/sysdiglabs/sysdig-operator/blob/master/images/agent-installation.png)

And you will see the screen where you can configure the parameters for the Sysdig Agent. You will need to replace the accessKey for the key that Sysdig provided you:

![SysdigAgent settings](https://github.com/sysdiglabs/sysdig-operator/blob/master/images/agent-settings.png)

### Install verification steps

Once the Operator is listed as `Succeeded` and `Up to date`:

![Sysdig Operator Ready](https://github.com/sysdiglabs/sysdig-operator/blob/master/images/sysdig-operator-ready.png)

You can verify that all the agents (you should have exactly one per node) are `READY` and in `Running` state. The Sysdig operator itself should also be `READY` and in `Running` state:

```
$ oc get pods -n sysdig-agent
NAME                                  READY   STATUS    RESTARTS   AGE
basic-agent-deployment-sysdig-24xpm   1/1     Running   0          19m
basic-agent-deployment-sysdig-6ngpv   1/1     Running   0          19m
basic-agent-deployment-sysdig-8q79t   1/1     Running   0          19m
basic-agent-deployment-sysdig-99rvx   1/1     Running   0          19m
basic-agent-deployment-sysdig-mjjst   1/1     Running   0          19m
basic-agent-deployment-sysdig-zrrnc   1/1     Running   0          19m
sysdig-operator-86c489b6fd-7tmd5      1/1     Running   0          22m
```

## Settings

This operator, uses the same options than the [Helm Chart](https://hub.helm.sh/charts/stable/sysdig), please take a look to all the options in the following table:

| Parameter                         | Description                                                            | Default                                     |
| ---                               | ---                                                                    | ---                                         |
| `image.registry`                  | Sysdig Agent image registry                                            | `docker.io`                                 |
| `image.repository`                | The image repository to pull from                                      | `sysdig/agent`                              |
| `image.tag`                       | The image tag to pull                                                  | `9.9.1`                                     |
| `image.pullPolicy`                | The Image pull policy                                                  | `IfNotPresent`                              |
| `image.pullSecrets`               | Image pull secrets                                                     | `nil`                                       |
| `resources.requests.cpu`          | CPU requested for being run in a node                                  | `600m`                                      |
| `resources.requests.memory`       | Memory requested for being run in a node                               | `512Mi`                                     |
| `resources.limits.cpu`            | CPU limit                                                              | `2000m`                                     |
| `resources.limits.memory`         | Memory limit                                                           | `1536Mi`                                    |
| `rbac.create`                     | If true, create & use RBAC resources                                   | `true`                                      |
| `serviceAccount.create`           | Create serviceAccount                                                  | `true`                                      |
| `serviceAccount.name`             | Use this value as serviceAccountName                                   | ` `                                         |
| `daemonset.updateStrategy.type`   | The updateStrategy for updating the daemonset                          | `RollingUpdate`                             |
| `daemonset.affinity`              | Node affinities                                                        | `nil`                                       |
| `daemonset.nodeSelector`          | Node selector                                                          | `kubernetes.io/arch:amd64`                  |
| `slim.enabled`                    | Use the slim based Sysdig Agent image                                  | `false`                                     |
| `slim.kmoduleImage.repository`    | The kernel module image builder repository to pull from                | `sysdig/agent-kmodule`                      |
| `slim.resources.requests.cpu`     | CPU requested for building the kernel module                           | `1000m`                                     |
| `slim.resources.requests.memory`  | Memory requested for building the kernel module                        | `348Mi`                                     |
| `slim.resources.limits.memory`    | Memory limit for building the kernel module                            | `512Mi`                                     |
| `ebpf.enabled`                    | Enable eBPF support for Sysdig instead of `sysdig-probe` kernel module | `false`                                     |
| `ebpf.settings.mountEtcVolume`    | Needed to detect which kernel version are running in Google COS        | `true`                                      |
| `sysdig.accessKey`                | Your Sysdig Monitor Access Key                                         | `Nil` You must provide your own key         |
| `sysdig.settings`                 | Settings for agent's configuration file                                | ` `                                         |
| `secure.enabled`                  | Enable Sysdig Secure                                                   | `true`                                      |
| `auditLog.enabled`                | Enable K8s audit log support for Sysdig Secure                         | `false`                                     |
| `auditLog.auditServerUrl`         | The URL where Sysdig Agent listens for K8s audit log events            | `0.0.0.0`                                   |
| `auditLog.auditServerPort`        | Port where Sysdig Agent listens for K8s audit log events               | `7765`                                      |
| `auditLog.dynamicBackend.enabled` | Deploy the Audit Sink where Sysdig listens for K8s audit log events    | `false`                                     |
| `customAppChecks`                 | The custom app checks deployed with your agent                         | `{}`                                        |
| `tolerations`                     | The tolerations for scheduling                                         | `node-role.kubernetes.io/master:NoSchedule` |
| `scc.create`                      | Create OpenShift's Security Context Constraint                         | `false`                                     |

For example, if you want to deploy a DaemonSet with eBPF and with Sysdig Secure
enabled:

```yaml
apiVersion: sysdig.com/v1
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

Please, notice that `sysdig.accessKey` is **mandatory**. Once you have provided
the accessKey, you can apply this file with `kubectl apply -f`

And then you can see you pods with the Sysdig Agent deployed:

```shell
$ kubectl get pods
NAME                                                              READY   STATUS    RESTARTS   AGE
agent-with-ebpf-and-secure-9wexzni4dib601y2ik5kc1vi5-sysdi2w9m4   1/1     Running   0          2m
agent-with-ebpf-and-secure-9wexzni4dib601y2ik5kc1vi5-sysdil8d9q   1/1     Running   0          2m
agent-with-ebpf-and-secure-9wexzni4dib601y2ik5kc1vi5-sysdiv2vgs   1/1     Running   0          2m
sysdig-operator-7f6cf49bb4-cwxcn                                  1/1     Running   0          2m
```

## Removal

Just run the `kubectl delete` command to remove the operator and its dependencies.

```shell
kubectl delete -f https://raw.githubusercontent.com/sysdiglabs/sysdig-operator/master/bundle.yaml
```

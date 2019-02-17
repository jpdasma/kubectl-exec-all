# exec-all

## Overview

Run a command in all of the containers in a specific resource.

## Install using krew

`kubectl krew install exec-all`

## Usage

```
kubectl exec-all [-c container_name] [-p number_parallel_executions] [-n namespace] resource resource_name command
```

## Examples

Execute "docker system prune -a -f" in all of the containers in a daemonset named docker-daemon (with mounted docker.sock)

```
kubectl exec-all daemonset docker-daemon docker system prune -a -f
```

Check a specific log for all the container specified with selector.

```
kubectl exec-all -s "label=app" cat /var/log/test.log
```

# exec-all

## Overview

Run a command in all of the containers in a specific resource.

## Install
Copy the exec-all directory inside the `~/.kube/plugins` directory

## Usage

```
kubectl plugin exec-all [-c $CONTAINER] [-p $NUMBER_OF_PARALLEL_EXECUTION] $RESOURCE_TYPE $RESOURCE_NAME -- $COMMAND
```

## Examples

Execute "docker system prune -a -f" in all of the containers in a daemonset named docker-daemon (with mounted docker.sock)

```
kubectl plugin exec-all daemonset docker-daemon -- docker system prune -a -f
```

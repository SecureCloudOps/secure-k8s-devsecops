package k8s

den[msg] {
  input.kind == "Deployment"
  c := input.spec.template.spec.containers[_]
  endswith(c.image, ":latest")
  msg := sprintf("container %s uses latest tag", [c.name])
}

den[msg] {
  input.kind == "Deployment"
  c := input.spec.template.spec.containers[_]
  not c.resources.requests.cpu
  msg := sprintf("container %s missing cpu request", [c.name])
}

den[msg] {
  input.kind == "Deployment"
  c := input.spec.template.spec.containers[_]
  not c.resources.requests.memory
  msg := sprintf("container %s missing memory request", [c.name])
}

den[msg] {
  input.kind == "Deployment"
  c := input.spec.template.spec.containers[_]
  not c.resources.limits.cpu
  msg := sprintf("container %s missing cpu limit", [c.name])
}

den[msg] {
  input.kind == "Deployment"
  c := input.spec.template.spec.containers[_]
  not c.resources.limits.memory
  msg := sprintf("container %s missing memory limit", [c.name])
}

den[msg] {
  input.kind == "Deployment"
  c := input.spec.template.spec.containers[_]
  c.securityContext.privileged == true
  msg := sprintf("container %s is privileged", [c.name])
}

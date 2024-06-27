# Triton w/ vllm on OpenShift

This repo helps to quickly configure Titon w/ vllm

## Quick Start

```sh
# deployment with aws gp2/3
until oc apply -k bootstrap/overlays/default; do : ; done

# deployment with odf storage
until oc apply -k bootstrap/overlays/odf; do : ; done

# add hugging face secret to env
oc -n llm-journey apply -f deployment/hf-secret.yaml
oc set env --from=secret/hugging-face-info deploy/triton-vllm-inference-server

# download model
# oc rsh deploy/triton-vllm-inference-server
# . /scripts/init.sh; model_download
```

## Uninstall

```sh
# delete storage cluster
oc -n openshift-storage delete storagecluster ocs-storagecluster

# remove: deployment with aws gp2/3
oc delete -k bootstrap/overlays/default

# remove: deployment with odf storage
oc delete -k bootstrap/overlays/odf
```

## Related Links

- https://github.com/redhat-na-ssa/demo-ai-gitops-catalog
- https://github.com/triton-inference-server/tutorials/blob/main/Quick_Deploy/vLLM/README.md
- https://github.com/awslabs/data-on-eks/tree/main/gen-ai/inference/vllm-nvidia-triton-server-gpu

### Triton Inference Server Wrapper

This project contains a container wrapper around the NVIDIA Triton Inference Server for serving LLMs:

- https://github.com/carlmes/triton-vllm-inference-server
- https://github.com/triton-inference-server/vllm_backend

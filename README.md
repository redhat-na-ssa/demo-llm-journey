# Triton w/ vllm on OpenShift

This repo helps to quickly configure Titon w/ vllm

## Obtaining Models from Hugging Face

Most of the models are available on model registry sites, the primary location for most of these is [Hugging Face](https://huggingface.co), which contains the models that are compatible with the inference server backend ([such as vLLM](https://docs.vllm.ai/en/stable/models/supported_models.html)). 

While most of these models are open, they are gated - meaning that a user must register for a Hugging Face account, and agree to each specific models terms and conditions before being able to download these.

In order to automate the process when the inference serving container starts up, a [user access token](https://huggingface.co/docs/hub/security-tokens) must be generated and supplied as an environment variable.

Steps to obtain the Hugging Face Hub Token:

- Sign up for an account at [huggingface.co](https://huggingface.co), and login
- Navigate to your user profile, settings, Access Tokens
- Create a new access token, and copy the details to a safe location

> Note: vLLM requires models in [Hugging Face Transformer Format](https://docs.vllm.ai/en/stable/models/supported_models.html#supported-models), this is why we pick Llama-2-7b-hf over Llama-2-7b, which doesn't have the model in a supported format for serving using vLLM. The Llama models can alternatively be downloaded directly from Meta by following these instructions: https://github.com/meta-llama/llama#download, however they will not be in the correctly supported format.

## Quick Start Deployment

```sh
# deployment with aws gp2/3
until oc apply -k bootstrap/overlays/default; do : ; done

# deployment with odf storage
until oc apply -k bootstrap/overlays/odf; do : ; done

# download model
# oc rsh deploy/triton-vllm-inference-server
# . /scripts/init.sh; model_download
```

Add your Hugging Face Hub Token credentials to the secret:

```sh
# add hugging face secret to env
oc -n llm-journey apply -f deployment/hf-secret.yaml
oc set env --from=secret/hugging-face-info deploy/triton-vllm-inference-server
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

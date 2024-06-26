# demo-llm-journey

Demo LLM things

## Quick Start

```sh
# deployment with aws gp2/3
until oc apply -k bootstrap/overlays/default; do : ; done

# deployment with odf storage
until oc apply -k bootstrap/overlays/odf; do : ; done
```

## Related Links

- https://github.com/redhat-na-ssa/demo-ai-gitops-catalog
- https://github.com/triton-inference-server/tutorials/blob/main/Quick_Deploy/vLLM/README.md

### Triton Inference Server Wrapper

This project contains a container wrapper around the NVIDIA Triton Inference Server for serving LLMs:

- https://github.com/carlmes/triton-vllm-inference-server
- https://github.com/triton-inference-server/vllm_backend

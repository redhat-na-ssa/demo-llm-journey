# Downloading and Caching the Models

This section describes how the LLM models are downloaded and cache on the local Persistent Volume, and mounted as a directory on the running container in order to provide a cached copy for the Triton server to load.

## Manually Downloading

> TODO: Instructions for downloading using the terminal

## Setting up an Automatic Download

> TODO: Add an initContainer to download the model from HuggingFace

## Setting up the Model Registry

> TODO: Update this to use ConfigMaps

Download the various models to a location on disk. On a local machine, this directory will be attached to the container using podman arguments, the on an OpenShift cluster it will be a Persistent Volume. For example, here's how to download the Llama-2-7b model:
```sh
$ mkdir ~/Downloads/model_registry && cd ~/Downloads/model_registry

$ git clone https://${HUGGING_FACE_HUB_USER}:${HUGGING_FACE_HUB_TOKEN}@huggingface.co/meta-llama/Llama-2-7b-hf 
```

> Note: vLLM requires models in [Hugging Face Transformer Format](https://docs.vllm.ai/en/stable/models/supported_models.html#supported-models), this is why we pick Llama-2-7b-hf over Llama-2-7b, which doesn't have the model in a supported format for serving using vLLM. The Llama models can be downloaded from meta by following these instructions: https://github.com/meta-llama/llama#download, however they will not be in a supported format.

Next, we add some configuration files into the model_repository location on disk to identify our model(s). For reference, see the [example model repository](https://github.com/triton-inference-server/vllm_backend/tree/main/samples/model_repository), instructions on the [vLLM backend](https://github.com/triton-inference-server/vllm_backend/blob/main/README.md#using-the-vllm-backend) repo as well as the [Triton Quickstart Guide](https://github.com/triton-inference-server/tutorials/blob/main/Quick_Deploy/vLLM/README.md#step-1-prepare-your-model-repository).

```
model_repository (provide this dir as source / MODEL_REPOSITORY )
└── vllm_model
    ├── 1
    │   └── model.json
    ├── Llama-2-7b-hf
    │   └── model files...
    └── config.pbtxt
```

Here are example files that work with the Llama-2-7B-hf model:

**model.json**
```json

{
    "model": "/opt/app-root/mnt/model_repository/vllm_model/Llama-2-7b-hf",
    "disable_log_requests": "true",
    "gpu_memory_utilization": 1
}
```

**config.pbtxt**
```
backend: "vllm"

instance_group [
  {
    count: 1
    kind: KIND_MODEL
  }
]

model_transaction_policy {
  decoupled: True
}

max_batch_size: 0

# https://github.com/triton-inference-server/server/issues/6578#issuecomment-1813112797
# Note: The vLLM backend uses the following input and output names.
# Any change here needs to also be made in model.py

input [
  {
    name: "text_input"
    data_type: TYPE_STRING
    dims: [ 1 ]
  },
  {
    name: "stream"
    data_type: TYPE_BOOL
    dims: [ 1 ]
  },
  {
    name: "sampling_parameters"
    data_type: TYPE_STRING
    dims: [ 1 ]
    optional: true
  }
]

output [
  {
    name: "text_output"
    data_type: TYPE_STRING
    dims: [ -1 ]
  }
]
```

> Note: Configuration extracted from: https://github.com/triton-inference-server/server/issues/6578
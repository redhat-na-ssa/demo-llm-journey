#!/bin/sh
# set -e

MODEL_REPOSITORY="${MODEL_REPOSITORY:-/opt/app-root/model_repository}"
MODEL_CACHE="${MODEL_CACHE:-/opt/app-root/models}"

create_trition_examples(){    
  git clone --depth=1 https://github.com/triton-inference-server/server.git /tmp/repo

  mv /tmp/repo/docs/examples/models_repository/* "${MODEL_REPOSITORY}/"

  (cd /tmp && \
    bash /tmp/repo/docs/examples/fetch_models.sh && \
    mv models_repository/* "${MODEL_REPOSITORY}/"
  )
}

download_model_from_huggingface(){
  which huggingface-cli || return
  [ -n "${HUGGING_FACE_HUB_TOKEN}" ] || return
  [ -n "${HUGGING_FACE_MODEL}" ] || return

  huggingface-cli env
  huggingface-cli download \
    --token "${HUGGING_FACE_HUB_TOKEN}" \
    --repo-type model \
    --local-dir "${MODEL_CACHE}/${HUGGING_FACE_MODEL}" \
    "${HUGGING_FACE_MODEL}"
}

model_download(){
  download_model_from_huggingface
}

model_generate_config(){
  MODEL_PATH="${MODEL_REPOSITORY}/vllm_model"
  [ -d "${MODEL_PATH}/1" ] || mkdir -p "${MODEL_PATH}/1"

  [ -e /scripts/config.pbtxt ] || return
  [ -e /scripts/model.json ]   || return

  cp /scripts/config.pbtxt  "${MODEL_PATH}/"
  cp /scripts/model.json    "${MODEL_PATH}/1/"

  # print_config_pbtxt_via_curl > "${MODEL_PATH}/config.pbtxt"
  # print_config_model_via_echo > "${MODEL_PATH}/1/model.json"
}

model_test(){
  # see https://github.com/vllm-project/vllm/blob/736ed388492c5c10deb7522637a94c041f163f48/vllm/sampling_params.py#L38
  curl -X POST localhost:8000/v2/models/vllm_model/generate -d '{"text_input": "Who is Red Hat", "parameters": {"max_tokens": "200", "temperature": 0.1, "stream": false}}'
}

# vllm_client(){
#   URL=https://github.com/awslabs/data-on-eks/raw/main/gen-ai/inference/vllm-nvidia-triton-server-gpu/triton-client/prompts.txt
#   curl -sLO "${URL}"
#   URL=https://github.com/awslabs/data-on-eks/raw/main/gen-ai/inference/vllm-nvidia-triton-server-gpu/triton-client/triton-client.py
#   curl -sLO "${URL}"

#   python3 triton-client.py
# }

# print_config_pbtxt_via_curl(){
#   URL="https://raw.githubusercontent.com/redhat-na-ssa/demo-llm-journey/main/deployment/config.pbtxt"
#   echo "# see ${URL}"
#   curl -sL "${URL}"
# }

# print_config_model_via_echo(){
#     MODEL_PATH="${MODEL_CACHE}/${HUGGING_FACE_MODEL}"

# cat << JSON
# {
#   "model": "${MODEL_PATH}",
#   "disable_log_requests": "true",
#   "gpu_memory_utilization": 0.8,
#   "enforce_eager": "true",
#   "max_model_len": 4096
# }
# JSON
# }

model_download
[ -d "${MODEL_CACHE}/${HUGGING_FACE_MODEL}" ] && model_generate_config

echo "Init Complete"

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

vllm_download_model_from_huggingface(){
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

vllm_generate_model_config(){
  MODEL_PATH="${MODEL_REPOSITORY}/vllm_model"
  [ -d "${MODEL_PATH}/1" ] || mkdir -p "${MODEL_PATH}/1"

  print_config_pbtxt > "${MODEL_PATH}/config.pbtxt"
  print_config_model > "${MODEL_PATH}/1/model.json"
}

vllm_curl(){
  curl -X POST localhost:8000/v2/models/vllm_model/generate -d '{"text_input": "What is Triton Inference Server?", "parameters": {"stream": false, "temperature": 0}}'
}

print_config_pbtxt(){
  URL="https://raw.githubusercontent.com/redhat-na-ssa/demo-llm-journey/main/deployment/config.pbtxt"
  echo "# see ${URL}"
  curl -sL "${URL}"
}

print_config_model(){
    MODEL_PATH="${MODEL_CACHE}/${HUGGING_FACE_MODEL}"

cat << JSON
{
  "model": "${MODEL_PATH}",
  "disable_log_requests": "true",
  "gpu_memory_utilization": 0.8,
  "enforce_eager": "true",
  "max_model_len": 4096
}
JSON
}

[ -d "${MODEL_CACHE}/${HUGGING_FACE_MODEL}" ] && vllm_generate_model_config

echo "Init Complete"

#!/bin/sh
# set -e

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
    --local-dir "${MODEL_REPOSITORY}/" \
    "${HUGGING_FACE_MODEL}"
}

echo "Init Complete"

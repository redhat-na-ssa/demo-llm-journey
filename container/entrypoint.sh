#!/bin/sh
# set -e

usage(){
  "${STI_SCRIPTS_PATH}/usage"
}

# fallback with sleep to debug your code
# oc rsh / podman exec -it .. /bin/sh
run_sleep(){
  echo "Ponder the universe with infinate sleep..."
  sleep infinity
}

# run normal s2i scripts
run_default(){
  NVIDIA_ENTRYPOINT=/opt/nvidia/nvidia_entrypoint.sh

  [ -e /NGC-DL-CONTAINER-LICENSE ] && cat /NGC-DL-CONTAINER-LICENSE

  if [ -e "${NVIDIA_ENTRYPOINT}" ]; then
    "${NVIDIA_ENTRYPOINT}" "$@"
  else
    exec "$@"
  fi
}

run_init(){
  # want to do something custom before you start
  echo "
  These messages brought to you by bash.
  
  Reticulating splines...
  Fetching dataset during runtime...
  "
}

usage

run_init
run_default
run_sleep

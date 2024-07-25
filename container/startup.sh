#!/usr/bin/env bash
set -e
set -u

# Check for libGLX_nvidia.so.0 (needed for vulkan)
ldconfig -p | grep libGLX_nvidia.so.0 || NOTFOUND=1
if [[ -v NOTFOUND ]]; then
    cat << EOF > /dev/stderr

Fatal Error: Can't find libGLX_nvidia.so.0...

Ensure running with NVIDIA runtime. (--gpus all) or (--runtime nvidia)

EOF
    exit 1
fi

# Detect NVIDIA Vulkan API version, and create ICD:
export VK_ICD_FILENAMES=/tmp/nvidia_icd.json

# Only required if needed to load a specific sample file during application launch by default.
# USD_PATH="${USD_PATH:-/app/samples/stage01.usd}"

USER_ID="${USER_ID:-""}"
if [ -z "${USER_ID}" ]; then
echo "User id is not set"
fi

WORKSTREAM="${OV_WORKSTREAM:-"omni-saas-int"}"

export HSSC_SC_MEMCACHED_SERVICE_NAME="memcached-service-r3"
export HSSC_SC_MEMCACHED_REDISCOVER="1"
export HSSC_SC_CLIENT_LOGFILE_ROOT=/tmp/renders/hssc
mkdir -p /tmp/renders

__GL_F32B90a0=$(find /opt/nvidia/omniverse/hssc_shader_cache_client_lib -path \*release/lib\* -name libhssc_shader_cache_client.so)
echo "Found hssc client so in: $__GL_F32B90a0"
export __GL_F32B90a0
export __GL_a011d7=1   # OGL_VULKAN_GFN_SHADER_CACHE_CONTROL=ON
export __GL_43787d32=0 #  OGL_VULKAN_SHADER_CACHE_TYPE=NONE
export __GL_3489FB=1   # OGL_VULKAN_IGNORE_PIPELINE_CACHE=ON

export OPENBLAS_NUM_THREADS=10

CMD="${OVC_APP_PATH}/kit/kit"
ARGS=(
    "${OVC_APP_PATH}/apps/${OVC_KIT}"
    "--no-window"
    "--/privacy/userId=${USER_ID}"
    "--/crashreporter/data/workstream=${WORKSTREAM}"
    "--/exts/omni.kit.window.content_browser/show_only_collections/2="
    "--/exts/omni.kit.window.filepicker/show_only_collections/2="
    "--ext-folder /home/ubuntu/.local/share/ov/data/exts/v2"
    "--/crashreporter/gatherUserStory=0"
    "--/crashreporter/includePythonTraceback=0"
    #"--${OVC_APP_PATH}/auto_load_usd=${USD_PATH}" # Comment out if you don't need to auto load a specific USD file


)

# Since we won't have access for
echo "==== Print out kit config OVC_KIT=${OVC_KIT} for debugging ===="
cat ${OVC_APP_PATH}/apps/${OVC_KIT}
echo "==== End of kit config ${OVC_KIT} ===="

echo "Starting usd viewer with $CMD ${ARGS[@]} $@"

exec "$CMD" "${ARGS[@]}" "$@"

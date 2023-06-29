
container_name="carla_22"
image_name="carla-22:test"

ROOT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)"

echo "Root folder: ${ROOT_FOLDER}"

xhost +local:root

if docker ps -a | grep -w -q "$container_name"; then
    # Start the existing container and enter it
    echo "Starting existing container \"$container_name\""
    docker start "$container_name"
    docker exec -ti "$container_name" bash
else
    docker run -ti \
            --gpus all \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -v /etc/vulkan/icd.d:/etc/vulkan/icd.d \
            --net host \
            -e DISPLAY \
            --privileged \
            --device /dev/dri \
            --cpus=$(($(nproc) - 1)) --cpuset-cpus=0-$(($(nproc) - 2)) \
            --name "$container_name" \
            -v ${ROOT_FOLDER}/carla/Docker/.bash_history_container:/root/.bash_history\
            -v ${ROOT_FOLDER}/UnrealEngine:/home/UnrealEngine\
            -v ${ROOT_FOLDER}/carla:/home/carla\
            ${image_name} bash
fi

xhost -local:root
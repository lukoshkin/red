#!/bin/bash

[[ "$@" = *=* ]] && { echo '= is invalid sign in arguments'; exit 1; }

ncores=4
if [[ $1 =~ -n ]]
then
  ncores=$2
  shift 2
fi

[[ -n $1 ]] && img=$1 || img=red


find_string () {
  local sel=$1
  shift

  for str in $@
  do
    [[ $str = $sel ]] && return 0
  done
  return 1
}

containers=$(docker ps -a --format '{{.Names}}')
find_string $img $containers \
  && { echo container \"$img\" already exists; exit 1; }


mkdir -p vimmed

docker build --build-arg UID=`id -u` --build-arg GID=`id -g` --build-arg N_CORES=$ncores -t $img . \
&& wget -O vimmed/Dockerfile https://raw.githubusercontent.com/lukoshkin/evangelist/master/Dockerfile \
&& docker build --build-arg IMG_NAME=$img -t $img vimmed/ \
&& rm -rf vimmed || :

[[ $? -ne 0 ]] && { echo Problems with building the images; exit 1; }
unzip -n PoreFlow*.zip -d project 2> /dev/null \
  && chmod +x project/bin/poremesh

[[ -d project  && -d examples ]] \
  && docker run --name $img \
    -v $PWD/project:/home/red/project \
    -v $PWD/examples:/home/red/project/examples \
    -e TERM=xterm-256color -ti -d $img \
  && cp helpers/* examples/

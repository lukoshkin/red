#!/bin/bash

ncores=4
if [[ $1 =~ -n(=| )?[0-9]+$ ]]
then
  ncores=$(sed -r 's/-n.*([0-9])/\1/' <<< $1)
  shift
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


docker build --build-arg UID=`id -u` --build-arg GID=`id -g` --build-arg N_CORES=$ncores -t $img . \
&& wget -O Vimmed.Dockerfile https://raw.githubusercontent.com/lukoshkin/evangelist/master/Dockerfile \
&& docker build --build-arg IMG_NAME=$img -t $img Vimmed.Dockerfile \
&& rm -f Vimmed.Dockefile

[[ $? -ne 0 ]] && { echo Problems with building the images; exit 1; }
unzip PoreFlow*.zip -d project 2> /dev/null

[[ -d project  && -d examples ]] \
  && docker run --name $img \
    -v project:/home/red/project \
    -v examples:/home/red/project/examples \
    -e TERM=xterm-256color -ti -d $img \
  && cp helpers/* project/examples/

#!/bin/bash

[[ "$@" = *=* ]] && { echo '= is invalid sign in arguments'; exit 1; }


uid=$(id -u)
gid=$(id -g)

ncores=4
examples="$PWD/examples"


help_msg () {
  echo 'Usage: ./setup.sh [opts] [img_name]'
  echo -e '\nOptions:'
  printf '  %-16s Mount a folder with examples.\n' '-e'
  printf "  %-16s Specify user IDs inside the container.\n" '-i'
  printf '  %-16s Set the number of cores for building the base image.\n' '-n'
  echo
}

params=$(getopt -o e:,i:,n: --name "$0" -- "$@")
[[ $? -ne 0 ]] && { help_msg; exit; }
eval set -- $params
unset params

([[ $@ =~ '-i' ]] && ! grep -qE '\-i [0-9]{3,},[0-9]{3,}' <<< $@) \
  && { echo 'Incorrect specification of a <UID,GID> pair'; exit 1; }


while [[ $1 != '--' ]]
do
  case $1 in
    -n) ncores=$2; shift 2 ;;
    -e) examples=$2; shift 2 ;;
    -i)
      uid=$(cut -d ',' -f1 <<< $2);
      gid=$(cut -d ',' -f2 <<< $2);
      shift 2 ;;
    *) echo Invalid arg; exit 1 ;;
  esac
done
shift

[[ $# -gt 1 ]] && { echo More than one positional argument given!; exit 1; }
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

docker build --build-arg UID=$uid --build-arg GID=$gid --build-arg N_CORES=$ncores -t $img . \
  && wget -O vimmed/Dockerfile https://raw.githubusercontent.com/lukoshkin/evangelist/master/Dockerfile \
  && docker build --build-arg IMG_NAME=$img -t $img vimmed/ \
  && rm -rf vimmed || :

[[ $? -ne 0 ]] && { echo Problems with building the images; exit 1; }
unzip -n PoreFlow*.zip -d project 2> /dev/null \
  && chmod +x project/bin/poremesh

echo
[[ -d project  && -d $examples ]] \
  && { docker run --name $img \
         -v $PWD/project:/home/red/project \
         -v $examples:/home/red/project/examples \
         -e TERM=xterm-256color -ti -d $img \
      && cp helpers/* $examples/ \
      && echo Successfully launched: $img container; } \
  || >&2 echo Missing elements in the structure: 'PoreFlow*.zip' or $examples

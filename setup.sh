#!/bin/bash

[[ "$@" = *=* ]] && { echo '= is invalid sign in arguments'; exit 1; }

source utils/utils.sh


uid=$(id -u)
gid=$(id -g)

ncores=4
examples="$PWD/examples"
strip_sfu_zip_flag=false
save_base_img_flag=false


params=$(getopt -o e:,i:,n:,sb,sz --name "$0" -- "$@")
[[ $? -ne 0 ]] && { utils::help_msg; exit; }
eval set -- $params
unset params

([[ $@ =~ '-i' ]] && ! grep -qE '\-i [0-9]{3,},[0-9]{3,}' <<< $@) \
  && { echo 'Incorrect specification of a <UID,GID> pair'; exit 1; }


while [[ $1 != '--' ]]
do
  case $1 in
    -n) ncores=$2; shift 2 ;;
    -e) examples=$2; shift 2 ;;
    -sz) strip_sfu_zip_flag=true; shift ;;
    -sb) save_base_img_flag=true; shift ;;
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

base=$img
save_base_img_flag && base+=':base'


containers=$(docker ps -a --format '{{.Names}}')
utils::find_string $img $containers \
  && { echo container \"$img\" already exists; exit 1; }


mkdir -p vimmed

docker build --build-arg UID=$uid --build-arg GID=$gid --build-arg N_CORES=$ncores -t $base . \
  && wget -O vimmed/Dockerfile https://raw.githubusercontent.com/lukoshkin/evangelist/master/Dockerfile \
  && docker build --build-arg IMG_NAME=$base -t $img vimmed/ \
  && rm -rf vimmed || :

[[ $? -ne 0 ]] && { echo Problems with building the images; exit 1; }

if strip_sfu_zip_flag
then
  utils::strip_zip_2dir PoreFlow*.zip project
else
  unzip -n PoreFlow*.zip -d project 2> /dev/null || echo PoreFlow*.zip not found.
  chmod +x project/bin/poremesh || echo PoreFlow*.zip has a different structure than expected.
fi

echo
[[ -d project  && -d $examples ]] \
  && { docker run --name $img \
         -v $PWD/project:/home/red/project \
         -v $examples:/home/red/project/examples \
         -e TERM=xterm-256color -ti -d $img \
      && cp helpers/* $examples/ \
      && echo Successfully launched: $img container; } \
  || >&2 echo Missing elements in the structure: 'PoreFlow*.zip' or $examples

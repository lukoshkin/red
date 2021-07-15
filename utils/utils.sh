utils::help_msg () {
  echo 'Usage: ./setup.sh [opts] [img_name]'
  echo -e '\nOptions:'
  printf '  %-16s Mount a folder with examples.\n' '-e'
  printf "  %-16s Specify user IDs inside the container.\n" '-i'
  printf '  %-16s Set the number of cores for building the base image.\n' '-n'
  echo
}


utils::find_string () {
  local sel=$1
  shift

  for str in $@
  do
    [[ $str = $sel ]] && return 0
  done
  return 1
}

utils::strip_zip_2dir () {
  mkdir $2
  unzip -d $2 $1 2> /dev/null

  if [[ $(ls $2 | wc -w) -gt 1 ]]
  then
    rm -rf $2
    >&2 echo Unexpected zip structure
    exit 1
  fi

  local dir=$(ls $2)
  mv $2/*/* $2
  rmdir $2/$dir
}

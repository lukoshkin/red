#!/bin/bash

help_msg () {
  echo 'Synopsis:'
  printf '%-4s./simg.make setup\n'
  printf '%-4s./simg.make [-n <nparts>] <example>\n'
  printf '%-4s./simg.make run [-N <nnodes>][-p <queue>][--mem <nG>] <example>\n'
  printf '%-4s./simg.make vtk <example> [<vtk-range>]\n'
  printf '%-4s./simg.make clean[-geom|-all] <example>\n'
}


setup () {
  [[ $# -ne 0 ]] && { echo "setup doesn't take arguments"; exit 1; }
  unzip -oqqd project PoreFlow*.zip
  cp helpers/* examples/
  chmod +x project/bin/poremesh
}


exec_cmd () {
  [[ -z $1 || -z $2 ]] && { help_msg; return; }
  [[ -d examples/$2 ]] || { echo "Example doesn't exist."; exit 1; }

  local cmd
  cmd="source .bashrc && cd project/examples && make"
  cmd+=" $1 EX=$2 ${@:3}"
  singularity exec --no-home --pwd /home/red \
    -B $PWD/project:/home/red/project \
    -B $PWD/examples:/home/red/project/examples \
    red.simg /bin/bash -c "$cmd"
}


make () {
  params=$(getopt -o n: --name "$0" -- "$@")
  [[ $? -ne 0 ]] && { help_msg; exit 1; }
  eval set -- $params
  unset params

  [[ $1 = '-n' ]] && { npart=$2; shift 3; } || shift

  if [[ -n $npart ]]
  then
    [[ $npart =~ ^[0-9]+$ ]] || { echo '-n: Invalid value'; exit 1; }
    [[ -z $1 ]] && { echo 'Name of example required'; exit 1; }
    sed -ri "s/^(NPart )[0-9]+/\1$npart/" examples/$1/param.txt
  fi

  exec_cmd all "$1"
}


run () {
  params=$(getopt -o p:,N: -l mem: --name "$0" -- "$@")
  [[ $? -ne 0 ]] && { help_msg; exit 1; }
  eval set -- $params
  unset params

  declare -A opts
  while [[ $1 != '--' ]]
  do
    case $1 in
      -p) opts["-p "]=$2; shift 2 ;;
      -N) opts['-N ']=$2; shift 2 ;;
      --mem) opts['--mem=']=$2; shift 2 ;;
      *) echo Invalid option.; exit 1 ;;
    esac
  done
  shift

  [[ -z $1 ]] && { echo Positional argument required.; exit 1; }
  [[ -d examples/$1 ]] || { echo "Example doesn't exist."; exit 1; }
  nproc=$(sed -rn "s;^NPart ([0-9]+).*;\1;p" examples/$1/param.txt)
  heredoc=$(sed -r \
    -e "s;^(#SBATCH -n).*;\1 $nproc;" \
    -e "s;^(example=).*;\1$1;" helpers/run.sh)

  for key in "${!opts[@]}"
  do
    heredoc=$(sed -r "s;^(#SBATCH $key).*;\1${opts[$key]};" <<< "$heredoc")
  done

  sbatch --job-name=$1 \
    -o ${1}:${opts['-N ']:+-}${nproc}.out \
    -e ${1}:${opts['-N ']:+-}${nproc}.err \
    <<< "$heredoc"
}


vtk () {
  [[ -n $2 ]] && ![[ $2 =~ ^[0-9]+-?[0-9]*$ ]] && echo Invalid vtk range.
  exec_cmd vtk $1 $2
}


clean () {
  [[ -z $2 ]] && { echo Example required.; exit 1; }
  exec_cmd $@
}



main () {
  case $1 in
    setup) setup ;;
    run) shift; run $@ ;;
    vtk) shift; vtk $@ ;;
    clean|clean-geom|clean-all) clean $@ ;;
    *) make $@ ;;
  esac
}



main $@

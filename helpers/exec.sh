# Complex command to call `singularity <image> exec bash $0`

dir=$1
sflow=$2

cd $dir
$sflow pore.apr pore.ini

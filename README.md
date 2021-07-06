# Wrapper for SFU Solver

## Preparation

1. ```git clone https://github.com/lukoshkin/red.git```
1. Download from gdrive the latest version of the SFU code
   to `red` folder.
1. Run `setup.sh` with required options.  

   * For example, ```./setup.sh -n 8 -i 1042,1507 -e /abs/path/to/examples lapuza```  
   will result in `uid=1042` and `gid=1507` inside the running container `lapuza` with
   bind mount that mounts `/abs/path/to/examples` on the host to `/home/red/project/examples`
   in the container. The option `-n` specifies the number of cores used
   when building the base image.

   * Defaults for this script have already nice values:  
   `-n 4`, `-i $(id -u),$(id -g)`, `-e "$PWD/examples"`, container's name - `red`

1. Get into the container named `lapuza` with  
   ```docker attach lapuza``` or ```docker exec -ti lapuza bash```


## Usage

The control over the SFU code is carried out through `make`.
Thus, in the container, a user goes to the folder with examples where
also Makefile resides: `cd project/examples`. Then, they choose an example
to work with, e.g., `small`, and adjust its `model.mhd` (and `param.txt` if need be)

```
vim small/geom/model.mhd
vim small/param.txt
```

When everything is ready for launch, run an example named `small` with

```
make run EX=small
```

To clean the folder of `small` example from the calculation results, mesh partition files,
or all of the aforementioned, run one the listed commands, correspondingly:

```
make clean EX=small
make clean-geom EX=small
make clean-all EX=small
```

To plot the results of calculations that can be viewed then in ParaView, use

```
make vtk EX=small VTK_RANGE=1-10
```

Where `VTK_RANGE` specifies what saved states of unstationary calculations
are to be presented in the visualization data. For the stationary case,
the last argument is always omitted. In the unstationary case, if ignored,
the maximum possible range is chosen. To plot just the last saved state
(via CHECK or SAVE), pass `VTK_RANGE=0`. The results will appear in `small/VTK`.


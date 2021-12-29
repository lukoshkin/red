# Wrapper for SFU Solver

## Requirements

1. installed Docker/Singularity.
1. access to SFU code.

## Preparation

1. ```git clone https://github.com/lukoshkin/red.git```
1. Download from gdrive the latest version of the SFU code
   to `red` folder.
1. Run `./setup.sh` with required options (see [options for `setup.sh`](#options-for-setupsh)).
1. Get into the container named `lapuza` with  
   ```docker attach lapuza``` or ```docker exec -ti lapuza bash```


## Usage

The control over the SFU code is carried out through `make`. Thus, in the
container, user goes to the folder with examples where also Makefile resides:
`cd project/examples`. Then, they choose an example to work with, e.g.,
`small`, and adjust its `model.mhd` (and `param.txt` if need be)

```
vim small/geom/model.mhd
vim small/param.txt
```

When everything is ready for launch, run an example named `small` with

```bash
make EX=small  # required every time one changes settings
make run EX=small
```

To clean the folder of `small` example from the calculation results, mesh
partition files, or all of the aforementioned, run one the listed commands,
correspondingly:

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

## Options for `setup.sh`

Here are some points that help to gain more control over the script:

   * Running ```./setup.sh -n 8 -i 1042,1507 -e /abs/path/to/examples lapuza```
     results in `uid=1042` and `gid=1507` inside the running container `lapuza`
     with bind mount that mounts `/abs/path/to/examples` on the host to
     `/home/red/project/examples` in the container. The option `-n` specifies
     the number of cores used when building the base image.

   * Defaults for this script have already nice values:  
   `-n 4`, `-i $(id -u),$(id -g)`, `-e "$PWD/examples"`, container's name - `red`

   * SFU code components should be archived in a zip named `PoreFlow*.zip`
     (without leading directories). Should they be packed in a folder
     that is later zipped, one must use `--strip-sfu-zip` flag to
     convert the archive to the required structure.

   * For the code deploiment with Singularity, it is better to save a light
     version of the docker image <br> with `--save-img-base` that further will
     be converted to a Singularity image.

## Working with Singularity

A similar CLI is achieved for Singularity with `simg.make` wrapper.
The preparation steps repeats the first two stated in the
[Preparation](#preparation) section. Then, in the top-most
directory of the project,

```
singularity build red.simg docker://lukoshkin/red:base
./simg.make setup
```

Note, `./simg.make setup` expects the `examples` folder at the same level as
the archive with SFU code and Singularity image `red.simg`. In order not to
transfer large amounts of data, user can symlink to the directory with
examples. That is, in the project folder,
```
ln -s </path/to/examples> examples
```

The general pipeline of using `simg.make`:

```
./simg.make [-n <nparts>] <example>
./simg.make run [-N <nnodes> -p <queue> --mem=<nG> --time=<days-hours>] <example>
./simg.make vtk <example> [<vtk-range>]
```

The cleaning is done with one of the following commands depending on whether
one wants to delete files generated after runs, after mesh generation, or all.
```
./simg.make clean <example>
./simg.make clean-geom <example>
./simg.make clean-all <example>
```


EX=small
PROJECT=/home/red/project
PARAMDIR=$(PWD)/$(EX)

SMESH=$(PROJECT)/bin/poremesh
SFLOWDIR=$(PROJECT)/src/poreflow/build
SFLOW=$(SFLOWDIR)/sFlow

SVTKDIR=$(PROJECT)/src/sFlowToVTK/build
SVTK=$(SVTKDIR)/sFlowToVTK

GENOUT=$(shell bash gen-names.sh $(EX))
N=$(shell echo $(GENOUT) | cut -d ' ' -f1 )
N_check=$(shell ls $(EX)/geom/*.mesh 2> /dev/null | wc -w)

ifeq ($(N_check),0)
	ifneq ($(shell ls $(EX)/geom/gcube.out 2> /dev/null),)
		N_check = 1
	endif
endif

mesh_parts=$(shell echo $(GENOUT) | cut -d ' ' -f2- )
VTK_RANGE=



all: | $(mesh_parts) $(SFLOW)
	@echo All is up to date.

run: | $(mesh_parts) $(SFLOW)
	@cd $(EX) \
	&& mpirun -n $N $(SFLOW) pore.apr pore.ini

vtk: | $(SVTK)
	@bash prep-vtk.sh $(SVTKDIR) $(EX) $N $(VTK_RANGE)
	@rm -rf $(EX)/VTK
	@cd $(EX) \
	&& $(SVTK) sFlowToVtk.ini


# &: grouped targets (update of multiple targets from one invocation)
# (that is, only one invocation of rules for any number of modified targets)
$(mesh_parts) &: $(PARAMDIR)/param.txt
	@if [ $N != $(N_check) ]; \
	then \
		make clean-geom \
		&& cd $(EX) \
		&& $(SMESH) $(PARAMDIR)/param.txt; \
	fi


$(SFLOW): | $(SFLOWDIR)
$(SVTK): | $(SVTKDIR)

$(SFLOW) $(SVTK):
	@if [ -n $| ]; \
		then rm -rf $|/*; \
	fi \
	&& cd $| \
	&& cmake ../src \
	&& make

$(SFLOWDIR) $(SVTKDIR):
	@mkdir -p $@



.PHONY: clean clean-geom clean-all

# make uses /bin/sh; thus, grouping with curly brackets is
# only available after adding, for example, `SHELL=/usr/bin/bash`.
clean :
	cd $(EX) \
	&& rm -f poreflow*.txt *.bin *.log *.tout \
	*.xml *mon*.dat *out.dat *residuals.dat CELLS.txt*

clean-geom :
	rm $(EX)/geom/*.out -f
	rm $(EX)/geom/*madd -f
	rm $(EX)/geom/*.umesh -f
	rm $(EX)/geom/*mesh -f
	rm $(EX)/geom/*.tmp -f
	rm $(EX)/geom/CELLS.txt* -f
	rm $(EX)/geom/*.log -f

clean-all : clean clean-geom
	rm -rf $(EX)/VTK


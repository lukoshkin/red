EXAMPLE=Horgue2015
PROJECT=PoreFlow
PARAMDIR=$(PWD)/$(EXAMPLE)

SMESH=$(HOME)/$(PROJECT)/bin/poremesh
SFLOWDIR=$(HOME)/$(PROJECT)/src/poreflow/build
SFLOW=$(SFLOWDIR)/sFlow

SVTKDIR=$(HOME)/$(PROJECT)/src/sFlowToVTK/build
SVTK=$(SVTKDIR)/sFlowToVTK

GENOUT=$(shell bash gen-names.sh $(EXAMPLE))
N=$(shell echo $(GENOUT) | cut -d ' ' -f1 )
mesh_parts=$(shell echo $(GENOUT) | cut -d ' ' -f2- )



all: | $(mesh_parts) $(SFLOW)
	@echo "All compiled!"
	@echo -e '\n\n'
	@echo example: $(EXAMPLE)
	@echo path to solver exe: $(SFLOW)

run: | $(mesh_parts) $(SFLOW)
	cd $(EXAMPLE) \
	&& mpirun -n $N $(SFLOW) pore.apr pore.ini

vtk: | $(SVTK)
	bash prep-vtk.sh $(SVTKDIR) $(EXAMPLE) $N
	rm -rf $(EXAMPLE)/VTK
	cd $(EXAMPLE) \
	&& $(SVTK) sFlowToVtk.ini


# &: grouped targets (update of multiple targets from one invocation)
# (that is, only one invocation of rules for any number of modified targets)
$(mesh_parts) &: $(PARAMDIR)/param.txt
	cd $(EXAMPLE) \
	&& $(SMESH) $(PARAMDIR)/param.txt


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
	mkdir -p $@



.PHONY: clean clean-geom clean-all

clean :
	cd $(EXAMPLE) \
	&& rm poreflow*.txt *.bin *.log *.tout *.xml *.dat -f

clean-geom :
	rm $(EXAMPLE)/geom/*.mhd -f
	rm $(EXAMPLE)/geom/*.out -f
	rm $(EXAMPLE)/geom/*madd -f
	rm $(EXAMPLE)/geom/*.umesh -f
	rm $(EXAMPLE)/geom/*mesh -f
	rm $(EXAMPLE)/geom/*.tmp -f
	rm $(EXAMPLE)/geom/CELLS.txt* -f
	rm $(EXAMPLE)/geom/*.log -f

clean-all : clean clean-geom


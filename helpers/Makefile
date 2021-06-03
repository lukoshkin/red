EX=small
PROJECT=project
PARAMDIR=$(PWD)/$(EX)

SMESH=$(HOME)/$(PROJECT)/bin/poremesh
SFLOWDIR=$(HOME)/$(PROJECT)/src/poreflow/build
SFLOW=$(SFLOWDIR)/sFlow

SVTKDIR=$(HOME)/$(PROJECT)/src/sFlowToVTK/build
SVTK=$(SVTKDIR)/sFlowToVTK

GENOUT=$(shell bash gen-names.sh $(EX))
N=$(shell echo $(GENOUT) | cut -d ' ' -f1 )
mesh_parts=$(shell echo $(GENOUT) | cut -d ' ' -f2- )



all: | $(mesh_parts) $(SFLOW)
	@echo "All compiled!"
	@echo -e '\n\n'
	@echo example: $(EX)
	@echo path to solver exe: $(SFLOW)

run: | $(mesh_parts) $(SFLOW)
	@cd $(EX) \
	&& mpirun -n $N $(SFLOW) pore.apr pore.ini

vtk: | $(SVTK)
	@bash prep-vtk.sh $(SVTKDIR) $(EX) $N
	@rm -rf $(EX)/VTK
	@cd $(EX) \
	&& $(SVTK) sFlowToVtk.ini


# &: grouped targets (update of multiple targets from one invocation)
# (that is, only one invocation of rules for any number of modified targets)
$(mesh_parts) &: $(PARAMDIR)/param.txt
	@cd $(EX) \
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
	@mkdir -p $@



.PHONY: clean clean-geom clean-all

clean :
	cd $(EX) \
	&& rm poreflow*.txt *.bin *.log *.tout *.xml *.dat CELLS.txt* -f

clean-geom :
	rm $(EX)/geom/*.mhd -f
	rm $(EX)/geom/*.out -f
	rm $(EX)/geom/*madd -f
	rm $(EX)/geom/*.umesh -f
	rm $(EX)/geom/*mesh -f
	rm $(EX)/geom/*.tmp -f
	rm $(EX)/geom/CELLS.txt* -f
	rm $(EX)/geom/*.log -f

clean-all : clean clean-geom
	rm -rf $(EX)/VTK


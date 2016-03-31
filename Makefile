SHELL = /bin/bash
PY_VER = $(shell python -c 'import sys; print(sys.version_info.major)')
NOTEBOOK_DIR = notebooks
BUILD_DIR = build

NOTEBOOKS = $(wildcard $(NOTEBOOK_DIR)/*.ipynb)
NB_OUTPUTS = $(patsubst $(NOTEBOOK_DIR)/%.ipynb, $(BUILD_DIR)/%.ipynb, $(NOTEBOOKS))
SLIDE_OUTPUTS = $(patsubst %.ipynb, %.slides.html, $(NB_OUTPUTS))
STRIPPED_NB_OUTPUTS = $(patsubst $(BUILD_DIR)/%.ipynb, $(BUILD_DIR)/%_stripped.ipynb, $(NOTEBOOKS))
HTML_OUTPUTS = $(patsubst %.ipynb, %.html, $(NB_OUTPUTS))

$(BUILD_DIR)/%.ipynb: $(NOTEBOOK_DIR)/%.ipynb $(BUILD_DIR)/code $(BUILD_DIR)/data $(BUILD_DIR)/images
	mkdir -p $(BUILD_DIR); 
	cp $< $@;
	jupyter nbconvert --execute --inplace --ExecutePreprocessor.timeout=-1 --to notebook $@;
	jupyter trust $@;

$(BUILD_DIR)/%_stripped.ipynb: $(BUILD_DIR)/%.ipynb
	python strip_skipped_cells.py $< $@;

$(BUILD_DIR)/%.html:$(BUILD_DIR)/%_stripped.ipynb
	jupyter nbconvert --to html --output=`basename $@` $<;
	# it seems to dump in this directory instead of $(BUILD_DIR)
	# mv `basename $@` build;
	# rm $<;

$(BUILD_DIR)/%.slides.html:$(BUILD_DIR)/%.ipynb
	jupyter nbconvert --to slides --reveal-prefix=http://cdn.jsdelivr.net/reveal.js/2.6.2 $<;
	# it seems to dump in this directory instead of $(BUILD_DIR)
	#mv `basename $@` $(BUILD_DIR);


$(BUILD_DIR)/code : $(NOTEBOOK_DIR)/code
	mkdir -p build;
	cp -r $(NOTEBOOK_DIR)/code $(BUILD_DIR)/code;

$(BUILD_DIR)/data : $(NOTEBOOK_DIR)/data
	mkdir -p build;
	cp -r $(NOTEBOOK_DIR)/data $(BUILD_DIR)/data;

$(BUILD_DIR)/images : $(NOTEBOOK_DIR)/images
	mkdir -p build;
	cp -r $(NOTEBOOK_DIR)/images $(BUILD_DIR)/images;

html: $(NB_OUTPUTS) 

	pip install -q -r requirements.docs.txt

slides: $(SLIDE_OUTPUTS)

htmlout: $(HTML_OUTPUTS)

tables : $(NB_OUTPUTS)

	
	python strip_skipped_cells.py $(BUILD_DIR)/Symmetric_normal_table.ipynb $(BUILD_DIR)/Symmetric_normal_table_stripped.ipynb ;
	jupyter nbconvert --to=html $(BUILD_DIR)/Symmetric_normal_table_stripped.ipynb ;
	rm $(BUILD_DIR)/Symmetric_normal_table_stripped.ipynb ;
	# mv Symmetric_normal_table_stripped.html $(BUILD_DIR)/Symmetric_normal_table.html;

	python strip_skipped_cells.py $(BUILD_DIR)/Tail_Chisquared_table.ipynb $(BUILD_DIR)/Tail_Chisquared_table_stripped.ipynb ;
	jupyter nbconvert --to=html $(BUILD_DIR)/Tail_Chisquared_table_stripped.ipynb ;
	rm $(BUILD_DIR)/Tail_Chisquared_table_stripped.ipynb ;
	# mv Tail_Chisquared_table_stripped.html $(BUILD_DIR)/Tail_Chisquared_table.html;

	python strip_skipped_cells.py $(BUILD_DIR)/Tail_T_table.ipynb $(BUILD_DIR)/Tail_T_table_stripped.ipynb ;
	jupyter nbconvert --to=html $(BUILD_DIR)/Tail_T_table_stripped.ipynb ;
	rm $(BUILD_DIR)/Tail_T_table_stripped.ipynb ;
	# mv Tail_T_table_stripped.html $(BUILD_DIR)/Tail_T_table.html;

	python strip_skipped_cells.py $(BUILD_DIR)/Tail_normal_table.ipynb $(BUILD_DIR)/Tail_normal_table_stripped.ipynb ;
	jupyter nbconvert --to=html $(BUILD_DIR)/Tail_normal_table_stripped.ipynb ;
	rm $(BUILD_DIR)/Tail_normal_table_stripped.ipynb ;
	# mv Tail_normal_table_stripped.html $(BUILD_DIR)/Tail_normal_table.html;

$(BUILD_DIR)/index.html : index.md
	
	notedown index.md > index.ipynb;
	jupyter nbconvert --to=rst index.ipynb --output=index;
	rm index.ipynb;
	mv index.rst sphinx;
	sphinx-build -v -E -b html sphinx _build/html ;
	cp -r _build/html/* build;

clean:
	
	rm -fr $(BUILD_DIR);
	rm -fr _build;

all: html htmlout slides tables $(BUILD_DIR)/index.html

	cp -r practice_quizzes $(BUILD_DIR)/practice_quizzes;

jtaylo_deploy: 
	rsync -avz build/* jtaylo@corn.stanford.edu:/afs/ir/class/stats60/WWW

lucy_deploy: 
	rsync -avz build/* lucyxia@corn.stanford.edu:/afs/ir/class/stats60/WWW
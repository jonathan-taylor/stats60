SHELL = /bin/bash
PY_VER = $(shell python -c 'import sys; print(sys.version_info.major)')
EXAMPLE_DIR = .
TABLES_DIR = Tables
BUILD_DIR = build

NOTEBOOKS = $(wildcard $(EXAMPLE_DIR)/*.ipynb)
NB_OUTPUTS = $(patsubst %.ipynb, $(BUILD_DIR)/%.ipynb, $(NOTEBOOKS))
SLIDE_OUTPUTS = $(patsubst %.ipynb, %.slides.html, $(NB_OUTPUTS))
TABLES = $(wildcard $(TABLES_DIR)/*.ipynb)
TABLE_OUTPUTS = $(patsubst %.ipynb, $(BUILD_DIR)/%.ipynb, $(TABLES))

$(BUILD_DIR)/%.ipynb:%.ipynb
	mkdir -p $(BUILD_DIR); 
	mkdir -p $(BUILD_DIR)/Tables; 
	jupyter nbconvert --execute --inplace --output=$@ --ExecutePreprocessor.timeout=-1 $<;
	jupyter trust $<;

$(BUILD_DIR)/%.slides.html:$(BUILD_DIR)/%.ipynb
	jupyter nbconvert --to slides --reveal-prefix=http://cdn.jsdelivr.net/reveal.js/3.2.0 $<;
	# it seems to dump in this directory instead of $(BUILD_DIR)
	mv `basename $@` $(BUILD_DIR);

html: $(NB_OUTPUTS) $(TABLE_OUTPUTS)

	jupyter nbconvert --to=html $(BUILD_DIR)/Tables

	cp -r code $(BUILD_DIR)/code;
	cp -r data $(BUILD_DIR)/data;
	cp -r images $(BUILD_DIR)/images;
	cp -r exercises $(BUILD_DIR)/exercises;

slides: $(SLIDE_OUTPUTS)

$(BUILD_DIR)/$(TABLES_DIR)%.html:$(BUILD_DIR)/$(TABLES_DIR)%.ipynb

	jupyter nbconvert --to html $<;
	mv `basename $@` $(BUILD_DIR)/$(TABLES_DIR);

tables : $(TABLE_OUTPUTS)

	jupyter nbconvert --to=html build/Tables/Symmetric_normal_table.ipynb ;
	mv Symmetric_normal_table.html build/Tables;

	jupyter nbconvert --to=html build/Tables/Tail_Chisquared_table.ipynb ;
	mv Tail_Chisquared_table.html build/Tables;

	jupyter nbconvert --to=html build/Tables/Tail_T_table.ipynb ;
	mv Tail_T_table.html build/Tables;

	jupyter nbconvert --to=html build/Tables/Tail_normal_table.ipynb ;
	mv Tail_normal_table.html build/Tables;

$(BUILD_DIR)/index.html :
	
	mkdir -p sphinx;
	notedown index.md > index.ipynb;
	jupyter nbconvert --to=rst index.ipynb --output=index;
	rm index.ipynb;
	mv index.rst sphinx;
	sphinx-build -E -b html sphinx _build/html ;
	cp -r _build/html/* build;

clean:
	
	rm -fr $(BUILD_DIR);
	rm -fr _build;

all: html slides tables $(BUILD_DIR)/index.html
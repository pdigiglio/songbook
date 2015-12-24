#
# Easy Makefile to compile songbook.lytex
#

.PHONY: lilyclean clean distclean dist help

# ---------------------------------------------------------------------------------------
LaTeX=latexmk
# Check if latexmk is installed
isNotInstalled = $(shell which $(LaTeX) 2> /dev/null; echo $$?)
ifeq ($(isNotInstalled),1)

# If latexmk is not installed
# 1. Print a warning
$(info WARNING >> $(LaTeX) is not installed, using latex)

# 2. Sets compiler to 'latex' and checks if it's installed
LaTeX=latex
isNotInstalled = $(shell which $(LaTeX) 2> /dev/null; echo $$?)
ifeq ($(isNotInstalled),1)

# If neither latex is installed, prints an error and exits
$(error ERROR >> $(LaTeX) is not installed, exiting)

endif
endif
# Check if lilypond-book is installed
lilyPond=lilypond-book
isNotInstalled = $(shell which $(lilyPond) 2> /dev/null; echo $$?)
ifeq ($(isNotInstalled),1)
$(error ERROR >> $(lilyPond) is not installed, exiting)
endif
#----------------------------------------------------------------------------------------


# default format is -pdf
ifndef format
format=pdf
else
# TODO implement a stop
#ifneq($(format),dvi)
#@echo "a"
#endif
endif

OPTIONS=-$(format) -shell-escape

# Track data file in data/ folder
dataFolder = $(wildcard data/*.tab)

outputDirectory=lilyOutput/
MAIN=songbook
$(MAIN): %: %.lytex $(dataFolder) Makefile
	@echo "`tput bold`$(lilyPond)`tput sgr0`"\
		"`tput setaf 1`--output=`tput sgr0`$(outputDirectory)"\
		"`tput setaf 1`--$(format)`tput sgr0`"\
		"`tput setaf 2`$<`tput sgr0`"
	@$(lilyPond) --output=$(outputDirectory) --$(format) $<
	@echo "\n`tput bold`cd`tput sgr0` $(outputDirectory)"
	@echo "`tput bold`$(LaTeX)`tput sgr0`"\
		"`tput setaf 1`$(OPTIONS)`tput sgr0`"\
		"`tput setaf 2`$(MAIN).tex`tput sgr0`"
	@cd $(outputDirectory) &&\
	  $(LaTeX) $(OPTIONS) $(MAIN).tex -f &&\
	  cp $(MAIN).pdf ..

# One can link the file in .. instead of generating it there
#	@echo "\n`tput bold`ln`tput sgr0`"\
		"`tput setaf 1`-sf`tput sgr0`"\
		"$(outputDirectory)$(MAIN).pdf"\
		"`tput setaf 2`$(MAIN).pdf`tput sgr0`"
#	@ln -sf $(outputDirectory)$(MAIN).pdf $(MAIN).pdf

# Clean output lilypond directory
lilyclean:
	@echo "`tput bold`rm`tput sgr0`"\
		"`tput setaf 1`--recursive --force --verbose`tput sgr0`"\
		"`tput setaf 2`$(outputDirectory)`tput sgr0`"
	@rm --recursive --force --verbose $(outputDirectory)

# Clean current directory
clean: lilyclean
	@echo "`tput bold`rm`tput sgr0`"\
		"`tput setaf 1`--recursive --force --verbose`tput sgr0`"\
		"`tput setaf 2`*.toc *.log *.out *.aux *.fls *.fdb_latexmk`tput sgr0`"
	@rm --recursive --force --verbose *.toc *.log *.out *.aux *.fls *.ind *.ilg *.fdb_latexmk

distclean: clean
	@echo "`tput bold`rm`tput sgr0`"\
		"`tput setaf 1`--recursive --force --verbose`tput sgr0`"\
		"`tput setaf 2`*.pdf *.dvi`tput sgr0`"
	@rm --recursive --force --verbose *.pdf *.dvi

thisFolder = $(shell basename $$(pwd))
now        = $(shell date "+%G-%m-%d_at_%H-%M-%S")
dist: $(MAIN) clean
	@cd ..; tar -cvzf $(thisFolder)_of_$(now).tar.gz --exclude-vcs $(thisFolder)/

help:
	@echo "`tput setaf 1`>> Options available`tput sgr0`\n"\
		"`tput bold`make`tput sgr0`           "\
		"Builds `tput setaf 2`\"$(MAIN).lytex\"`tput sgr0` trying to use latexmk (if it's not installed, uses latex). Calls the default `tput bold`$(MAIN)`tput sgr0` rule\n"\
		"`tput bold`make help`tput sgr0`      "\
		"Prints this help\n"\
		"`tput bold`make lilyclean`tput sgr0` "\
		"Removes `tput setaf 2`$(outputDirectory)`tput sgr0`, the output folder for lilypond files\n" \
		"`tput bold`make clean`tput sgr0`     "\
		"Removes `tput setaf 2`*.log *.out *.aux *.fls *.fdb_latexmk`tput sgr0` files\n" \
		"`tput bold`make distclean`tput sgr0` "\
		"Calls `tput bold`clean`tput sgr0` and removes `tput setaf 2`*.pdf *.dvi`tput sgr0` files\n" \
		"`tput bold`make dist`tput sgr0`      "\
		"Calls `tput bold`$(MAIN)`tput sgr0` and `tput bold`clean`tput sgr0` and creates a `tput setaf 2`.tar.gz`tput sgr0` archive of source files in ../\n" \

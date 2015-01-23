#################################################
# 
# Makefile for LaTeX
#
# (c) 2013 Matthias Nott
#
#################################################


#################################################
# 
# Configuration
#
#################################################

TEXBIN=/usr/texbin/
BIBFILE=../../../Papers/Bibliography.bib
FILELOC=~/Library/Application\ Support/DEVONthink\ Pro\ 2/Inbox

#################################################
# 
# End of Configuration
#
#################################################

PATH:=$(TEXBIN):$(PATH)

ifdef loglvl
  LOGLVL=$(loglvl)
endif

ifdef LOGLEVEL
  LOGLVL=$(loglvl)
endif

ifdef loglevel
  LOGLVL=$(loglevel)
endif

ifndef LOGLVL
  LOGLVL=INFO
endif

ifdef lvl
	LVL=$(lvl)
endif

ifndef LVL
	LVL=DEBUG
endif

ifndef DEST
	DEST=tmp
endif


ifeq ($(MAKE),)
    MAKE := make
endif

define uc
$(shell echo $1 | tr a-z A-Z)
endef

PACKAGE    = document
VERSION    = 0.1

.SILENT :

.EXPORT_ALL_VARIABLES :

.NOTPARALLEL :


#################################################
#
# Help function
#
#################################################
.PHONY: help
help :

	echo "=========================================="
	echo "Welcome to this massively informative help"
	echo "=========================================="
	echo 
	echo "You have the following targets:           "
	echo 
	echo "make init       Initialize LaTeX Project. "
	echo "                This deletes all content! "
	echo
	echo "make clean      Remove all LaTeX auxiliary"
	echo "                files and build artefacts."
	echo

	echo
	echo "=========================================="



.PHONY: test
test :
	echo $$PATH



#################################################
#
# Initial Things we mostly always want to do.
#
#################################################

.PHONY: check
check :
	$(MAKE) log msg="make check" LVL=debug
	#
	# Check for maximum level of recursion
	#
	if [ $(MAKELEVEL) -gt 20 ]; then \
		$(MAKE) log lvl=fatal msg="Maximum recursion level reached. Aborting."; \
		exit 1; \
	else \
	  $(MAKE) log lvl=debug msg="Recursion level: $(MAKELEVEL)"; \
	fi;

	#
	# Make sure the directory tmp exists
	#
	mkdir -p tmp;
	
	#
	# Make sure there's a file wc.tex in tmp
	#
	if [ ! -f tmp/wc.tex ]; then touch tmp/wc.tex; fi
	
	#
	# Set flags for runnint tex
	#
	if [ "$$submit" == "true" ] ; then \
		echo "\\providecommand{\\submit}{true}" > tmp/env.tex;\
	else \
		echo "\\providecommand{\\submit}{false}" > tmp/env.tex;\
	fi;


#################################################
# 
# Initialize the Project, remove old Content
#
#################################################

.PHONY: init
init : check clean
	$(MAKE) log msg="make init" LVL=info
	#
	# Ask the user if that's really what he wants
	#
	read -r -p "This will reinitialize and remove all your content. Are you sure? [y/N] " response;\
	if [[ $$response == "" || ! $$response =~ ^([yY][eE][sS]|[yY])$$ ]];  then echo no ; exit 1; fi;

	#
	# Register the project with local git server
	#
	if [ "$$repository" == "" ]; then \
    echo If you want to register the project with a different git server, use: ;\
    echo ;\
    echo make init repository=gitserver:remote_repository_name ;\
    echo ;\
    echo for example: ;\
    echo ;\
    echo make init repository=git:MBA4/MBA4W1DQ1 ;\
    echo ;\
  else \
    git remote rename origin upstream ;\
    git remote add origin $$repository ;\
    git push origin master ;\
    git branch master --set-upstream-to origin/master ;\
  fi;

	#
	# Parse directory name into .project
	#
	PROJ=$$(basename "$$(pwd)"); \
  echo Initializing $$PROJ; \
  perl -pi -e "BEGIN{undef $$/};s#(<projectDescription.*?<name>)(.*?)(</name>)#\1$${PROJ}\3#ms" .project

	#
	# Remove everything between <content> and </content>
	# from each .tex file
	#
	for i in chapter*tex; do perl -pi -e 'BEGIN{undef $$/};s#(.*?%\s*?<content>\s*?%).*?(%\s*?</content>\s*?%.*)#\1\n\n\n\n\2\n\n#ms' $$i; done ;
	
	#
	# Resymlink Bibliography
	#
	rm -f Bibliography.bib ; ln -s $(BIBFILE)



#################################################
# 
# Open PDF
#
#################################################

.PHONY: pdf
pdf : check pdflatex
	$(MAKE) log msg="make pdf" LVL=info
	open document.pdf


#################################################
# 
# Run pdflatex
#
#################################################

.PHONY: pdflatex
pdflatex : check
	$(MAKE) log msg="make pdflatex" LVL=info
	if [ "$$verbose" == "1" ] ; then \
    yes x | pdflatex -shell-escape -enable-write18 -synctex=1 -interaction=batchmode -output-directory=$$DEST document.tex; \
  else \
    yes x | pdflatex -shell-escape -enable-write18 -synctex=1 -interaction=batchmode -output-directory=$$DEST document.tex >/dev/null 2>&1; \
  fi; \
  remake=0; \
  if grep -Fq "No file document.acr" $$DEST/document.log; then $(MAKE) acronyms; remake=1; fi; \
  if grep -Fq "No file document.gls" $$DEST/document.log; then $(MAKE) glossary; remake=1; fi; \
  if grep -Fq "No file document.syi" $$DEST/document.log; then $(MAKE) symbols;  remake=1; fi; \
  if grep -Fq "No file document.ind" $$DEST/document.log; then $(MAKE) index;    remake=1; fi; \
  if grep -Fq "Please (re)run Biber" $$DEST/document.log; then $(MAKE) biber;    remake=1; fi; \
  if grep -Fq "Please rerun LaTeX"   $$DEST/document.log; then remake=1; fi; \
  if [ "$$remake" == "1" ] ; then $(MAKE) pdflatex; fi; \
  $(MAKE) totmp; \
  if [ -f $$DEST/document.pdf ]; then mv $$DEST/document.pdf . >/dev/null 2>&1; fi;\
  if [ -f $$DEST/document.synctex.gz ]; then mv $$DEST/document.synctex.gz . >/dev/null 2>&1; fi;\
  if [ -f $$DEST/document.log ]; then mv $$DEST/document.log . >/dev/null 2>&1; fi;


#################################################
# 
# Run htlatex
#
#################################################

.PHONY: htlatex
htlatex : check
	$(MAKE) log msg="make htlatex" LVL=info
	$(MAKE) fromtmp;
	export DEST=.; \
  if [ "$$verbose" == "1" ] ; then \
    yes x | htlatex document.tex "cfg/myconfig.cfg" "" "" "-interaction=batchmode"; \
  else \
    yes x | htlatex document.tex "cfg/myconfig.cfg" "" "" "-interaction=batchmode" >/dev/null 2>&1; \
  fi; \
  remake=0; \
  $(MAKE) totmp;\
  if grep -Fq "No file document.acr" tmp/document.log; then $(MAKE) acronyms; remake=1; $(MAKE) log msg="Needed to make Acronyms." LVL=info; fi; \
  if grep -Fq "No file document.gls" tmp/document.log; then $(MAKE) glossary; remake=1; $(MAKE) log msg="Needed to make Glossary." LVL=info; fi; \
  if grep -Fq "No file document.syi" tmp/document.log; then $(MAKE) symbols;  remake=1; $(MAKE) log msg="Needed to make Symbols. " LVL=info; fi; \
  if grep -Fq "No file document.ind" tmp/document.log; then $(MAKE) index;    remake=1; $(MAKE) log msg="Needed to make Index.   " LVL=info; fi; \
  if grep -Fq "Please (re)run Biber" tmp/document.log; then $(MAKE) biber;    remake=1; $(MAKE) log msg="Needed to make Biber.   " LVL=info; fi; \
  if grep -Fq "Please rerun LaTeX"   tmp/document.log; then remake=1; fi; \
  if [ "$$remake" == "1" ] ; then $(MAKE) pdflatex; fi; \
  if [ -f tmp/document.pdf ]; then mv tmp/document.pdf . >/dev/null 2>&1; fi;\
  if [ -f tmp/document.synctex.gz ]; then mv tmp/document.synctex.gz . >/dev/null 2>&1; fi;



#################################################
# 
# Run Makeindex
#
#################################################
.PHONY: makeindex
makeindex :
	$(MAKE) log msg="make $$INDEX" LVL=info
	if [ ! -f $$DEST/document.ist ]; then  \
    $(MAKE) pdflatex; \
  fi; \
  if [ -f $$DEST/document.$$INDEXFILE ] ; then \
  	if [ "$$verbose" == "1" ] ; then \
      if [ "$$INDEXFILE" == "idx" ] ; then \
        makeindex $$DEST/document.idx; \
      fi; \
      makeindex -s $$DEST/document.ist -t $$DEST/document.$$LOGFILE -o $$DEST/document.$$OUTFILE $$DEST/document.$$INDEXFILE; \
      if [ "$$INDEXFILE" == "idx" ] ; then \
        makeindex $$DEST/document.idx; \
      fi; \
    else \
      if [ "$$INDEXFILE" == "idx" ] ; then \
        makeindex $$DEST/document.idx >/dev/null 2>&1; \
      fi; \
      makeindex -s $$DEST/document.ist -t $$DEST/document.$$LOGFILE -o $$DEST/document.$$OUTFILE $$DEST/document.$$INDEXFILE >/dev/null 2>&1; \
      if [ "$$INDEXFILE" == "idx" ] ; then \
        makeindex $$DEST/document.idx >/dev/null 2>&1; \
      fi; \
    fi; \
  fi;


#################################################
# 
# Sort Acronyms
#
#################################################

.PHONY: acronyms
acronyms : check 
	$(MAKE) makeindex LOGFILE=alg OUTFILE=acr INDEXFILE=acn INDEX=acronyms


#################################################
# 
# Sort Glossary
#
#################################################

.PHONY: glossary
glossary : check
	$(MAKE) makeindex LOGFILE=glg OUTFILE=gls INDEXFILE=glo INDEX=glossary


#################################################
# 
# Sort Symbols
#
#################################################

.PHONY: symbols
symbols : check 
	$(MAKE) makeindex LOGFILE=slg OUTFILE=syi INDEXFILE=syg INDEX=symbols


#################################################
# 
# Sort Index
#
#################################################

.PHONY: index
index : check
	$(MAKE) makeindex LOGFILE=ilg OUTFILE=ind INDEXFILE=idx INDEX=index


#################################################
# 
# Run Biber
#
#################################################

.PHONY: biber
biber : check
	$(MAKE) log msg="make biber" LVL=info
	if [ "$$DEST" == "" ] ; then export DEST=tmp; fi;
	if [ ! -f $$DEST/document.log ]; then  \
		$(MAKE) $(FORMAT)latex; \
	fi;
	if [ "$$verbose" == "1" ] ; then \
		biber --output_directory=$$DEST document; \
	else \
		biber --output_directory=$$DEST document >/dev/null 2>&1; \
	fi;
	
	#
	# Sometines a document.blg gets generated, so we move it away
	#
	if [ -f document.blg -a "$$DEST" == "tmp" ]; then mv document.blg tmp/ >/dev/null 2>&1; fi; \
	
	#
	# Conditionally remake indices
	#
	if grep -Fq "pdfTeX warning (dest): name{acn:" $$DEST/document.log; then $(MAKE) acronyms; fi;
	if grep -Fq "pdfTeX warning (dest): name{glo:" $$DEST/document.log; then $(MAKE) glossary; fi;
	if grep -Fq "pdfTeX warning (dest): name{syg:" $$DEST/document.log; then $(MAKE) symbols;  fi;
	if grep -Fq "pdfTeX warning (dest): name{idx:" $$DEST/document.log; then $(MAKE) index;    fi;


#################################################
# 
# Count Words
#
#################################################

.PHONY: wc
wc : check
	$(MAKE) log msg="make wc" LVL=info
	if [ -s tmp/wc.tex ] ; then \
		if [ "$$(cat tmp/wc.tex)" != "." ] ; then \
			cat tmp/wc.tex; \
			exit; \
		fi; \
	fi; \
  if [ "$$verbose" == "1" ] ; then \
    $(MAKE) htlatex;\
  else \
    $(MAKE) htlatex >/dev/null 2>&1;\
  fi; \
  $(MAKE) fromtmp;\
  if [ "$$verbose" == "1" ] ; then \
    cat document.html | perl -pi -e 'BEGIN{undef$$/};s%<!-- COUNT -->%##COUNT##%sg'| perl -pi -e 'BEGIN{undef$$/};s%<!-- /COUNT -->%##/COUNT##%sg' | python cfg/html2text.py | perl -0777 -ne 'print "$$1\n" while /##COUNT##(.*?)##\/COUNT##/gs'| perl -pi -e 'BEGIN{undef$$/};s%##COUNT##%%sg' | perl -pi -e 'BEGIN{undef$$/};s%##/COUNT##%%sg' | perl -pi -e "s%#{1,} %%gm"| perl -pi -e "s%\* %%gm" | perl -pi -e "s%\\[\\[.*?\\)%%gm"; \
  fi; \
  cat document.html | perl -pi -e 'BEGIN{undef$$/};s%<!-- COUNT -->%##COUNT##%sg'| perl -pi -e 'BEGIN{undef$$/};s%<!-- /COUNT -->%##/COUNT##%sg' | python cfg/html2text.py | perl -0777 -ne 'print "$$1\n" while /##COUNT##(.*?)##\/COUNT##/gs'| perl -pi -e 'BEGIN{undef$$/};s%##COUNT##%%sg' | perl -pi -e 'BEGIN{undef$$/};s%##/COUNT##%%sg' | perl -pi -e "s%#{1,} %%gm"| perl -pi -e "s%\* %%gm" | perl -pi -e "s%\\[\\[.*?\\)%%gm" > wc.log; \
  cat document.html | perl -pi -e 'BEGIN{undef$$/};s%<!-- COUNT -->%##COUNT##%sg'| perl -pi -e 'BEGIN{undef$$/};s%<!-- /COUNT -->%##/COUNT##%sg' | python cfg/html2text.py | perl -0777 -ne 'print "$$1\n" while /##COUNT##(.*?)##\/COUNT##/gs'| perl -pi -e 'BEGIN{undef$$/};s%##COUNT##%%sg' | perl -pi -e 'BEGIN{undef$$/};s%##/COUNT##%%sg' | perl -pi -e "s%#{1,} %%gm"| perl -pi -e "s%\* %%gm" | perl -pi -e "s%\\[\\[.*?\\)%%gm" | wc -w | sed 's/ //g' | tee wc.tex; \
  $(MAKE) totmp;


#################################################
# 
# Submit
#
#################################################

.PHONY: submit
submit : check wc
	$(MAKE) log msg="make submit" LVL=info
	export DEST=tmp;\
  $(MAKE) fromtmp; \
  $(MAKE) pdflatex submit=true; \
  $(MAKE) pdflatex submit=true; \
  if [ -f tmp/document.pdf -a "$$DEST" == "tmp" ]; then mv tmp/document.pdf .; fi;\
  cp -a document.pdf ~/Desktop >/dev/null 2>&1;\
  open ~/Desktop/document.pdf;\
  export DEST=.;\
  $(MAKE) totmp;\
  $(MAKE) htlatex submit=true; \
  $(MAKE) htlatex submit=true; \
  cat tmp/document.html | perl -pi -e 'BEGIN{undef$$/};s%(.*)(<html.*?<body.*?>)(.*)%$$2<br/><span class="cmr-10">For a well-formatted version, see attached document (link above).</span><br/><br/>$$3%s' > tmp/document_submitted.html;\
  mv tmp/document_submitted.html tmp/document.html;\
  for i in $(*png); do mv $$i tmp/; done; \
  cp -a fig tmp >/dev/null 2>&1;\
  open tmp/document.html;\
  $(MAKE) totmp;


#################################################
# 
# File
#
#################################################

.PHONY: file
file : check
	$(MAKE) log msg="make file" LVL=info
	if test -f document.pdf; then \
    if test -d $(FILELOC); then \
      if test -f .git/config; then \
        cp -a document.pdf $(FILELOC)/$$(cat .git/config | grep git: | sed -e 's/.*\/\(.*\)/\1/g').pdf; \
      fi; \
    fi; \
  else \
    echo "document.pdf not found. make submit first."; \
  fi;




#################################################
# 
# Remove all temporary tex-files
#
#################################################

.PHONY: clean
clean :
	$(MAKE) log lvl=info msg="make clean"
	
	#
	# Remove all files matching pattern in tex-files
	#
	for i in $(tex-files); do \
		for f in `find . -name "$$i"|grep -v .git|grep -v .png`; do \
			rm -f $$f;\
		done;\
	done;
  
  #
  # Remake directory tmp
  #
	mkdir -p tmp;
	
	#
	# Remove everything from tmp;
	#
	if find tmp/ -maxdepth 0 -type f | read; then rm tmp/*; fi;
	
  #
  # Create the file document.ent which seems to be needed.
  #
	touch tmp/document.ent;


.PHONY: fromtmp
fromtmp :
	$(MAKE) log lvl=debug msg="make fromtmp"
	for i in $(tex-files); do \
		for j in $$(find tmp/ -d 1 -type f -iname "$$i"); do \
			if [ -f "$$j" ]; then \
				$(MAKE) Makefile log lvl=debug msg="cp -a $$j ."; \
				cp -a "$$j" . >/dev/null 2>&1;\
			fi;\
		done;\
	done;\


.PHONY: totmp
totmp :
	$(MAKE) log lvl=debug msg="make totmp"
	for i in $(tex-files); do \
		for j in $$(find . -d 1 -type f -iname "$$i"); do \
			if [ -f "$$j" ]; then \
				$(MAKE) log lvl=debug msg="mv $$j tmp/"; \
				mv $$j tmp/ >/dev/null 2>&1;\
			fi;\
		done;\
	done;



tex-files =	\
	*.4ct	\
	*.4nd	\
	*.4tc	\
	*.acn	\
	*.acr	\
	*.alg	\
	*.aux	\
	*.bbl	\
	*.bcf	\
	*.blg	\
	*.css	\
	*.dvi	\
	*.ent	\
	*.glg	\
	*.glo	\
	*.gls	\
	*.htm*	\
	*.idv	\
	*.ilg	\
	*.idx	\
	*.ind	\
	*.ist	\
	*.lbx	\
	*.lg	\
        *.loe   \
	*.lof	\
	*.log   \
	*.lot	\
	*.mw	\
	*.odt	\
	*.out	\
	*.png	\
	*.run*.xml	\
	*.slg	\
	*.syg	\
	*.syi	\
	*.tmp	\
	*.toc	\
	*.xref \
	wc.tex \
	zzdocument.ps
	



#################################################
# 
# Rudimentary logging functionality
#
#################################################

.PHONY: log
log :
	if [ "$$silent" == "1" ] ; then exit 0; fi
	#
	# Log levels are DEBUG, INFO, WARN, ERROR, FATAL 
	#
	case "$(call uc,$(LVL))" in\
		DEBUG|"")\
			case "$(call uc,$(LOGLVL))" in\
				DEBUG)\
					echo $$msg;\
			esac;\
			;;\
		INFO)\
			case "$(call uc,$(LOGLVL))" in\
				DEBUG|INFO)\
					echo $$msg;\
			esac;\
			;;\
		WARN)\
			case "$(call uc,$(LOGLVL))" in\
				DEBUG|INFO|WARN)\
					echo $$msg;\
			esac;\
			;;\
		ERROR)\
			case "$(call uc,$(LOGLVL))" in\
				DEBUG|INFO|WARN|ERROR)\
					echo $$msg;\
			esac;\
			;;\
		FATAL)\
			case "$(call uc,$(LOGLVL))" in\
				DEBUG|INFO|WARN|ERROR|FATAL)\
					echo $$msg;\
			esac;\
			;;\
  esac;\

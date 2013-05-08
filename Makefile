#################################################
# 
# Makefile for LaTeX
#
# (c) 2013 Matthias Nott
#
#################################################

PACKAGE    = document
VERSION    = 0.1

.SILENT :

.EXPORT_ALL_VARIABLES :

.NOTPARALLEL :

.PHONY: check
check :
	if [ $(MAKELEVEL) -gt 20 ]; then \
	  echo "Maximum recursion level reached. Aborting."; \
	  exit 1; \
	fi;\
  mkdir -p tmp; 

all : clean submit

#################################################
# 
# Configuration
#
#################################################

TEXBIN=/usr/texbin/

#################################################
# 
# Initialize the Project, Remove old Content
#
#################################################

.PHONY: init
init :  check clean
	PROJ=$$(basename "$$(pwd)"); \
  echo Initializing $$PROJ; \
  perl -pi -e "BEGIN{undef $$/};s#(<projectDescription.*?<name>)(.*?)(</name>)#\1$${PROJ}\3#ms" .project; \
	for i in chapter*tex; do perl -pi -e 'BEGIN{undef $$/};s#(.*?%\s*?<content>\s*?%).*?(%\s*?</content>\s*?%.*)#\1\n\n\n\n\2\n\n#ms' $$i; done ; \
  rm Bibliography.bib ; ln -s ../../../../Papers/Bibliography.bib



#################################################
# 
# Open PDF
#
#################################################

.PHONY: pdf
pdf : check pdflatex
	echo make pdf; \
  echo $$(pwd); \
  open document.pdf


#################################################
# 
# Run pdflatex
#
#################################################

.PHONY: pdflatex
pdflatex : check
	echo make pdflatex; \
  export PATH=$$TEXBIN:$$PATH; \
	export FORMAT=pdf; \
	export DEST=tmp; \
  if [ "$$verbose" == "1" ] ; then \
    yes x | pdflatex -interaction=nonstopmode -output-directory=$$DEST document; \
  else \
    yes x | pdflatex -interaction=nonstopmode -output-directory=$$DEST document.tex >/dev/null 2>&1; \
  fi; \
  remake=0; \
  if grep -Fq "No file document.acr" $$DEST/document.log; then $(MAKE) acronyms; remake=1; fi; \
  if grep -Fq "No file document.gls" $$DEST/document.log; then $(MAKE) glossary; remake=1; fi; \
  if grep -Fq "No file document.syi" $$DEST/document.log; then $(MAKE) symbols;  remake=1; fi; \
  if grep -Fq "No file document.ind" $$DEST/document.log; then $(MAKE) index;    remake=1; fi; \
  if grep -Fq "Please (re)run Biber" $$DEST/document.log; then $(MAKE) biber;    remake=1; fi; \
  if grep -Fq "Please rerun LaTeX"   $$DEST/document.log; then remake=1; fi; \
  if [ "$$remake" == "1" ] ; then $(MAKE) pdflatex; fi; \
  if [ -f tmp/document.pdf ]; then mv tmp/document.pdf .; fi;


#################################################
# 
# Run htlatex
#
#################################################

.PHONY: htlatex
htlatex : check
	echo make htlatex; \
	export FORMAT=ht; \
  for i in $(tex-files); do if [ -f "tmp/$$i" ]; then cp -a tmp/$$i . >/dev/null 2>&1; fi; done; \
	export DEST=.; \
  if [ "$$verbose" == "1" ] ; then \
    yes x | htlatex document.tex "cfg/myconfig.cfg"; \
  else \
    yes x | htlatex document.tex "cfg/myconfig.cfg" >/dev/null 2>&1; \
  fi; \
  if grep -Fq "No file document.acr" $$DEST/document.log; then $(MAKE) acronyms; remake=1; fi; \
  if grep -Fq "No file document.gls" $$DEST/document.log; then $(MAKE) glossary; remake=1; fi; \
  if grep -Fq "No file document.syi" $$DEST/document.log; then $(MAKE) symbols;  remake=1; fi; \
  if grep -Fq "No file document.ind" $$DEST/document.log; then $(MAKE) index;    remake=1; fi; \
  if grep -Fq "Please (re)run Biber" $$DEST/document.log; then $(MAKE) biber;    remake=1; fi; \
  if grep -Fq "Please rerun LaTeX"   $$DEST/document.log; then remake=1; fi; \
  if [ "$$remake" == "1" ]; then \
    $(MAKE) htlatex; \
  else \
    for i in $(tex-files); do if [ -f "$$i" ]; then mv $$i tmp/; fi; done; \
  fi;


#################################################
# 
# Sort Acronyms
#
#################################################

.PHONY: acronyms
acronyms : check 
	echo make acronyms; \
	if [ "$$DEST" == "" ] ; then export DEST=tmp; fi; \
  if [ ! -f $$DEST/document.ist ]; then  \
    $(MAKE) $(FORMAT)latex; \
  fi; \
	if [ "$$verbose" == "1" ] ; then \
    makeindex -s $$DEST/document.ist -t $$DEST/document.alg -o $$DEST/document.acr $$DEST/document.acn; \
  else \
    makeindex -s $$DEST/document.ist -t $$DEST/document.alg -o $$DEST/document.acr $$DEST/document.acn >/dev/null 2>&1; \
  fi;

#################################################
# 
# Sort Glossary
#
#################################################

.PHONY: glossary
glossary : check
	echo make glossary; \
	if [ "$$DEST" == "" ] ; then export DEST=tmp; fi; \
  if [ ! -f $$DEST/document.ist ]; then  \
    $(MAKE) $(FORMAT)latex; \
  fi; \
	if [ "$$verbose" == "1" ] ; then \
    makeindex -s $$DEST/document.ist -t $$DEST/document.glg -o $$DEST/document.gls $$DEST/document.glo; \
  else \
    makeindex -s $$DEST/document.ist -t $$DEST/document.glg -o $$DEST/document.gls $$DEST/document.glo >/dev/null 2>&1; \
  fi;


#################################################
# 
# Sort Symbols
#
#################################################

.PHONY: symbols
symbols : check 
	echo make symbols; \
	if [ "$$DEST" == "" ] ; then export DEST=tmp; fi; \
  if [ ! -f $$DEST/document.ist ]; then  \
    $(MAKE) $(FORMAT)latex; \
  fi; \
	if [ "$$verbose" == "1" ] ; then \
    makeindex -s $$DEST/document.ist -t $$DEST/document.slg -o $$DEST/document.syi $$DEST/document.syg; \
  else \
    makeindex -s $$DEST/document.ist -t $$DEST/document.slg -o $$DEST/document.syi $$DEST/document.syg >/dev/null 2>&1; \
  fi;


#################################################
# 
# Sort Index
#
#################################################

.PHONY: index
index : check
	echo make index; \
	if [ "$$DEST" == "" ] ; then export DEST=tmp; fi; \
  if [ ! -f $$DEST/document.ist ]; then  \
    $(MAKE) $(FORMAT)latex; \
  fi; \
	if [ "$$verbose" == "1" ] ; then \
    makeindex -s $$DEST/document.ist -t $$DEST/document.ilg -o $$DEST/document.ind $$DEST/document.idx; \
  else \
    makeindex -s $$DEST/document.ist -t $$DEST/document.ilg -o $$DEST/document.ind $$DEST/document.idx >/dev/null 2>&1; \
  fi;


#################################################
# 
# Run Biber
#
#################################################

.PHONY: biber
biber : check
	echo make biber; \
	if [ "$$DEST" == "" ] ; then export DEST=tmp; fi; \
  if [ ! -f $$DEST/document.log ]; then  \
    $(MAKE) $(FORMAT)latex; \
  fi; \
	if [ "$$verbose" == "1" ] ; then \
    biber --output_directory=$$DEST document; \
  else \
    biber --output_directory=$$DEST document >/dev/null 2>&1; \
  fi; \
  if [ -f document.blg ]; then mv document.blg tmp/; fi; \
  if grep -Fq "pdfTeX warning (dest): name{acn:" $$DEST/document.log; then $(MAKE) acronyms; fi; \
  if grep -Fq "pdfTeX warning (dest): name{glo:" $$DEST/document.log; then $(MAKE) glossary; fi; \
  if grep -Fq "pdfTeX warning (dest): name{syg:" $$DEST/document.log; then $(MAKE) symbols;  fi; \
  if grep -Fq "pdfTeX warning (dest): name{idx:" $$DEST/document.log; then $(MAKE) index;    fi;
  

#################################################
# 
# Count Words
#
#################################################

.PHONY: wc
wc : check
	echo make wc; \
	if [ "$$DEST" == "" ] ; then export DEST=tmp; fi; \
  if [ -d sav ]; then\
    echo Directory sav exists - exiting.;\
    exit 1;\
  fi;\
  \
  mkdir sav;\
  cp -av *tex sav >/dev/null 2>&1;\
  \
  cat chapter_00.tex | perl -pi -e 'BEGIN{undef$$/};s%(.*)(\\section\*\{Discussion Question\}.*?\\section\*\{Discussion Question Answer\})(.*)%$$1$$3%s' > chapter_00.new;\
  mv chapter_00.new chapter_00.tex;\
  \
  cat chapter_00.tex | perl -pi -e 'BEGIN{undef$$/};s%(.*)(\\section\*\{Assignment\}.*?\\section\*\{Assignment Answer\})(.*)%$$1$$3%s' > chapter_00.new;\
  mv chapter_00.new chapter_00.tex;\
  \
  $(MAKE) pdflatex; \
  for i in chapter*tex; do perl -pi -e 'BEGIN{undef$$/};s#\\vref#\\ref#gs' $$i; done ;\
  for i in chapter*tex; do perl -pi -e 'BEGIN{undef$$/};s#(\\caption.*?)}.*?(\\caption\*{)(.*?})}#$$1 ($$3)}#msg' $$i; done ;\
  $(MAKE) htlatex; \
  cat $$DEST/document.html | perl -pi -e 's/\\relax//g' > document2.html; \
  mv document2.html document.html; \
  if [ "$$verbose" == "1" ] ; then \
    python /pgm/scripts/html2text.py document.html "iso-8859-1" | perl -pi -e 'BEGIN{undef$$/};s%(.*?)(###.*?1 )(.*?)([0-9]*? Words excluding .*)%$$2$$3%s' | perl -pi -e "s%#{3,} %%gm" | perl -pi -e "s%\* %%gm"; \
  fi; \
  python /pgm/scripts/html2text.py document.html "iso-8859-1" | perl -pi -e 'BEGIN{undef$$/};s%(.*?)(###.*?1 )(.*?)([0-9]*? Words excluding .*)%$$2$$3%s' | perl -pi -e "s%#{3,} %%gm" | perl -pi -e "s%\* %%gm" | wc -w; \
  cp -a sav/* . >/dev/null 2>&1;\
  rm -rf sav >/dev/null 2>&1; \
  for i in $(tex-files); do if [ -f "$$i" ]; then mv $$i tmp/; fi; done; \



#################################################
# 
# Submit
#
#################################################

.PHONY: submit
submit : check
	echo make submit; \
  if [ -d sav ]; then\
    echo Directory sav exists - exiting.;\
    exit 1;\
  fi;\
  \
  mkdir sav;\
  cp -av *tex sav >/dev/null 2>&1;\
  \
  cat chapter_00.tex | perl -pi -e 'BEGIN{undef$$/};s%(.*)(\\section\*\{Discussion Question\}.*?\\section\*\{Discussion Question Answer\})(.*)%$$1$$3%s' > chapter_00.new;\
  mv chapter_00.new chapter_00.tex;\
  \
  cat chapter_00.tex | perl -pi -e 'BEGIN{undef$$/};s%(.*)(\\section\*\{Assignment\}.*?\\section\*\{Assignment Answer\})(.*)%$$1$$3%s' > chapter_00.new;\
  mv chapter_00.new chapter_00.tex;\
  \
  $(MAKE) pdflatex; \
  mv tmp/document.pdf .; \
  cp -a document.pdf ~/Desktop >/dev/null 2>&1;\
  open ~/Desktop/document.pdf;\
  for i in chapter*tex; do perl -pi -e 'BEGIN{undef$$/};s#\\vref#\\ref#gs' $$i; done ;\
  for i in chapter*tex; do perl -pi -e 'BEGIN{undef$$/};s#(\\caption.*?)}.*?(\\caption\*{)(.*?})}#$$1 ($$3)}#msg' $$i; done ;\
  $(MAKE) htlatex; \
  cat tmp/document.html | perl -pi -e 'BEGIN{undef$$/};s%(.*)(<html.*?<body.*?>)(.*)%$$2<br/><span class="cmr-10">For a well-formatted version, see attached document (link above).</span><br/><br/>$$3%s' > tmp/document_submitted.html;\
  mv tmp/document_submitted.html tmp/document.html;\
  cp -a fig tmp >/dev/null 2>&1;\
  open tmp/document.html;\
  cp -a sav/* . >/dev/null 2>&1;\
  rm -rf sav >/dev/null 2>&1;



#################################################
# 
# Remove all temporary tex-files
#
#################################################

.PHONY: clean
clean :
	echo make clean; \
  for i in $(tex-files); do \
    for f in `find . -name "$$i"|grep -v .git`; do \
      rm -f $$f;\
    done;\
  done; \
  mkdir -p tmp; \
  if find tmp/ -maxdepth 0 -type f | read; then rm tmp/*; fi; \
  touch tmp/document.ent;

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
	*.lof	\
	*.log	\
	*.lot	\
	*.odt	\
	*.out	\
	*.run*.xml	\
	*.slg	\
	*.syg	\
	*.syi	\
	*.synctex.gz	\
	*.tmp	\
	*.toc	\
	*.xref \
	zzdocument.ps
	

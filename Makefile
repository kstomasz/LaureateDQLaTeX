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
	if [ "$$silent" != "1" ] ; then \
    echo make pdf; \
  fi; \
  open document.pdf


#################################################
# 
# Run pdflatex
#
#################################################

.PHONY: pdflatex
pdflatex : check
	if [ "$$silent" != "1" ] ; then \
    echo make pdflatex; \
  fi; \
  export PATH=$$TEXBIN:$$PATH; \
	export FORMAT=pdf; \
	export DEST=tmp; \
  if [ "$$verbose" == "1" ] ; then \
    yes x | pdflatex -shell-escape -enable-write18 -synctex=1 -interaction=nonstopmode -output-directory=$$DEST document; \
  else \
    yes x | pdflatex -shell-escape -enable-write18 -synctex=1 -interaction=nonstopmode -output-directory=$$DEST document.tex >/dev/null 2>&1; \
  fi; \
  remake=0; \
  if grep -Fq "No file document.acr" $$DEST/document.log; then $(MAKE) acronyms; remake=1; fi; \
  if grep -Fq "No file document.gls" $$DEST/document.log; then $(MAKE) glossary; remake=1; fi; \
  if grep -Fq "No file document.syi" $$DEST/document.log; then $(MAKE) symbols;  remake=1; fi; \
  if grep -Fq "No file document.ind" $$DEST/document.log; then $(MAKE) index;    remake=1; fi; \
  if grep -Fq "Please (re)run Biber" $$DEST/document.log; then $(MAKE) biber;    remake=1; fi; \
  if grep -Fq "Please rerun LaTeX"   $$DEST/document.log; then remake=1; fi; \
  if [ "$$remake" == "1" ] ; then $(MAKE) pdflatex; fi; \
  if [ -f document.blg ]; then mv document.blg $$DEST/; fi; \
  if [ -f $$DEST/document.pdf ]; then mv $$DEST/document.pdf .; fi;\
  if [ -f $$DEST/document.synctex.gz ]; then mv $$DEST/document.synctex.gz .; fi;


#################################################
# 
# Run htlatex
#
#################################################

.PHONY: htlatex
htlatex : check
	if [ "$$silent" != "1" ] ; then \
    echo make htlatex; \
  fi; \
	export FORMAT=ht; \
  for i in $(tex-files); do if [ -f "tmp/$$i" ]; then cp -a tmp/$$i . >/dev/null 2>&1; fi; done; \
	export DEST=tmp; \
  if [ "$$verbose" == "1" ] ; then \
    yes x | htlatex document.tex "cfg/myconfig.cfg"; \
  else \
    yes x | htlatex document.tex "cfg/myconfig.cfg" >/dev/null 2>&1; \
  fi; \
  if [ "$$verbose" == "1" ] ; then \
    yes x | latex '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode 'cfg/myconfig.cfg'.a.b.c.\input ' document.tex  -output-directory=$$DEST ; \
    tex4ht -f/document.tex  -i~/tex4ht.dir/texmf/tex4ht/ht-fonts/ ;\
    t4ht -f/document.tex document -dtmp/ -m644 ;\
  else \
    yes x | latex '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode 'cfg/myconfig.cfg'.a.b.c.\input ' document.tex  -output-directory=$$DEST  >/dev/null 2>&1 ; \
    tex4ht -f/document.tex  -i~/tex4ht.dir/texmf/tex4ht/ht-fonts/  >/dev/null 2>&1 ;\
    t4ht -f/document.tex document -dtmp/ -m644 >/dev/null 2>&1  ;\
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
	if [ "$$silent" != "1" ] ; then \
    echo make acronyms; \
  fi; \
  if [ "$$DEST"   == "" ] ; then export DEST=tmp; fi; \
  if [ "$$FORMAT" == "" ] ; then export FORMAT=pdf; fi; \
  if [ ! -f $$DEST/document.ist ]; then  \
    $(MAKE) $${FORMAT}latex; \
  fi; \
  if [ -f $$DEST/document.acn ] ; then \
  	if [ "$$verbose" == "1" ] ; then \
      makeindex -s $$DEST/document.ist -t $$DEST/document.alg -o $$DEST/document.acr $$DEST/document.acn; \
    else \
      makeindex -s $$DEST/document.ist -t $$DEST/document.alg -o $$DEST/document.acr $$DEST/document.acn >/dev/null 2>&1; \
    fi; \
  fi;

#################################################
# 
# Sort Glossary
#
#################################################

.PHONY: glossary
glossary : check
	if [ "$$silent" != "1" ] ; then \
    echo make glossary; \
  fi; \
  if [ "$$DEST"   == "" ] ; then export DEST=tmp; fi; \
  if [ "$$FORMAT" == "" ] ; then export FORMAT=pdf; fi; \
  if [ ! -f $$DEST/document.ist ]; then  \
    $(MAKE) $${FORMAT}latex; \
  fi; \
  if [ -f $$DEST/document.glo ] ; then \
  	if [ "$$verbose" == "1" ] ; then \
      makeindex -s $$DEST/document.ist -t $$DEST/document.glg -o $$DEST/document.gls $$DEST/document.glo; \
    else \
      makeindex -s $$DEST/document.ist -t $$DEST/document.glg -o $$DEST/document.gls $$DEST/document.glo >/dev/null 2>&1; \
    fi; \
  fi;


#################################################
# 
# Sort Symbols
#
#################################################

.PHONY: symbols
symbols : check 
	if [ "$$silent" != "1" ] ; then \
    echo make symbols; \
  fi; \
	if [ "$$DEST"   == "" ] ; then export DEST=tmp; fi; \
  if [ "$$FORMAT" == "" ] ; then export FORMAT=pdf; fi; \
  if [ ! -f $$DEST/document.ist ]; then  \
    $(MAKE) $${FORMAT}latex; \
  fi; \
  if [ -f $$DEST/document.syg ] ; then \
	  if [ "$$verbose" == "1" ] ; then \
      makeindex -s $$DEST/document.ist -t $$DEST/document.slg -o $$DEST/document.syi $$DEST/document.syg; \
    else \
      makeindex -s $$DEST/document.ist -t $$DEST/document.slg -o $$DEST/document.syi $$DEST/document.syg >/dev/null 2>&1; \
    fi; \
  fi;


#################################################
# 
# Sort Index
#
#################################################

.PHONY: index
index : check
	if [ "$$silent" != "1" ] ; then \
    echo make index; \
  fi; \
	if [ "$$DEST"   == "" ] ; then export DEST=tmp; fi; \
  if [ "$$FORMAT" == "" ] ; then export FORMAT=pdf; fi; \
  if [ ! -f $$DEST/document.ist ]; then  \
    $(MAKE) $${FORMAT}latex; \
  fi; \
  if [ -f $$DEST/document.idx ] ; then \
	  if [ "$$verbose" == "1" ] ; then \
      makeindex -s $$DEST/document.ist -t $$DEST/document.ilg -o $$DEST/document.ind $$DEST/document.idx; \
    else \
      makeindex -s $$DEST/document.ist -t $$DEST/document.ilg -o $$DEST/document.ind $$DEST/document.idx >/dev/null 2>&1; \
    fi; \
  fi;


#################################################
# 
# Run Biber
#
#################################################

.PHONY: biber
biber : check
	if [ "$$silent" != "1" ] ; then \
    echo make biber; \
  fi; \
	if [ "$$DEST" == "" ] ; then export DEST=tmp; fi; \
  if [ ! -f $$DEST/document.log ]; then  \
    $(MAKE) $(FORMAT)latex; \
  fi;
	if [ "$$verbose" == "1" ] ; then \
    biber --output_directory=$$DEST document; \
  else \
    biber --output_directory=$$DEST document >/dev/null 2>&1; \
  fi; 
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
	if [ "$$silent" != "1" ] ; then \
    echo make wc; \
  fi; \
  if [ -f tmp/wc.tex ] ; then if [ -s tmp/wc.tex ] ; then if [ "$$(cat tmp/wc.tex)" != "." ] ; then cat tmp/wc.tex; exit ; fi ; fi ; fi; \
	if [ "$$DEST" == "" ] ; then export DEST=tmp; fi; \
  if [ -d sav ]; then\
    if [ "$$silent" == "1" ] ; then echo "."; else echo "Directory sav exists; exiting."; fi;\
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
  if [ "$$fromtex" != "1" ] ; then \
    $(MAKE) pdflatex; \
  fi;\
  for i in chapter*tex; do perl -pi -e 'BEGIN{undef$$/};s#\\vref#\\ref#gs' $$i; done ;\
  for i in chapter*tex; do perl -pi -e 'BEGIN{undef$$/};s#(\\caption.*?)}.*?(\\caption\*{)(.*?})}#$$1 ($$3)}#msg' $$i; done ;\
  if [ "$$verbose" == "1" ] ; then \
    yes x | latex '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode 'cfg/myconfig.cfg'.a.b.c.\input ' document.tex  -output-directory=$$DEST ; \
    tex4ht -f/document.tex  -i~/tex4ht.dir/texmf/tex4ht/ht-fonts/ ;\
    t4ht -f/document.tex document -dtmp/ -m644 ;\
  else \
    yes x | latex '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode 'cfg/myconfig.cfg'.a.b.c.\input ' document.tex  -output-directory=$$DEST  >/dev/null 2>&1 ; \
    tex4ht -f/document.tex  -i~/tex4ht.dir/texmf/tex4ht/ht-fonts/  >/dev/null 2>&1 ;\
    t4ht -f/document.tex document -dtmp/ -m644 >/dev/null 2>&1  ;\
  fi; \
  cat $$DEST/document.html | perl -pi -e 's/\\relax//g' > document2.html; \
  mv document2.html document.html; \
  if [ "$$verbose" == "1" ] ; then \
    python cfg/html2text.py document.html "iso-8859-1" | perl -pi -e 'BEGIN{undef$$/};s%(.*?)(###.*?1 )(.*?)(Words excluding .*)%$$2$$3%s' | perl -pi -e "s%#{3,} %%gm" | perl -pi -e "s%\* %%gm"; \
  fi; \
  python cfg/html2text.py document.html "iso-8859-1" | perl -pi -e 'BEGIN{undef$$/};s%(.*?)(###.*?1 )(.*?)(Words excluding .*)%$$2$$3%s' | perl -pi -e "s%#{3,} %%gm" | perl -pi -e "s%\* %%gm" > tmp/wc.log; \
  python cfg/html2text.py document.html "iso-8859-1" | perl -pi -e 'BEGIN{undef$$/};s%(.*?)(###.*?1 )(.*?)(Words excluding .*)%$$2$$3%s' | perl -pi -e "s%#{3,} %%gm" | perl -pi -e "s%\* %%gm" | wc -w | sed 's/ //g'; \
  cp -a sav/* . >/dev/null 2>&1;\
  rm -rf sav >/dev/null 2>&1; \
  for i in $(tex-files); do if [ -f "$$i" ]; then mv $$i tmp/; fi; done; \
  if [ "$$fromtex" == "1" ] ; then \
    rm -f tmp/document.ist tmp/document.glg tmp/document.gls tmp/document.glo;\
  fi;\


#################################################
# 
# Submit
#
#################################################

.PHONY: submit
submit : check
	if [ "$$silent" != "1" ] ; then \
    echo make submit; \
  fi; \
  if [ -d sav_submit ]; then\
    echo Directory sav_submit exists - exiting.;\
    exit 1;\
  fi;\
  \
  mkdir sav_submit;\
  cp -av *tex sav_submit >/dev/null 2>&1;\
  \
  cat chapter_00.tex | perl -pi -e 'BEGIN{undef$$/};s%(.*)(\\section\*\{Discussion Question\}.*?\\section\*\{Discussion Question Answer\})(.*)%$$1$$3%s' > chapter_00.new;\
  mv chapter_00.new chapter_00.tex;\
  \
  cat chapter_00.tex | perl -pi -e 'BEGIN{undef$$/};s%(.*)(\\section\*\{Assignment\}.*?\\section\*\{Assignment Answer\})(.*)%$$1$$3%s' > chapter_00.new;\
  mv chapter_00.new chapter_00.tex;\
  \
  $(MAKE) pdflatex; \
  if [ -f tmp/document.pdf ]; then mv tmp/document.pdf .; fi;\
  cp -a document.pdf ~/Desktop >/dev/null 2>&1;\
  open ~/Desktop/document.pdf;\
  for i in chapter*tex; do perl -pi -e 'BEGIN{undef$$/};s#\\vref#\\ref#gs' $$i; done ;\
  for i in chapter*tex; do perl -pi -e 'BEGIN{undef$$/};s#(\\caption.*?)}.*?(\\caption\*{)(.*?})}#$$1 ($$3)}#msg' $$i; done ;\
  if [ "$$verbose" == "1" ] ; then \
    yes x | latex '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode 'cfg/myconfig.cfg'.a.b.c.\input ' document.tex  -output-directory=$$DEST ; \
    tex4ht -f/document.tex  -i~/tex4ht.dir/texmf/tex4ht/ht-fonts/ ;\
    t4ht -f/document.tex document -dtmp/ -m644 ;\
  else \
    yes x | latex '\makeatletter\def\HCode{\futurelet\HCode\HChar}\def\HChar{\ifx"\HCode\def\HCode"##1"{\Link##1}\expandafter\HCode\else\expandafter\Link\fi}\def\Link#1.a.b.c.{\g@addto@macro\@documentclasshook{\RequirePackage[#1,html]{tex4ht}}\let\HCode\documentstyle\def\documentstyle{\let\documentstyle\HCode\expandafter\def\csname tex4ht\endcsname{#1,html}\def\HCode####1{\documentstyle[tex4ht,}\@ifnextchar[{\HCode}{\documentstyle[tex4ht]}}}\makeatother\HCode 'cfg/myconfig.cfg'.a.b.c.\input ' document.tex  -output-directory=$$DEST  >/dev/null 2>&1 ; \
    tex4ht -f/document.tex  -i~/tex4ht.dir/texmf/tex4ht/ht-fonts/  >/dev/null 2>&1 ;\
    t4ht -f/document.tex document -dtmp/ -m644 >/dev/null 2>&1  ;\
  fi; \
  cat tmp/document.html | perl -pi -e 'BEGIN{undef$$/};s%(.*)(<html.*?<body.*?>)(.*)%$$2<br/><span class="cmr-10">For a well-formatted version, see attached document (link above).</span><br/><br/>$$3%s' > tmp/document_submitted.html;\
  mv tmp/document_submitted.html tmp/document.html;\
  cp -a fig tmp >/dev/null 2>&1;\
  open tmp/document.html;\
  cp -a sav_submit/* . >/dev/null 2>&1;\
  rm -rf sav_submit >/dev/null 2>&1; \
  for i in $(tex-files); do if [ -f "$$i" ]; then mv $$i tmp/; fi; done; \



#################################################
# 
# Remove all temporary tex-files
#
#################################################

.PHONY: clean
clean :
	if [ "$$silent" != "1" ] ; then \
    echo make clean; \
  fi; \
  if [ -f tmp/wc.tex ] ; then rm tmp/wc.tex; fi; \
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
	*.tmp	\
	*.toc	\
	*.xref \
	zzdocument.ps
	

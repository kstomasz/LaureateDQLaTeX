#!/bin/bash
sudo chown -R mnott.mnott *
#makeindex document.nlo -s sty/nomencl/nomencl.ist -o document.nls
#makeindex -s document.ist -t document.glg -o document.gls document.glo
perl sty/glossary/makeglos.pl document
#latex document.tex
#latex document.tex
/usr/bin/pdflatex -interaction=scrollmode --src-specials document.tex
/usr/bin/pdflatex -interaction=scrollmode --src-specials document.tex

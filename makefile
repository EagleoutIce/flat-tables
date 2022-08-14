.PHONY: all documentation dtx ctan


all: ctan

dtx: flat-tables.tex flat-tables.sty
	makedtx -src "(.*)\.sty=>\1.sty" -doc flat-tables.tex -license gpl -author "Florian Sihler" flat-tables

ctan: dtx
	l3build ctan
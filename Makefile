# You want latexmk to *always* run, because make does not have all the info.
# Also, include non-file targets in .PHONY so they are run regardless of any
# file of the given name existing.
.PHONY: latex/ugent2016-nl.pdf latex/ugent2016-en.pdf all

# The first rule in a Makefile is the one executed by default ("make"). It
# should always be the "all" rule, so that "make" and "make all" are identical.
all: $(pdf_assets) latex/ugent2016-nl.pdf latex/ugent2016-en.pdf

# CUSTOM BUILD RULES

# In case you didn't know, '$@' is a variable holding the name of the target,
# and '$<' is a variable holding the (first) dependency of a rule.
# "raw2tex" and "dat2tex" are just placeholders for whatever custom steps
# you might have.


#%.tex: %.raw
#        ./raw2tex $< > $@
#
#%.tex: %.dat
#        ./dat2tex $< > $@

# MAIN LATEXMK RULE

# -pdf tells latexmk to generate PDF directly (instead of DVI).
# -pdflatex="" tells latexmk to call a specific backend with specific options.
# -use-make tells latexmk to call make for generating missing files.

# -interaction=nonstopmode keeps the pdflatex backend from stopping at a
# missing file reference and interactively asking you for an alternative.

pdf_assets := $(patsubst assets/%,latex/logos/%,$(patsubst %.eps,%.pdf,$(wildcard assets/*.eps)))

latex/ugent2016-nl.pdf: latex/ugent2016-nl.tex \
						latex/ugent2016-title-report.pdf \
						latex/ugent2016-title-course.pdf \
						latex/ugent2016-title-notes.pdf \
						all_pdf_assets
	latexmk -cd -lualatex -interaction=nonstopmode -shell-escape -use-make $<

latex/ugent2016-en.pdf: latex/ugent2016-en.tex \
						latex/ugent2016-title-report.pdf \
						latex/ugent2016-title-course.pdf \
						latex/ugent2016-title-notes.pdf \
						all_pdf_assets
	latexmk -cd -lualatex -interaction=nonstopmode -shell-escape -use-make $<

# Run from within the latex directory
latex/ugent2016-title-%.pdf: latex/ugent2016-title-%.tex
	latexmk -cd -lualatex -interaction=nonstopmode -use-make $<

# Create the example file
example.pdf: example.tex
	latexmk -cd lualatex -interaction=nontopmode -use-make $<

# Create all assets
all_pdf_assets: $(pdf_assets) latex/logos/ugent2016-logo-global-nl.pdf latex/logos/ugent2016-logo-kortrijk-en.pdf

# These two are created using symlinks rather than links.
latex/logos/ugent2016-logo-global-nl.pdf: latex/logos/ugent2016-logo-global-en.pdf
	powershell New-Item -Force -ItemType SymbolicLink -Name $@ -Value $<

latex/logos/ugent2016-logo-kortrijk-en.pdf: latex/logos/ugent2016-logo-kortrijk-nl.pdf
	powershell New-Item -Force -ItemType SymbolicLink -Name $@ -Value $<

# Create the directory
latex/logos:
	powershell mkdir -f latex/logos

# Convert a single asset
latex/logos/%.pdf: assets/%.eps latex/logos
	epstopdf --outfile=$@ $<

# Clean up some stuff
clean:
	powershell rm -r -force latex/logos/
	latexmk -cd -use-make -C

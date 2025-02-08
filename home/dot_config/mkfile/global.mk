# from CC hihi, for Linux

.SILENT:
%: %.cpp 
	g++ $@.cpp -o $@
	./$@
	echo
	rm $@.exe

%: %.c 
	gcc $@.c -o $@
	./$@
	echo
	rm $@.exe

%: %.py
	python $@.py 

%: %.tex
	pdflatex $@.tex
	rm $@.aux $@.toc $@.out $@.log

clean:
	rm *.exe
	rm *.o

build:
	mkdir -p bin
	crystal build src/main.cr -o bin/main
run:
	bin/main
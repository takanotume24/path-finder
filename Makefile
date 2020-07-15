build:
	mkdir -p bin
	crystal build src/main.cr -o bin/main --static
run:
	bin/main ${OPTION}

run-error-trace: 
	crystal run src/main.cr --error-trace -- ${OPTION}
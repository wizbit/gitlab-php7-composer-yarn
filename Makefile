.PHONY: test
test: 
	docker build . -t test-php-image

.PHONY: run
run:
	docker run --rm -it --entrypoint bash test-php-image:latest

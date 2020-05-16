tag=natverse/r-natverse
password="natverse"

build:
	docker build . --tag $(tag)

bash:
	docker run --rm -ti -v $(HOME):/home/rstudio --user rstudio $(tag) bash
	
r:
	docker run --rm -ti -v $(HOME):/home/rstudio --user rstudio $(tag) R

rstudio:
	docker run -e PASSWORD=$(password) -p 8787:8787 \
	-v $(HOME):/home/$(natuser) \
	natverse/r-natverse

push:
	docker push $(tag)

.PHONY: list
help:
	@echo "The following make targets are available:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

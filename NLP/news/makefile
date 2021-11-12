BASEIMAGE := docker.dragonfly.co.nz/r-text-analysis
IMAGE := $(BASEIMAGE):2021-10-27
# BASEIMAGE := docker.dragonfly.co.nz/r-unsupervised-text-analysis
# IMAGE := $(BASEIMAGE):2021-07-02

UID ?= $(shell id -u)
GID ?= $(shell id -g)

RUN ?= docker run --rm \
			-v $$(pwd)/../..:/work -w /work/NLP/news \
			-e HOME=/work \
			-u $(UID):$(GID) \
			$(IMAGE)

all: .ran

generated/news-data.rds: prepare-data.r
	$(RUN) bash -c "Rscript $<"

.ran: main.r \
			../rbol.r \
			project-config.r \
			project-functions.r \
			generated/news-data.rds
	$(RUN) bash -c "Rscript $<  &&  touch $@"

shiny: shiny/data/data.rdata
shiny/data/data.rdata: prepare-shiny.r \
			.ran
	$(RUN) bash -c "Rscript $<"

APP     = skeleton-python
CLOUD   = gae # lambda ecs gae gce heroku digitalocean up docker
PORT    = 3000

# sources
SRC     = $(wildcard *.py)
STATIC  = ./static/

# toolchain
PYTHON = /usr/local/bin/python
AWS    = /usr/local/bin/aws
GCLOUD = /usr/local/bin/gcloud
HEROKU = /usr/local/bin/heroku
DOCTL  = /usr/local/bin/doctl
DOCKER = /usr/local/bin/docker
GOPATH = $(HOME)/go
UP     = $(GOPATH)/bin/up
GO     = /usr/local/bin/go
BREW   = /usr/local/bin/brew

PROJECT   = $(APP)


# launch service for development (without cloud runtime support)
run: $(PYTHON) .once-pip-install
	$(PYTHON) main.py


# run unit tests then exit
test: $(PYTHON) .once-pip-install
	# nyi


# launch service locally in a manner similar to deployed
run_local: run_local_$(CLOUD)

run_local_lambda:
	@echo "error: AWS Lambda does not run locally" 1>&2
	@exit 1

run_local_gae: deps_gae
	dev_appserver.py gae/app.yaml

run_local_gcf:
	@echo "error: Google Cloud Functions does not run python" 1>&2
	@exit 1

run_local_heroku: $(HEROKU) .once-pip-install
	$(HEROKU) local --port $(PORT) web

run_local_ecs run_local_gce run_local_digitalocean run_local_docker: $(DOCKER) build
	# nyi
	# $(DOCKER) ...

run_local_up:
	@echo "error: Up does not run locally (yet)" 1>&2
	@exit 1


# assemble assets for deployment
build build_cloud:
	true


# launch service in the cloud
deploy: deploy_$(CLOUD)
	# nyi

# AWS Lambda
deploy_lambda: $(AWS) .once-init-aws
	# nyi

# Amazon EC2 Container Service
deploy_ecs: $(AWS) .once-init-aws
	# nyi

# Google App Engine
deploy_gae: $(GCLOUD) deps_gae .once-init-gcloud
	# nyi

# Google Container Engine
deploy_gce: $(GCLOUD) deps_gce .once-init-gcloud
	# nyi

# Google Cloud Functions
deploy_gcf:
	@echo "error: Google Cloud Functions does not run python" 1>&2
	@exit 1

# Heroku Dynos
deploy_heroku: $(HEROKU) .once-init-heroku
	# nyi

# DigitalOcean Droplet (Debian)
deploy_digitalocean: $(DOCTL) .once-init-digitalocean
	# nyi
	# $(DOCTL) compute droplet create name --size 1gb --image image_slug --region nyc1 --ssh-keys ssh_key_fingerprint
	# install systemd
	# start service

deploy_docker:
	@echo "error: Docker is not a cloud; try ecs or gce" 1>&2
	@exit 1

# TJ's Up
deploy_up: $(UP) .once-init-up
	# nyi


# undo "deploy"
revoke: revoke_$(CLOUD)
	# stop service
	# remove instance/app

revoke_lambda: $(AWS) .once-init-aws
	# nyi

revoke_ecs: $(AWS) .once-init-aws
	# nyi

revoke_gae: $(GCLOUD) .once-init-gcloud
	$(GCLOUD) projects delete $(PROJECT)

revoke_gce: $(GCLOUD) .once-init-gcloud
	# nyi

revoke_gcf:
	@echo "error: Google Cloud Functions does not run python" 1>&2
	@exit 1

revoke_heroku: $(HEROKU) .once-init-heroku
	# nyi

revoke_digitalocean: $(DOCTL) .once-init-digitalocean
	# nyi

revoke_docker:
	@echo "error: Docker is not a cloud" 1>&2
	@exit 1

revoke_up: $(UP) .once-init-up
	# nyi


# undo "build"
clean:
	true


# dependencies (tools and sdks)

.once-pip-install: $(PYTHON)
	# nyi
	# XXX python deps
	# pip install Flask (or something using requirements.txt)
	touch $@


# cloud dependencies

deps_gae: $(GCLOUD)
	# nyi

deps_gce: $(GCLOUD)
	# nyi


# toolchain dependencies

$(PYTHON): $(BREW)
	$(BREW) install python3

$(AWS): $(BREW)
	$(BREW) install awscli

$(GCLOUD): $(BREW)
	$(BREW) install cask google-cloud-sdk
	$(GCLOUD) components install app-engine-go

$(HEROKU): $(BREW)
	$(BREW) install heroku

$(DOCTL): $(BREW)
	$(BREW) install doctl

$(DOCKER): $(BREW)
	$(BREW) install docker

$(UP): $(GO)
	$(GO) get github.com/apex/up

$(GO): $(BREW)
	$(BREW) install go

$(BREW):
	/usr/bin/ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# interactively install xcode if missing
# XXX may be moot if "make" or "git" depends on xcode-select
xcode:
	xcode-select --print-path > /dev/null || xcode-select --install


# cloud initialization

.once-init-aws: $(AWS)
	# nyi
	# $(AWS) ...
	touch $@

.once-init-gae: .once-init-gcloud
	# nyi
	# enable GAE api
	$(GCLOUD) app create
	touch $@

.once-init-gce: .once-init-gcloud
	# nyi
	# enable GCE api
	touch $@

.once-init-gcloud: $(GCLOUD)
	$(GCLOUD) --quiet components install app-engine-go
	$(GCLOUD) components install beta
	$(GCLOUD) projects create $(PROJECT)
	$(GCLOUD) beta billing
	$(GCLOUD) init
	touch $@

.once-init-heroku: $(HEROKU)
	# nyi
	touch $@

.once-init-digitalocean: $(DOCTL)
	# nyi
	$(DOCTL) auth init
	touch $@

.once-init-docker: $(DOCKER)
	# nyi
	# $(DOCKER) ...
	touch $@

.once-init-up: $(UP)
	# nyi
	touch $@


.PHONY: run run_local run_local_$(CLOUD)
.PHONY: test
.PHONY: deps_$(CLOUD)
.PHONY: build build_cloud
.PHONY: deploy deploy_$(CLOUD)
.PHONY: revoke revoke_$(CLOUD)
.PHONY: clean

.DEFAULT: run

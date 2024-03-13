# Why are we using a Makefile? PactFlow has around 30 example consumer and provider projects that show how to use Pact. 
# We often use them for demos and workshops, and Makefiles allow us to provide a consistent language and platform agnostic interface
# for each project. You do not need to use Makefiles to use Pact in your own project!

# Default to the read only token - the read/write token will be present on Travis CI.
# It's set as a secure environment variable in the .travis.yml file
GITHUB_ORG="pactflow"
PACTICIPANT ?= "pactflow-example-bi-directional-consumer-cypress"
GITHUB_WEBHOOK_UUID := "04510dc1-7f0a-4ed2-997d-114bfa86f8ad"
PACT_CHANGED_WEBHOOK_UUID := "8e49caaa-0498-4cc1-9368-325de0812c8a"
VERSION?=$(shell npx -y absolute-version)
BRANCH?=$(shell git rev-parse --abbrev-ref HEAD)

## ====================
## Demo Specific Example Variables
## ====================
REACT_APP_API_BASE_URL=http://localhost:3001
PACT_FILES_LOCATION=cypress/pacts

## ====================
## CI tasks
## ====================

all: ci
all_docker: ci_docker
all_ruby_standalone: ci_ruby_standalone
all_ruby_cli: ci_ruby_cli

# Run the ci target from a developer machine with the environment variables
# set as if it was on Github Actions.
# Use this for quick feedback when playing around with your workflows.
ci: test test_and_publish can_i_deploy $(DEPLOY_TARGET)

# Run the ci target from a developer machine with the environment variables
# set as if it was on CI.
# Use this for quick feedback when playing around with your workflows.
fake_ci: .env
	@CI=true \
	make ci

test_and_publish: test publish_pacts

publish_pacts: .env
	@echo "\n========== STAGE: publish_pacts generated with cypress ==========\n"
	@${PACT_BROKER_COMMAND} publish ${PACT_FILES_LOCATION} --consumer-app-version ${VERSION} --branch ${BRANCH}

## =====================
## Build/test tasks
## =====================

install: 
	npm install 

test: .env
	@echo "\n========== STAGE: test ✅ (cypress) ==========\n"
	npm run start:ui:and:test

## =====================
## Deploy tasks
## =====================

# Only deploy from main/master
ifneq ($(filter $(BRANCH),main master),)
	DEPLOY_TARGET=deploy
else
	DEPLOY_TARGET=no_deploy
endif

create_environment:
	@"${PACT_BROKER_COMMAND}" create-environment --name production --production

deploy: deploy_app record_deployment

deploy_target: can_i_deploy $(DEPLOY_TARGET)

no_deploy:
	@echo "Not deploying as not on main branch"

can_i_deploy: .env
	@echo "\n========== STAGE: can-i-deploy? ==========\n"
	@${PACT_BROKER_COMMAND} can-i-deploy \
	  --pacticipant ${PACTICIPANT} \
	  --version ${VERSION} \
	  --to-environment production \
	  --retry-while-unknown 6 \
	  --retry-interval 10

deploy_app:
	@echo "\n========== STAGE: deploy ==========\n"
	@echo "Deploying to production"

record_deployment: .env
	@${PACT_BROKER_COMMAND} record-deployment --pacticipant ${PACTICIPANT} --version ${VERSION} --environment production

## =====================
## PactFlow set up tasks
## =====================

# This should be called once before creating the webhook
# with the environment variable GITHUB_TOKEN set
create_github_token_secret:
	@curl -v -X POST ${PACT_BROKER_BASE_URL}/secrets \
	-H "Authorization: Bearer ${PACT_BROKER_TOKEN}" \
	-H "Content-Type: application/json" \
	-H "Accept: application/hal+json" \
	-d  "{\"name\":\"githubCommitStatusToken\",\"description\":\"Github token for updating commit statuses\",\"value\":\"${GITHUB_TOKEN}\"}"

# This webhook will update the Github commit status for this commit
# so that any PRs will get a status that shows what the status of
# the pact is.
create_or_update_github_commit_status_webhook:
	@${PACT_BROKER_COMMAND} \
	  broker create-or-update-webhook \
	  'https://api.github.com/repos/pactflow/example-consumer/statuses/$${pactbroker.consumerVersionNumber}' \
	  --header 'Content-Type: application/json' 'Accept: application/vnd.github.v3+json' 'Authorization: token $${user.githubCommitStatusToken}' \
	  --request POST \
	  --data @${PWD}/pactflow/github-commit-status-webhook.json \
	  --uuid ${GITHUB_WEBHOOK_UUID} \
	  --consumer ${PACTICIPANT} \
	  --contract-published \
	  --provider-verification-published \
	  --description "Github commit status webhook for ${PACTICIPANT}"

test_github_webhook:
	@curl -v -X POST ${PACT_BROKER_BASE_URL}/webhooks/${GITHUB_WEBHOOK_UUID}/execute -H "Authorization: Bearer ${PACT_BROKER_TOKEN}"

## ======================
## Misc
## ======================

.env:
	touch .env

output:
	mkdir -p ./pacts
	touch ./pacts/tmp

clean: output
	rm pacts/*

## =====================
## Multi-platform detection and support
## Pact CLI install/uninstall tasks
## =====================
SHELL := /bin/bash
PACT_TOOL?=docker
PACT_CLI_DOCKER_VERSION?=latest
PACT_CLI_VERSION?=latest
PACT_CLI_STANDALONE_VERSION?=2.4.1
PACT_CLI_DOCKER_RUN_COMMAND?=docker run --rm -v /${PWD}:/${PWD} -w ${PWD} -e PACT_BROKER_BASE_URL -e PACT_BROKER_TOKEN pactfoundation/pact-cli:${PACT_CLI_DOCKER_VERSION}
PACT_BROKER_COMMAND=pact-broker
PACTFLOW_CLI_COMMAND=pactflow

ifeq '$(findstring ;,$(PATH))' ';'
	detected_OS := Windows
else
	detected_OS := $(shell uname -sm 2>/dev/null || echo Unknown)
	detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
	detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
	detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
endif

ifeq ($(PACT_TOOL),ruby_standalone)
# add path to standalone, and add bat if windows
	ifneq ($(filter $(detected_OS),Windows MSYS),)
		PACT_BROKER_COMMAND:="./pact/bin/${PACT_BROKER_COMMAND}.bat"
		PACTFLOW_CLI_COMMAND:="./pact/bin/${PACTFLOW_CLI_COMMAND}.bat"
	else
		PACT_BROKER_COMMAND:="./pact/bin/${PACT_BROKER_COMMAND}"
		PACTFLOW_CLI_COMMAND:="./pact/bin/${PACTFLOW_CLI_COMMAND}"
	endif
endif

ifeq ($(PACT_TOOL),docker)
# add docker run command path
	PACT_BROKER_COMMAND:=${PACT_CLI_DOCKER_RUN_COMMAND} ${PACT_BROKER_COMMAND}
	PACTFLOW_CLI_COMMAND:=${PACT_CLI_DOCKER_RUN_COMMAND} ${PACTFLOW_CLI_COMMAND}
endif


install-pact-ruby-cli:
	case "${PACT_CLI_VERSION}" in \
	latest) gem install pact_broker-client;; \
	"") gem install pact_broker-client;; \
		*) gem install pact_broker-client -v ${PACT_CLI_VERSION} ;; \
	esac

uninstall-pact-ruby-cli:
	gem uninstall -aIx pact_broker-client

install-pact-ruby-standalone:
	case "${detected_OS}" in \
	Windows|MSYS) curl -LO https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v${PACT_CLI_STANDALONE_VERSION}/pact-${PACT_CLI_STANDALONE_VERSION}-windows-x86_64.zip && \
		unzip pact-${PACT_CLI_STANDALONE_VERSION}-windows-x86_64.zip && \
		./pact/bin/pact-mock-service.bat --help && \
		./pact/bin/pact-provider-verifier.bat --help && \
		./pact/bin/pactflow.bat help;; \
	"Darwin arm64") curl -LO https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v${PACT_CLI_STANDALONE_VERSION}/pact-${PACT_CLI_STANDALONE_VERSION}-osx-arm64.tar.gz && \
		tar xzf pact-${PACT_CLI_STANDALONE_VERSION}-osx-arm64.tar.gz && \
		./pact/bin/pact-mock-service --help && \
		./pact/bin/pact-provider-verifier --help && \
		./pact/bin/pactflow help;; \
	"Darwin x86_64") curl -LO https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v${PACT_CLI_STANDALONE_VERSION}/pact-${PACT_CLI_STANDALONE_VERSION}-osx-x86_64.tar.gz && \
		tar xzf pact-${PACT_CLI_STANDALONE_VERSION}-osx-x86_64.tar.gz && \
		./pact/bin/pact-mock-service --help && \
		./pact/bin/pact-provider-verifier --help && \
		./pact/bin/pactflow help;; \
	"Linux aarch64") curl -LO https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v${PACT_CLI_STANDALONE_VERSION}/pact-${PACT_CLI_STANDALONE_VERSION}-linux-arm64.tar.gz && \
		tar xzf pact-${PACT_CLI_STANDALONE_VERSION}-linux-arm64.tar.gz && \
		./pact/bin/pact-mock-service --help && \
		./pact/bin/pact-provider-verifier --help && \
		./pact/bin/pactflow help;; \
	"Linux x86_64") curl -LO https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v${PACT_CLI_STANDALONE_VERSION}/pact-${PACT_CLI_STANDALONE_VERSION}-linux-x86_64.tar.gz && \
		tar xzf pact-${PACT_CLI_STANDALONE_VERSION}-linux-x86_64.tar.gz && \
		./pact/bin/pact-mock-service --help && \
		./pact/bin/pact-provider-verifier --help && \
		./pact/bin/pactflow help;; \
	esac

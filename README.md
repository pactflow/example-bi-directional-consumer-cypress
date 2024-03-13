# Example NodeJS/React Consumer - Cypress (BYO Adapter)

[![Build](https://github.com/pactflow/example-bi-directional-consumer-cypress/actions/workflows/build.yml/badge.svg)](https://github.com/pactflow/example-bi-directional-consumer-cypress/actions/workflows/build.yml)

[![Can I Deploy Status](https://testdemo.pactflow.io/pacticipants/pactflow-example-bi-directional-consumer-cypress/branches/main/latest-version/can-i-deploy/to-environment/production/badge)](https://testdemo.pactflow.io/pacticipants/pactflow-example-bi-directional-consumer-cypress/branches/main/latest-version/can-i-deploy/to-environment/production/badge)

- [Example NodeJS/React Consumer - Cypress (BYO Adapter)](#example-nodejsreact-consumer---cypress-byo-adapter)
  - [Overview of Example](#overview-of-example)
    - [Key points with Cypress](#key-points-with-cypress)
  - [Overview of Part of Bi-Directional Contract Testing Flow](#overview-of-part-of-bi-directional-contract-testing-flow)
  - [Compatible with Providers](#compatible-with-providers)
  - [Pre-requisites](#pre-requisites)
    - [Environment variables](#environment-variables)
  - [Usage](#usage)
    - [Steps](#steps)
  - [OS/Platform specific considerations](#osplatform-specific-considerations)
  - [Caveats](#caveats)
  - [Related topics / posts / discussions](#related-topics--posts--discussions)
  - [Other examples of how to do this form of testing](#other-examples-of-how-to-do-this-form-of-testing)
  - [Found an issue?](#found-an-issue)

## Overview of Example

<!-- Consumer Overview -->

This is an example of a React "Product" API consumer that uses Cypress, [pact-cypress-adapter](https://www.npmjs.com/package/@pactflow/pact-cypress-adapter), [PactFlow](https://pactflow.io) and GitHub Actions to generate and publish Pact consumer contracts.

It performs pre-deployment cross-compatibility checks to ensure that it is compatible with specified providers using the Bi-Directional contract capability of PactFlow.

<!-- General -->

See the full [PactFlow Bi-Directional Workshop](https://docs.pactflow.io/docs/workshops/bi-directional-contract-testing) for which this can be substituted in as the "consumer".

### Key points with Cypress

It:

- It is a React app implementing a "Product" website created with Create React App
- It utilises Cypress to functionally test the website
- It utilises [pact-cypress-adapter](https://www.npmjs.com/package/@pactflow/pact-cypress-adapter) to transform cypress mocks into Pact consumer contracts.

## Overview of Part of Bi-Directional Contract Testing Flow

<!-- Consumer Overview -->

In the following diagram, You can see how the consumer testing process works - it's the same as the current Pact process.

When we call "can-i-deploy" the cross-contract validation process kicks off on PactFlow, to ensure any consumer consumes a valid subset of the OAS for the provider.

![Consumer Test](docs/consumer-scope.png 'Consumer Test')

The project uses a Makefile to simulate a very simple build pipeline with two stages - test and deploy.

When you run the CI pipeline (see below for doing this), the pipeline should perform the following activities (simplified):

- Test
  - Run tests (including the pact tests that generate the contract)
  - Publish pacts, tagging the consumer version with the name of the current branch
  - Check if we are safe to deploy to Production with `can-i-deploy` (ie. has the cross-contract validation has been successfully performed)
- Deploy (only from <main|master>)
  - Deploy app to Production
  - Record the Production deployment in the Pact Broker

![Consumer Pipeline](docs./../docs/consumer-pipeline.png 'Consumer Pipeline')

## Compatible with Providers

<!-- Provider Compatability -->

This project is currently compatible with the following provider(s):

- [pactflow-example-bi-directional-provider-dredd](https://github.com/pactflow/example-bi-directional-provider-dredd)
- [pactflow-example-bi-directional-provider-restassured](https://github.com/pactflow/example-provider-restassured)
- [pactflow-example-bi-directional-provider-postman](https://github.com/pactflow/example-bi-directional-provider-postman)
<!-- * [pactflow-example-bi-directional-provider-dotnet](https://github.com/pactflow/example-bi-directional-provider-dotnet) -->

See [Environment variables](#environment-variables) on how to set these up.

## Pre-requisites

**Software**:

- Tools listed at: https://docs.pactflow.io/docs/workshops/ci-cd/set-up-ci/prerequisites/
- A pactflow.io account with a valid [API token](https://docs.pactflow.io/docs/getting-started/#configuring-your-api-token)

### Environment variables

To be able to run some of the commands locally, you will need to export the following environment variables into your shell:

- `PACT_BROKER_TOKEN`: a valid [API token](https://docs.pactflow.io/docs/getting-started/#configuring-your-api-token) for PactFlow
- `PACT_BROKER_BASE_URL`: a fully qualified domain name with protocol to your pact broker e.g. https://testdemo.pactflow.io

<!-- CONSUMER env vars -->

Set `PACT_PROVIDER` to one of the following

- `PACT_PROVIDER=pactflow-example-bi-directional-provider-dredd`: Dredd - (https://github.com/pactflow/example-bi-directional-provider-dredd)
- `PACT_PROVIDER=pactflow-example-bi-directional-provider-postman`: Postman - (https://github.com/pactflow/example-bi-directional-provider-postman)
- `PACT_PROVIDER=pactflow-example-bi-directional-provider-restassured`: Rest Assured - (https://github.com/pactflow/example-bi-directional-provider-restassured)

## Usage

### Steps

NOTE: Cypress tests are located in `./cypress/e2e`. See below for how to start cypress test, generate a consumer contract, and publish the contract to pactflow.

- `make install` - install project dependencies

Run each step separately

- `make test_and_publish` - tests the consumer and publishes pact contracts to PactFlow
  - This will perform the following 2 calls
    - `make test`
    - `make publish_pacts`
- `make can_i_deploy` - runs can-i-deploy to check if its safe to deploy the consumer
- `make deploy` - deploys the app and records deployment

or run the whole lot in one go

- `make ci` - run the CI process, but locally (uses Docker by default)

Installing alternate pact CLI tools.

If you don't have docker, you can use one of the ruby tools. The standalone doesn't require that you install Ruby on your host machine.

- `make install-pact-ruby-cli` - installs the pact ruby CLI tool
- `make install-pact-ruby-standalone` - installs the pact standalone CLI depending on your platform
- `make uninstall-pact-ruby-standalone` - uninstalls the pact standalone CLI

Using alternate pact CLI tools.

- `PACT_TOOL=docker make ci` - run the CI process, using the pact Docker CLI tool
- `PACT_TOOL=ruby_standalone make ci` - run the CI process, using the pact standalone CLI tool
- `PACT_TOOL=ruby_cli make ci` - run the CI process, using the pact ruby CLI tool

_How to use Cypress_

- Spin up the ui project by running `npm run start`
- Define your pact provider and consumer name at `cypress.config.cjs` as cypress environment variables
- You can stub your network request and response with `cy.intercept`, and record network call to a consumer-driven contract with `cy.usePactWait`. Each request you want to add to the contract must call this method.
- `npm run cypress:headless:chrome` - this will run cypress e2e test in headless mode, and write stubbed network calls a pact file
- `npm run cypress:run` - this will run cypress e2e test with browser ui

## OS/Platform specific considerations

The Makefile has been configured to run on Unix/Windows and MacOS-based systems, and tested against GitHub Actions

They can be run locally on Unix/Windows and MacOS, or on Windows via [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) or a shell with bash.

## Caveats

- [OAS considerations](https://docs.pactflow.io/docs/bi-directional-contract-testing/contracts/oas#considerations)

## Related topics / posts / discussions

- [Consumer Side Bi-Directional Contract Testing Guide](https://docs.pactflow.io/docs/bi-directional-contract-testing/consumer)
- [Provider Side Bi-Directional Contract Testing Guide](https://docs.pactflow.io/docs/bi-directional-contract-testing/provider)

## Other examples of how to do this form of testing

- TBC

## Found an issue?

Reach out via a GitHub Issue, or reach us over in the [Pact Foundation Slack](https://slack.pact.io)

/* eslint-disable no-undef */
/// <reference types="cypress" />
// ***********************************************************
// This example plugins/index.js can be used to load plugins
//
// You can change the location of this file or turn off loading
// the plugins file with the 'pluginsFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/plugins-guide
// ***********************************************************

// This function is called when a project is opened or re-opened (e.g. due to
// the project's config changing)

/**
 * @type {Cypress.PluginConfig}
 */
 const pactCypressPlugin = require('@pactflow/pact-cypress-adapter/dist/plugin')
 const fs = require('fs')
 
 module.exports = (on, config) => {
   config.env.PACT_PROVIDER = process.env.PACT_PROVIDER || 'pactflow-example-provider-postman'
   pactCypressPlugin(on, config, fs)
   return config
 }

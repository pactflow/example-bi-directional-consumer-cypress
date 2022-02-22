import { formatAlias, writePact } from './utils'

Cypress.Commands.add('usePactWait', (alias) => {
  const formattedAlias = formatAlias(alias)
  const testCaseTitle = Cypress.currentTest.title
  const providerName = Cypress.env('PACT_CONSUMER') || 'consumer'
  const consumerName = Cypress.env('PACT_PROVIDER') || 'provider'
  const filePath = `cypress/pacts/${providerName}-${consumerName}.json`
  cy.wait([...formattedAlias]).spread((...intercepts) => {
    intercepts.forEach((intercept, index) => {
      writePact(filePath, intercept, `${testCaseTitle}-${formattedAlias[index]}`)
    })
  })
})

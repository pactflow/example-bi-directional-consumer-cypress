import { formatAlias, writePact } from './utils'

Cypress.Commands.add('usePactWait', (alias) => {
  const formattedAlias = formatAlias(alias)
  const testCaseTitle = Cypress.currentTest.title
  const providerName = Cypress.env('PACT_CONSUMER') || 'consumer'
  const consumerName = Cypress.env('PACT_PROVIDER') || 'provider'
  const filePath = `cypress/pacts/${providerName}-${consumerName}.json`
  if (formattedAlias.length > 1) {
    cy.wait([...formattedAlias]).spread((...intercepts) => {
      intercepts.forEach((intercept, index) => {
        writePact(filePath, intercept, `${testCaseTitle}-${formattedAlias[index]}`)
      })
    })
  } else {
    cy.wait(formattedAlias).then((intercept) => {
      writePact(filePath, intercept, `${testCaseTitle}`)
    })
  }
})

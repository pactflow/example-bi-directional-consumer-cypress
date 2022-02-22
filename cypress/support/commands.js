import { constructPactFile } from './utils'

Cypress.Commands.add('usePactWait', (alias) => {
  cy.wait(`@${alias}`).then((response) => {
    const testCaseTitle = Cypress.currentTest.title
    const providerName = Cypress.env('PACT_CONSUMER') || 'consumer'
    const consumerName = Cypress.env('PACT_PROVIDER') || 'provider'
    const filePath = `cypress/pacts/${providerName}-${consumerName}.json`

    cy.task('readFileMaybe', filePath).then((content) => {
      if (content) {
        const data = constructPactFile(response, testCaseTitle, JSON.parse(content))
        cy.writeFile(filePath, JSON.stringify(data))
      } else {
        const data = constructPactFile(response, testCaseTitle)
        cy.writeFile(filePath, JSON.stringify(data))
      }
    })
  })
})

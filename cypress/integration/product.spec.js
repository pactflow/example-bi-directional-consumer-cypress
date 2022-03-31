const productResponse = require('../fixtures/product.json')

describe('product page', () => {
  beforeEach(() => {
    cy.intercept(
      {
        method: 'GET',
        url: '**/product/*'
      },
      {
        statusCode: 200,
        body: { ...productResponse },
        headers: { 'access-control-allow-origin': '*' }
      },
    ).as('getProduct')
    cy.setupPact('pactflow-example-consumer-cypress', 'pactflow-example-provider-dredd')
    cy.visit('http://localhost:3000/products/09')
  })

  it('displays product item', () => {
    cy.get('.product-id').contains('09')
    cy.get('.product-name').contains('Gem Visa')
    cy.get('.product-type').contains('CREDIT_CARD')
  })

  after(() => {
    cy.usePactWait(['getProduct'])
  })
})

const productsResponse = require('../fixtures/products.json')

describe('products page', () => {
  beforeEach(() => {
    cy.intercept(
      {
        method: 'GET',
        url: 'http://localhost:3001/products'
      },
      {
        statusCode: 200,
        body: productsResponse,
        headers: { 'access-control-allow-origin': '*' }
      }
    ).as('getProducts')
    cy.setupPact(Cypress.env('PACT_CONSUMER'), Cypress.env('PACT_PROVIDER'))

    cy.visit('http://localhost:3000/products')
  })

  it('displays products', () => {
    cy.get('.product-item').its('length').should('eq', 3)
  })

  after(() => {
    cy.usePactWait(['getProducts'])
  })
})

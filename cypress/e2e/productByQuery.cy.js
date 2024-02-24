const productResponse = require('../fixtures/products.json')

describe('products page with query', () => {
  beforeEach(() => {
    cy.intercept(
      {
        url: 'http://localhost:3001/products*',
        query: {
          id: '2'
        }
      },
      {
        statusCode: 200,
        body: productResponse,
        headers: { 'access-control-allow-origin': '*' }
      }
    ).as('getProductById')

    cy.setupPact(Cypress.env('PACT_CONSUMER'), Cypress.env('PACT_PROVIDER'))
    cy.visit('http://localhost:3000/products?id=2')
  })

  it('displays product item by query', () => {
    cy.usePactWait('getProductById')
    cy.get('.product-item').its('length').should('eq', 3)
  })
})

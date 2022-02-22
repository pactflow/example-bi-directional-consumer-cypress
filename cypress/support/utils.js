import { uniqBy, reverse } from 'lodash'

const constructInteraction = (intercept, testTitle) => {
  const path = new URL(intercept.request.url).pathname
  const search = new URL(intercept.request.url).search
  const query = new URLSearchParams(search).toString()
  return {
    description: testTitle,
    providerState: '',
    request: {
      method: intercept.request.method,
      path: path,
      headers: intercept.request.headers,
      body: intercept.request.body,
      query: query
    },
    response: {
      status: intercept.response.statusCode,
      headers: intercept.response.headers,
      body: intercept.response.body
    }
  }
}
export const constructPactFile = (intercept, testTitle, content) => {
    console.log('intercept', intercept)
  const pactSkeletonObject = {
    consumer: { name: Cypress.env('PACT_CONSUMER') || 'consumer' },
    provider: { name: Cypress.env('PACT_PROVIDER') || 'provider' },
    interactions: [],
    metadata: {
      pactSpecification: {
        version: '2.0.0'
      }
    }
  }

  if (content) {
    const interactions = [...content.interactions, constructInteraction(intercept, testTitle)]
    const nonDuplicatesInteractions = reverse(uniqBy(reverse(interactions), 'description'))
    const data = {
      ...pactSkeletonObject,
      ...content,
      interactions: nonDuplicatesInteractions
    }
    return data
  }

  return {
    ...pactSkeletonObject,
    interactions: [...pactSkeletonObject.interactions, constructInteraction(intercept, testTitle)]
  }
}

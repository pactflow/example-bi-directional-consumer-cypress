import { uniqBy, reverse, omit } from 'lodash'

const OMITTED_AUTOGEN_CYPRESS_HEADERS = ['access-control-expose-headers', 
  'access-control-allow-credentials', 
  'host',
  'proxy-connection',
  'sec-ch-ua',
  'sec-ch-ua-mobile',
  'user-agent',
  'sec-ch-ua-platform',
  'origin',
  'sec-fetch-site',
  'sec-fetch-mode',
  'sec-fetch-dest',
  'referer',
  'accept-encoding',
  'accept-language'
]
export const formatAlias = (alias) => {
  if (Array.isArray(alias)) {
    return [...alias].map((a) => `@${a}`)
  }
  return [`@${alias}`]
}

export const writePact = (filePath, intercept, testCaseTitle) => {
  cy.task('readFileMaybe', filePath).then((content) => {
    if (content) {
      const data = constructPactFile(intercept, testCaseTitle, JSON.parse(content))
      cy.writeFile(filePath, JSON.stringify(data))
    } else {
      const data = constructPactFile(intercept, testCaseTitle)
      cy.writeFile(filePath, JSON.stringify(data))
    }
  })
}

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
      headers: omit(intercept.request.headers, OMITTED_AUTOGEN_CYPRESS_HEADERS),
      body: intercept.request.body,
      query: query
    },
    response: {
      status: intercept.response.statusCode,
      headers: omit(intercept.response.headers, OMITTED_AUTOGEN_CYPRESS_HEADERS),
      body: intercept.response.body
    }
  }
}

export const constructPactFile = (intercept, testTitle, content) => {
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

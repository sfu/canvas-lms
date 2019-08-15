/*
 * Copyright (C) 2018 - present Instructure, Inc.
 *
 * This file is part of Canvas.
 *
 * Canvas is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import $ from 'jquery'
import * as uploadFileModule from '../../../shared/upload_file'
import {fireEvent, render, waitForElement} from '@testing-library/react'
import {CREATE_SUBMISSION_DRAFT} from '../graphqlData/Mutations'
import {createCache} from '../../../canvas-apollo'
import {MockedProvider} from 'react-apollo/test-utils'
import {mockQuery} from '../mocks'
import React from 'react'
import {STUDENT_VIEW_QUERY, SUBMISSION_ID_QUERY} from '../graphqlData/Queries'
import SubmissionIDQuery from '../components/SubmissionIDQuery'

async function createGraphqlMocks(overrides = {}) {
  const mocks = [
    {
      query: SUBMISSION_ID_QUERY,
      variables: {assignmentLid: '1'}
    },
    {
      query: STUDENT_VIEW_QUERY,
      variables: {assignmentLid: '1', submissionID: '1'}
    },
    {
      query: CREATE_SUBMISSION_DRAFT,
      variables: {id: '1', attempt: 1, fileIds: ['1']}
    }
  ]

  const mockResults = await Promise.all(
    mocks.map(async ({query, variables}) => {
      const result = await mockQuery(query, overrides, variables)
      return {
        request: {query, variables},
        result
      }
    })
  )
  return mockResults
}

describe('SubmissionIDQuery', () => {
  beforeEach(() => {
    window.ENV = {
      context_asset_string: 'test_1',
      COURSE_ID: '1',
      current_user: {display_name: 'bob', avatar_url: 'awesome.avatar.url'},
      PREREQS: {}
    }
  })

  // TODO: These three tests could be moved to the SubmissionIDQuery unit test file
  it('renders normally', async () => {
    const mocks = await createGraphqlMocks()
    const {getByTestId} = render(
      <MockedProvider mocks={mocks} cache={createCache()}>
        <SubmissionIDQuery assignmentLid="1" />
      </MockedProvider>
    )
    expect(
      await waitForElement(() => getByTestId('assignments-2-student-view'))
    ).toBeInTheDocument()
  })

  it('renders loading', async () => {
    const mocks = await createGraphqlMocks()
    const {getByTitle} = render(
      <MockedProvider mocks={mocks} cache={createCache()}>
        <SubmissionIDQuery assignmentLid="1" />
      </MockedProvider>
    )

    expect(getByTitle('Loading')).toBeInTheDocument()
  })

  it('renders error', async () => {
    const mocks = await createGraphqlMocks()
    mocks[1].error = new Error('aw shucks')
    const {getByText} = render(
      <MockedProvider mocks={mocks} cache={createCache()}>
        <SubmissionIDQuery assignmentLid="1" />
      </MockedProvider>
    )

    expect(await waitForElement(() => getByText('Sorry, Something Broke'))).toBeInTheDocument()
  })

  // This cannot be tested at the <AttemptTab> because the new file being
  // displayed happens as a result of a cache write and these higher level
  // components re-rendering
  it('displays the new file after it has been uploaded', async () => {
    window.URL.createObjectURL = jest.fn()
    uploadFileModule.uploadFiles = jest.fn()
    uploadFileModule.uploadFiles.mockReturnValueOnce([{id: '1', name: 'file1.jpg'}])
    $('body').append('<div role="alert" id="flash_screenreader_holder" />')

    const mocks = await createGraphqlMocks({
      CreateSubmissionDraftPayload: () => ({
        submissionDraft: () => ({attachments: [{displayName: 'test.jpg'}]})
      })
    })

    const {container, getAllByText} = render(
      <MockedProvider mocks={mocks} cache={createCache()}>
        <SubmissionIDQuery assignmentLid="1" />
      </MockedProvider>
    )

    const files = [new File(['foo'], 'file1.jpg', {type: 'image/jpg'})]
    const fileInput = await waitForElement(() =>
      container.querySelector('input[id="inputFileDrop"]')
    )
    fireEvent.change(fileInput, {target: {files}})
    expect(await waitForElement(() => getAllByText('test.jpg')[0])).toBeInTheDocument()
  })
})

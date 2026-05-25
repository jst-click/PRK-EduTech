import { useMemo, useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { useApiData } from '../hooks/useApiData'
import { apiRequest } from '../services/apiClient'

function TestsPage() {
  const { data: tests, loading, error, refresh } = useApiData('/api/tests', { useToken: false })
  const [payload, setPayload] = useState({
    title: '',
    topic: '',
    description: '',
    duration: '30',
    questionsText:
      'Question 1|Option 1|Option 2|Option 3|Option 4|option1|Solution line',
  })
  const [message, setMessage] = useState('')

  const parsedQuestions = useMemo(() => {
    return payload.questionsText
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean)
      .map((line) => {
        const [questionText, option1, option2, option3, option4, correctOption, solution] =
          line.split('|')
        return {
          questionText,
          options: { option1, option2, option3, option4 },
          correctOption,
          solution,
        }
      })
  }, [payload.questionsText])

  const createTest = async (event) => {
    event.preventDefault()
    try {
      await apiRequest('/api/tests', {
        method: 'POST',
        body: {
          title: payload.title,
          topic: payload.topic,
          description: payload.description,
          duration: Number(payload.duration),
          questions: parsedQuestions,
        },
      })
      setMessage('Test created')
      setPayload({
        title: '',
        topic: '',
        description: '',
        duration: '30',
        questionsText: '',
      })
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const deleteTest = async (id) => {
    if (!window.confirm('Delete this test?')) return
    try {
      await apiRequest(`/api/tests/${id}`, { method: 'DELETE' })
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  return (
    <section className="card">
      <PageHeader title="Tests" description="Create and control test series content" />
      <form className="grid-form two-cols" onSubmit={createTest}>
        <input
          placeholder="Title"
          value={payload.title}
          onChange={(event) => setPayload((prev) => ({ ...prev, title: event.target.value }))}
          required
        />
        <input
          placeholder="Topic"
          value={payload.topic}
          onChange={(event) => setPayload((prev) => ({ ...prev, topic: event.target.value }))}
          required
        />
        <textarea
          placeholder="Description"
          value={payload.description}
          onChange={(event) => setPayload((prev) => ({ ...prev, description: event.target.value }))}
          required
        />
        <input
          type="number"
          min="1"
          placeholder="Duration in minutes"
          value={payload.duration}
          onChange={(event) => setPayload((prev) => ({ ...prev, duration: event.target.value }))}
          required
        />
        <textarea
          className="questions-textarea"
          placeholder="Each line: question|opt1|opt2|opt3|opt4|correctOption|solution"
          value={payload.questionsText}
          onChange={(event) => setPayload((prev) => ({ ...prev, questionsText: event.target.value }))}
          required
        />
        <button className="btn" type="submit">
          Create Test
        </button>
      </form>
      {message && <p className="muted">{message}</p>}
      {error && <p className="error-text">{error}</p>}
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Title</th>
              <th>Topic</th>
              <th>Duration</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={4}>Loading tests...</td>
              </tr>
            )}
            {!loading &&
              tests.map((test) => (
                <tr key={test._id}>
                  <td>{test.title}</td>
                  <td>{test.topic}</td>
                  <td>{test.duration} min</td>
                  <td>
                    <button className="btn btn-danger" type="button" onClick={() => deleteTest(test._id)}>
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>
    </section>
  )
}

export default TestsPage

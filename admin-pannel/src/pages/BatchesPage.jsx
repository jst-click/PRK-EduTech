import { useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { useApiData } from '../hooks/useApiData'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

function BatchesPage() {
  const { token } = getStoredSession()
  const { data: batches, loading, error, refresh } = useApiData('/api/batches')
  const [form, setForm] = useState({ name: '', batchId: '', description: '' })
  const [message, setMessage] = useState('')

  const createBatch = async (event) => {
    event.preventDefault()
    setMessage('')
    try {
      await apiRequest('/api/batches', { token, method: 'POST', body: form })
      setForm({ name: '', batchId: '', description: '' })
      setMessage('Batch created successfully')
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  return (
    <section className="card">
      <PageHeader title="Batches" description="Create and monitor student batches" />
      <form className="grid-form" onSubmit={createBatch}>
        <input
          placeholder="Batch name"
          value={form.name}
          onChange={(event) => setForm((prev) => ({ ...prev, name: event.target.value }))}
          required
        />
        <input
          placeholder="Batch ID"
          value={form.batchId}
          onChange={(event) => setForm((prev) => ({ ...prev, batchId: event.target.value }))}
          required
        />
        <input
          placeholder="Description"
          value={form.description}
          onChange={(event) => setForm((prev) => ({ ...prev, description: event.target.value }))}
        />
        <button type="submit" className="btn">
          Create Batch
        </button>
      </form>
      {message && <p className="muted">{message}</p>}
      {error && <p className="error-text">{error}</p>}
      {loading ? (
        <p className="muted">Loading batches...</p>
      ) : (
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Batch ID</th>
                <th>Description</th>
              </tr>
            </thead>
            <tbody>
              {batches.map((batch) => (
                <tr key={batch._id}>
                  <td>{batch.name}</td>
                  <td>{batch.batchId}</td>
                  <td>{batch.description || '-'}</td>
                </tr>
              ))}
              {!batches.length && (
                <tr>
                  <td colSpan={3} className="muted">
                    No batches available
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </section>
  )
}

export default BatchesPage

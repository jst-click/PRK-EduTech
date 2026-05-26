import { useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import DetailsModal from '../components/common/DetailsModal'
import { useApiData } from '../hooks/useApiData'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'
import { truncateWords } from '../utils/text'

function BatchesPage() {
  const { token } = getStoredSession()
  const { data: batches, loading, error, refresh } = useApiData('/api/batches')
  const [form, setForm] = useState({ name: '', batchId: '', description: '' })
  const [showAddForm, setShowAddForm] = useState(false)
  const [message, setMessage] = useState('')
  const [selectedBatch, setSelectedBatch] = useState(null)

  const createBatch = async (event) => {
    event.preventDefault()
    setMessage('')
    try {
      await apiRequest('/api/batches', { token, method: 'POST', body: form })
      setForm({ name: '', batchId: '', description: '' })
      setMessage('Batch created successfully')
      setShowAddForm(false)
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  return (
    <section className="card">
      <PageHeader
        title="Batches"
        description="Create and monitor student batches"
        action={
          <button type="button" className="btn" onClick={() => setShowAddForm((prev) => !prev)}>
            {showAddForm ? 'Close Form' : 'Add Batch'}
          </button>
        }
      />
      {showAddForm && (
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
          <div className="form-actions">
            <button type="submit" className="btn">
              Save Batch
            </button>
            <button type="button" className="btn btn-secondary" onClick={() => setShowAddForm(false)}>
              Cancel
            </button>
          </div>
        </form>
      )}
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
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {batches.map((batch) => (
                <tr key={batch._id}>
                  <td>{batch.name}</td>
                  <td>{batch.batchId}</td>
                  <td>{truncateWords(batch.description, 12)}</td>
                  <td>
                    <button className="btn btn-secondary" type="button" onClick={() => setSelectedBatch(batch)}>
                      View
                    </button>
                  </td>
                </tr>
              ))}
              {!batches.length && (
                <tr>
                  <td colSpan={4} className="muted">
                    No batches available
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}
      <DetailsModal
        title="Batch Details"
        details={
          selectedBatch
            ? [
                { label: 'Name', value: selectedBatch.name },
                { label: 'Batch ID', value: selectedBatch.batchId },
                { label: 'Description', value: selectedBatch.description || '-' },
              ]
            : null
        }
        onClose={() => setSelectedBatch(null)}
      />
    </section>
  )
}

export default BatchesPage

import { useMemo, useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { useApiData } from '../hooks/useApiData'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

const initialForm = {
  question: '',
  answer: '',
  source: '',
  publishedAt: '',
}

function formatDateForInput(value) {
  if (!value) return ''
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return ''
  const pad = (num) => String(num).padStart(2, '0')
  const yyyy = parsed.getFullYear()
  const mm = pad(parsed.getMonth() + 1)
  const dd = pad(parsed.getDate())
  const hh = pad(parsed.getHours())
  const min = pad(parsed.getMinutes())
  return `${yyyy}-${mm}-${dd}T${hh}:${min}`
}

function formatDateForTable(value) {
  if (!value) return '-'
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return '-'
  return parsed.toLocaleString()
}

function CurrentAffairsPage() {
  const { token } = getStoredSession()
  const { data: currentAffairs, loading, error, refresh } = useApiData('/api/current-affairs', { useToken: false })
  const [form, setForm] = useState(initialForm)
  const [editingId, setEditingId] = useState('')
  const [message, setMessage] = useState('')
  const [saving, setSaving] = useState(false)

  const isEditing = useMemo(() => Boolean(editingId), [editingId])

  const handleSubmit = async (event) => {
    event.preventDefault()
    if (!form.question.trim() || !form.answer.trim()) return

    setSaving(true)
    setMessage('')
    try {
      const payload = {
        question: form.question.trim(),
        answer: form.answer.trim(),
        source: form.source.trim(),
      }

      if (form.publishedAt) {
        payload.publishedAt = new Date(form.publishedAt).toISOString()
      }

      if (isEditing) {
        await apiRequest(`/api/current-affairs/${editingId}`, {
          token,
          method: 'PUT',
          body: payload,
        })
        setMessage('Current affair updated')
      } else {
        await apiRequest('/api/current-affairs', {
          token,
          method: 'POST',
          body: payload,
        })
        setMessage('Current affair created')
      }

      setForm(initialForm)
      setEditingId('')
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    } finally {
      setSaving(false)
    }
  }

  const handleEdit = (item) => {
    setEditingId(item._id)
    setForm({
      question: item.question || '',
      answer: item.answer || '',
      source: item.source || '',
      publishedAt: formatDateForInput(item.publishedAt),
    })
    setMessage('')
  }

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this current affair item?')) return
    setMessage('')
    try {
      await apiRequest(`/api/current-affairs/${id}`, { token, method: 'DELETE' })
      if (editingId === id) {
        setEditingId('')
        setForm(initialForm)
      }
      setMessage('Current affair deleted')
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const resetForm = () => {
    setEditingId('')
    setForm(initialForm)
    setMessage('')
  }

  return (
    <section className="card">
      <PageHeader title="Current Affairs" description="Manage current affairs shown in app home and sidebar" />

      <form className="grid-form two-cols" onSubmit={handleSubmit}>
        <input
          placeholder="Headline / Question"
          value={form.question}
          onChange={(event) => setForm((prev) => ({ ...prev, question: event.target.value }))}
          required
        />
        <textarea
          placeholder="Details / Answer"
          value={form.answer}
          onChange={(event) => setForm((prev) => ({ ...prev, answer: event.target.value }))}
          required
        />
        <input
          placeholder="Source (optional)"
          value={form.source}
          onChange={(event) => setForm((prev) => ({ ...prev, source: event.target.value }))}
        />
        <input
          type="datetime-local"
          value={form.publishedAt}
          onChange={(event) => setForm((prev) => ({ ...prev, publishedAt: event.target.value }))}
        />
        <div className="form-actions">
          <button className="btn" type="submit" disabled={saving}>
            {saving ? 'Saving...' : isEditing ? 'Update Current Affair' : 'Add Current Affair'}
          </button>
          <button type="button" className="btn btn-secondary" onClick={resetForm}>
            Clear
          </button>
        </div>
      </form>

      {message && <p className="muted">{message}</p>}
      {error && <p className="error-text">{error}</p>}

      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Headline</th>
              <th>Details</th>
              <th>Source</th>
              <th>Date</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={5}>Loading current affairs...</td>
              </tr>
            )}
            {!loading &&
              currentAffairs.map((item) => (
                <tr key={item._id}>
                  <td>{item.question}</td>
                  <td>{item.answer}</td>
                  <td>{item.source || '-'}</td>
                  <td>{formatDateForTable(item.publishedAt || item.createdAt)}</td>
                  <td>
                    <div className="row-actions">
                      <button type="button" className="btn btn-secondary" onClick={() => handleEdit(item)}>
                        Edit
                      </button>
                      <button type="button" className="btn btn-danger" onClick={() => handleDelete(item._id)}>
                        Delete
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            {!loading && !currentAffairs.length && (
              <tr>
                <td colSpan={5} className="muted">
                  No current affairs found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </section>
  )
}

export default CurrentAffairsPage

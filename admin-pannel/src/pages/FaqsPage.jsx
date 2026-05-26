import { useMemo, useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { useApiData } from '../hooks/useApiData'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

const initialForm = {
  question: '',
  answer: '',
}

function FaqsPage() {
  const { token } = getStoredSession()
  const { data: faqs, loading, error, refresh } = useApiData('/api/faqs', { useToken: false })
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
      if (isEditing) {
        await apiRequest(`/api/faqs/${editingId}`, {
          token,
          method: 'PUT',
          body: form,
        })
        setMessage('FAQ updated')
      } else {
        await apiRequest('/api/faqs', {
          token,
          method: 'POST',
          body: form,
        })
        setMessage('FAQ created')
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

  const handleEdit = (faq) => {
    setEditingId(faq._id)
    setForm({
      question: faq.question || '',
      answer: faq.answer || '',
    })
    setMessage('')
  }

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this FAQ?')) return
    setMessage('')
    try {
      await apiRequest(`/api/faqs/${id}`, { token, method: 'DELETE' })
      if (editingId === id) {
        setEditingId('')
        setForm(initialForm)
      }
      setMessage('FAQ deleted')
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
      <PageHeader title="FAQ" description="Manage frequently asked questions shown in app" />

      <form className="grid-form two-cols" onSubmit={handleSubmit}>
        <input
          placeholder="Question"
          value={form.question}
          onChange={(event) => setForm((prev) => ({ ...prev, question: event.target.value }))}
          required
        />
        <textarea
          placeholder="Answer"
          value={form.answer}
          onChange={(event) => setForm((prev) => ({ ...prev, answer: event.target.value }))}
          required
        />
        <div className="form-actions">
          <button className="btn" type="submit" disabled={saving}>
            {saving ? 'Saving...' : isEditing ? 'Update FAQ' : 'Add FAQ'}
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
              <th>Question</th>
              <th>Answer</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={3}>Loading FAQs...</td>
              </tr>
            )}
            {!loading &&
              faqs.map((faq) => (
                <tr key={faq._id}>
                  <td>{faq.question}</td>
                  <td>{faq.answer}</td>
                  <td>
                    <div className="row-actions">
                      <button type="button" className="btn btn-secondary" onClick={() => handleEdit(faq)}>
                        Edit
                      </button>
                      <button type="button" className="btn btn-danger" onClick={() => handleDelete(faq._id)}>
                        Delete
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            {!loading && !faqs.length && (
              <tr>
                <td colSpan={3} className="muted">
                  No FAQ found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </section>
  )
}

export default FaqsPage

import { useMemo, useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { useApiData } from '../hooks/useApiData'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

const initialForm = {
  name: '',
  designation: '',
  message: '',
  rating: '5',
}

function TestimonialsPage() {
  const { token } = getStoredSession()
  const { data: testimonials, loading, error, refresh } = useApiData('/api/testimonials', { useToken: false })
  const [form, setForm] = useState(initialForm)
  const [editingId, setEditingId] = useState('')
  const [message, setMessage] = useState('')
  const [saving, setSaving] = useState(false)

  const isEditing = useMemo(() => Boolean(editingId), [editingId])

  const handleSubmit = async (event) => {
    event.preventDefault()
    if (!form.name.trim() || !form.message.trim()) return

    const ratingValue = Number(form.rating)
    if (!Number.isInteger(ratingValue) || ratingValue < 1 || ratingValue > 5) {
      setMessage('Rating must be between 1 and 5')
      return
    }

    setSaving(true)
    setMessage('')

    try {
      const payload = {
        name: form.name.trim(),
        designation: form.designation.trim(),
        message: form.message.trim(),
        rating: ratingValue,
      }

      if (isEditing) {
        await apiRequest(`/api/testimonials/${editingId}`, {
          token,
          method: 'PUT',
          body: payload,
        })
        setMessage('Testimonial updated')
      } else {
        await apiRequest('/api/testimonials', {
          token,
          method: 'POST',
          body: payload,
        })
        setMessage('Testimonial created')
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
      name: item.name || '',
      designation: item.designation || '',
      message: item.message || '',
      rating: String(item.rating || 5),
    })
    setMessage('')
  }

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this testimonial?')) return
    setMessage('')
    try {
      await apiRequest(`/api/testimonials/${id}`, { token, method: 'DELETE' })
      if (editingId === id) {
        setEditingId('')
        setForm(initialForm)
      }
      setMessage('Testimonial deleted')
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
      <PageHeader title="Testimonials" description="Manage testimonials shown inside the app sidebar section" />

      <form className="grid-form two-cols" onSubmit={handleSubmit}>
        <input
          placeholder="Name"
          value={form.name}
          onChange={(event) => setForm((prev) => ({ ...prev, name: event.target.value }))}
          required
        />
        <input
          placeholder="Designation / Role (optional)"
          value={form.designation}
          onChange={(event) => setForm((prev) => ({ ...prev, designation: event.target.value }))}
        />
        <textarea
          placeholder="Testimonial message"
          value={form.message}
          onChange={(event) => setForm((prev) => ({ ...prev, message: event.target.value }))}
          required
        />
        <input
          type="number"
          min={1}
          max={5}
          placeholder="Rating (1 to 5)"
          value={form.rating}
          onChange={(event) => setForm((prev) => ({ ...prev, rating: event.target.value }))}
          required
        />
        <div className="form-actions">
          <button className="btn" type="submit" disabled={saving}>
            {saving ? 'Saving...' : isEditing ? 'Update Testimonial' : 'Add Testimonial'}
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
              <th>Name</th>
              <th>Designation</th>
              <th>Rating</th>
              <th>Message</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={5}>Loading testimonials...</td>
              </tr>
            )}
            {!loading &&
              testimonials.map((item) => (
                <tr key={item._id}>
                  <td>{item.name}</td>
                  <td>{item.designation || '-'}</td>
                  <td>{item.rating || 5}</td>
                  <td>{item.message}</td>
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
            {!loading && !testimonials.length && (
              <tr>
                <td colSpan={5} className="muted">
                  No testimonials found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </section>
  )
}

export default TestimonialsPage

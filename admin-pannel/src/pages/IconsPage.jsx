import { useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import DetailsModal from '../components/common/DetailsModal'
import { useApiData } from '../hooks/useApiData'
import { apiRequest } from '../services/apiClient'

function IconsPage() {
  const { data: icons, loading, error, refresh } = useApiData('/icons', { useToken: false })
  const [showAddForm, setShowAddForm] = useState(false)
  const [form, setForm] = useState({ image: '', label: '' })
  const [message, setMessage] = useState('')
  const [selectedIcon, setSelectedIcon] = useState(null)

  const createIcon = async (event) => {
    event.preventDefault()
    try {
      await apiRequest('/icons', { method: 'POST', body: form })
      setForm({ image: '', label: '' })
      setMessage('Icon created')
      setShowAddForm(false)
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const deleteIcon = async (id) => {
    if (!window.confirm('Delete icon?')) return
    try {
      await apiRequest(`/icons/${id}`, { method: 'DELETE' })
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  return (
    <section className="card">
      <PageHeader
        title="Icons"
        description="Configure icon labels and image links"
        action={
          <button type="button" className="btn" onClick={() => setShowAddForm((prev) => !prev)}>
            {showAddForm ? 'Close Form' : 'Add Icon'}
          </button>
        }
      />
      {showAddForm && (
        <form className="grid-form" onSubmit={createIcon}>
          <input
            value={form.label}
            placeholder="Label"
            onChange={(event) => setForm((prev) => ({ ...prev, label: event.target.value }))}
            required
          />
          <input
            value={form.image}
            placeholder="Image URL"
            onChange={(event) => setForm((prev) => ({ ...prev, image: event.target.value }))}
          />
          <div className="form-actions">
            <button className="btn" type="submit">
              Save Icon
            </button>
            <button type="button" className="btn btn-secondary" onClick={() => setShowAddForm(false)}>
              Cancel
            </button>
          </div>
        </form>
      )}
      {message && <p className="muted">{message}</p>}
      {error && <p className="error-text">{error}</p>}
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Label</th>
              <th>Image</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={4}>Loading icons...</td>
              </tr>
            )}
            {!loading &&
              icons.map((icon) => (
                <tr key={icon._id}>
                  <td>{icon.id}</td>
                  <td>{icon.label}</td>
                  <td className="truncate">{icon.image || '-'}</td>
                  <td>
                    <div className="row-actions">
                      <button className="btn btn-secondary" type="button" onClick={() => setSelectedIcon(icon)}>
                        View
                      </button>
                      <button className="btn btn-danger" type="button" onClick={() => deleteIcon(icon.id)}>
                        Delete
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>
      <DetailsModal
        title="Icon Details"
        details={
          selectedIcon
            ? [
                { label: 'ID', value: selectedIcon.id },
                { label: 'Label', value: selectedIcon.label },
                { label: 'Image URL', value: selectedIcon.image || '-' },
              ]
            : null
        }
        onClose={() => setSelectedIcon(null)}
      />
    </section>
  )
}

export default IconsPage

import { useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { useApiData } from '../hooks/useApiData'
import { apiRequest } from '../services/apiClient'

function IconsPage() {
  const { data: icons, loading, error, refresh } = useApiData('/icons', { useToken: false })
  const [form, setForm] = useState({ image: '', label: '' })
  const [message, setMessage] = useState('')

  const createIcon = async (event) => {
    event.preventDefault()
    try {
      await apiRequest('/icons', { method: 'POST', body: form })
      setForm({ image: '', label: '' })
      setMessage('Icon created')
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
      <PageHeader title="Icons" description="Configure icon labels and image links" />
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
        <button className="btn" type="submit">
          Create Icon
        </button>
      </form>
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
                    <button className="btn btn-danger" type="button" onClick={() => deleteIcon(icon.id)}>
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

export default IconsPage

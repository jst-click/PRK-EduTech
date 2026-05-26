import { useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import DetailsModal from '../components/common/DetailsModal'
import { useApiData } from '../hooks/useApiData'
import { apiRequest } from '../services/apiClient'
import { truncateWords } from '../utils/text'

const initialForm = {
  bookName: '',
  author: '',
  description: '',
  subject: 'General',
  difficultyLevel: 'general',
  pricing: 'free',
  thumbnail: null,
  pdf: null,
}

function NotesPage() {
  const { data: notes, loading, error, refresh } = useApiData('/api/resources?contentType=notes', {
    useToken: false,
  })
  const [showAddForm, setShowAddForm] = useState(false)
  const [form, setForm] = useState(initialForm)
  const [message, setMessage] = useState('')
  const [selectedNote, setSelectedNote] = useState(null)

  const createNote = async (event) => {
    event.preventDefault()
    const data = new FormData()
    data.append('bookName', form.bookName)
    data.append('author', form.author)
    data.append('description', form.description)
    data.append('subject', form.subject)
    data.append('difficultyLevel', form.difficultyLevel)
    data.append('pricing', form.pricing)
    data.append('contentType', 'notes')
    if (form.thumbnail) data.append('thumbnail', form.thumbnail)
    if (form.pdf) data.append('pdf', form.pdf)

    try {
      await apiRequest('/api/resources', {
        method: 'POST',
        body: data,
        isFormData: true,
      })
      setMessage('Note created')
      setForm(initialForm)
      setShowAddForm(false)
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const deleteNote = async (id) => {
    if (!window.confirm('Delete this note?')) return
    try {
      await apiRequest(`/api/resources/${id}`, { method: 'DELETE' })
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  return (
    <section className="card">
      <PageHeader
        title="Notes"
        description="Create and manage educational notes shown in app"
        action={
          <button type="button" className="btn" onClick={() => setShowAddForm((prev) => !prev)}>
            {showAddForm ? 'Close Form' : 'Add Note'}
          </button>
        }
      />
      {showAddForm && (
        <form className="grid-form two-cols" onSubmit={createNote}>
          <input
            placeholder="Note title"
            value={form.bookName}
            onChange={(event) => setForm((prev) => ({ ...prev, bookName: event.target.value }))}
            required
          />
          <input
            placeholder="Author"
            value={form.author}
            onChange={(event) => setForm((prev) => ({ ...prev, author: event.target.value }))}
            required
          />
          <input
            placeholder="Subject (e.g. Mathematics)"
            value={form.subject}
            onChange={(event) => setForm((prev) => ({ ...prev, subject: event.target.value }))}
            required
          />
          <label>
            <span>Difficulty</span>
            <select
              value={form.difficultyLevel}
              onChange={(event) => setForm((prev) => ({ ...prev, difficultyLevel: event.target.value }))}
            >
              <option value="general">General</option>
              <option value="beginner">Beginner</option>
              <option value="intermediate">Intermediate</option>
              <option value="advanced">Advanced</option>
            </select>
          </label>
          <label>
            <span>Pricing</span>
            <select
              value={form.pricing}
              onChange={(event) => setForm((prev) => ({ ...prev, pricing: event.target.value }))}
            >
              <option value="free">Free</option>
              <option value="paid">Paid</option>
            </select>
          </label>
          <label>
            <span>Thumbnail</span>
            <input
              type="file"
              accept="image/*"
              onChange={(event) =>
                setForm((prev) => ({ ...prev, thumbnail: event.target.files?.[0] || null }))
              }
            />
          </label>
          <label>
            <span>PDF</span>
            <input
              type="file"
              accept=".pdf"
              onChange={(event) => setForm((prev) => ({ ...prev, pdf: event.target.files?.[0] || null }))}
            />
          </label>
          <textarea
            placeholder="Description"
            value={form.description}
            onChange={(event) => setForm((prev) => ({ ...prev, description: event.target.value }))}
            required
          />
          <div className="form-actions">
            <button className="btn" type="submit">
              Save Note
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
              <th>Title</th>
              <th>Author</th>
              <th>Subject</th>
              <th>Level</th>
              <th>Pricing</th>
              <th>Description</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={7}>Loading notes...</td>
              </tr>
            )}
            {!loading &&
              notes.map((note) => (
                <tr key={note._id}>
                  <td>{note.bookName}</td>
                  <td>{note.author}</td>
                  <td>{note.subject || 'General'}</td>
                  <td>{(note.difficultyLevel || 'general').toUpperCase()}</td>
                  <td>{(note.pricing || 'free').toUpperCase()}</td>
                  <td>{truncateWords(note.description, 12)}</td>
                  <td>
                    <div className="row-actions">
                      <button className="btn btn-secondary" type="button" onClick={() => setSelectedNote(note)}>
                        View
                      </button>
                      <button className="btn btn-danger" type="button" onClick={() => deleteNote(note._id)}>
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
        title="Note Details"
        details={
          selectedNote
            ? [
                { label: 'Title', value: selectedNote.bookName },
                { label: 'Author', value: selectedNote.author },
                { label: 'Subject', value: selectedNote.subject || 'General' },
                { label: 'Difficulty', value: selectedNote.difficultyLevel || 'general' },
                { label: 'Pricing', value: selectedNote.pricing || 'free' },
                { label: 'Description', value: selectedNote.description },
                { label: 'Thumbnail', value: selectedNote.thumbnail || '-' },
                { label: 'PDF', value: selectedNote.pdf || '-' },
              ]
            : null
        }
        onClose={() => setSelectedNote(null)}
      />
    </section>
  )
}

export default NotesPage

import { useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import DetailsModal from '../components/common/DetailsModal'
import { useApiData } from '../hooks/useApiData'
import { apiRequest } from '../services/apiClient'
import { truncateWords } from '../utils/text'

function EbooksPage() {
  const { data: books, loading, error, refresh } = useApiData('/api/ebooks', { useToken: false })
  const [showAddForm, setShowAddForm] = useState(false)
  const [form, setForm] = useState({
    bookName: '',
    author: '',
    description: '',
    thumbnail: null,
    pdf: null,
  })
  const [message, setMessage] = useState('')
  const [selectedBook, setSelectedBook] = useState(null)

  const createBook = async (event) => {
    event.preventDefault()
    const data = new FormData()
    data.append('bookName', form.bookName)
    data.append('author', form.author)
    data.append('description', form.description)
    if (form.thumbnail) data.append('thumbnail', form.thumbnail)
    if (form.pdf) data.append('pdf', form.pdf)

    try {
      await apiRequest('/api/ebooks', {
        method: 'POST',
        body: data,
        isFormData: true,
      })
      setMessage('Book created')
      setForm({ bookName: '', author: '', description: '', thumbnail: null, pdf: null })
      setShowAddForm(false)
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const deleteBook = async (id) => {
    if (!window.confirm('Delete this ebook?')) return
    try {
      await apiRequest(`/api/ebooks/${id}`, { method: 'DELETE' })
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  return (
    <section className="card">
      <PageHeader
        title="Ebooks"
        description="Upload and manage digital books"
        action={
          <button type="button" className="btn" onClick={() => setShowAddForm((prev) => !prev)}>
            {showAddForm ? 'Close Form' : 'Add Ebook'}
          </button>
        }
      />
      {showAddForm && (
        <form className="grid-form two-cols" onSubmit={createBook}>
          <input
            placeholder="Book name"
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
          <textarea
            placeholder="Description"
            value={form.description}
            onChange={(event) => setForm((prev) => ({ ...prev, description: event.target.value }))}
            required
          />
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
          <div className="form-actions">
            <button className="btn" type="submit">
              Save Ebook
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
              <th>Name</th>
              <th>Author</th>
              <th>Description</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={4}>Loading books...</td>
              </tr>
            )}
            {!loading &&
              books.map((book) => (
                <tr key={book._id}>
                  <td>{book.bookName}</td>
                  <td>{book.author}</td>
                  <td>{truncateWords(book.description, 12)}</td>
                  <td>
                    <div className="row-actions">
                      <button className="btn btn-secondary" type="button" onClick={() => setSelectedBook(book)}>
                        View
                      </button>
                      <button className="btn btn-danger" type="button" onClick={() => deleteBook(book._id)}>
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
        title="Ebook Details"
        details={
          selectedBook
            ? [
                { label: 'Name', value: selectedBook.bookName },
                { label: 'Author', value: selectedBook.author },
                { label: 'Description', value: selectedBook.description },
                { label: 'Thumbnail', value: selectedBook.thumbnail || '-' },
                { label: 'PDF', value: selectedBook.pdf || '-' },
              ]
            : null
        }
        onClose={() => setSelectedBook(null)}
      />
    </section>
  )
}

export default EbooksPage

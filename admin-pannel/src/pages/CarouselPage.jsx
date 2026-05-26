import { useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import DetailsModal from '../components/common/DetailsModal'
import { useApiData } from '../hooks/useApiData'
import { apiRequest } from '../services/apiClient'

function CarouselPage() {
  const { data: images, loading, error, refresh } = useApiData('/api/carouselImages/withIds', {
    useToken: false,
  })
  const [showAddForm, setShowAddForm] = useState(false)
  const [uploadFile, setUploadFile] = useState(null)
  const [message, setMessage] = useState('')
  const [selectedImage, setSelectedImage] = useState(null)

  const uploadImage = async (event) => {
    event.preventDefault()
    if (!uploadFile) return
    const data = new FormData()
    data.append('image', uploadFile)
    try {
      await apiRequest('/api/carouselImages', {
        method: 'POST',
        body: data,
        isFormData: true,
      })
      setUploadFile(null)
      setMessage('Image uploaded')
      setShowAddForm(false)
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const deleteImage = async (id) => {
    if (!window.confirm('Delete this image?')) return
    try {
      await apiRequest(`/api/carouselImages/${id}`, { method: 'DELETE' })
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  return (
    <section className="card">
      <PageHeader
        title="Carousel Images"
        description="Upload and remove home slider images"
        action={
          <button type="button" className="btn" onClick={() => setShowAddForm((prev) => !prev)}>
            {showAddForm ? 'Close Form' : 'Add Image'}
          </button>
        }
      />
      {showAddForm && (
        <form className="inline-tools" onSubmit={uploadImage}>
          <input
            type="file"
            accept="image/*"
            onChange={(event) => setUploadFile(event.target.files?.[0] || null)}
          />
          <button className="btn" type="submit">
            Save Image
          </button>
          <button className="btn btn-secondary" type="button" onClick={() => setShowAddForm(false)}>
            Cancel
          </button>
        </form>
      )}
      {message && <p className="muted">{message}</p>}
      {error && <p className="error-text">{error}</p>}
      <div className="cards-grid">
        {loading && <p>Loading images...</p>}
        {!loading &&
          images.map((image) => (
            <article className="mini-card" key={image._id}>
              <img src={image.imageUrl} alt={`carousel-${image.id}`} />
              <p>ID: {image.id}</p>
              <div className="row-actions">
                <button className="btn btn-secondary" type="button" onClick={() => setSelectedImage(image)}>
                  View
                </button>
                <button className="btn btn-danger" type="button" onClick={() => deleteImage(image.id)}>
                  Delete
                </button>
              </div>
            </article>
          ))}
      </div>
      <DetailsModal
        title="Carousel Image Details"
        details={
          selectedImage
            ? [
                { label: 'ID', value: selectedImage.id },
                { label: 'Mongo ID', value: selectedImage._id },
                { label: 'Image URL', value: selectedImage.imageUrl || '-' },
              ]
            : null
        }
        onClose={() => setSelectedImage(null)}
      />
    </section>
  )
}

export default CarouselPage

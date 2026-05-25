import { useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { useApiData } from '../hooks/useApiData'
import { apiRequest } from '../services/apiClient'

function CarouselPage() {
  const { data: images, loading, error, refresh } = useApiData('/api/carouselImages/withIds', {
    useToken: false,
  })
  const [uploadFile, setUploadFile] = useState(null)
  const [message, setMessage] = useState('')

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
      <PageHeader title="Carousel Images" description="Upload and remove home slider images" />
      <form className="inline-tools" onSubmit={uploadImage}>
        <input type="file" accept="image/*" onChange={(event) => setUploadFile(event.target.files?.[0] || null)} />
        <button className="btn" type="submit">
          Upload
        </button>
      </form>
      {message && <p className="muted">{message}</p>}
      {error && <p className="error-text">{error}</p>}
      <div className="cards-grid">
        {loading && <p>Loading images...</p>}
        {!loading &&
          images.map((image) => (
            <article className="mini-card" key={image._id}>
              <img src={image.imageUrl} alt={`carousel-${image.id}`} />
              <p>ID: {image.id}</p>
              <button className="btn btn-danger" type="button" onClick={() => deleteImage(image.id)}>
                Delete
              </button>
            </article>
          ))}
      </div>
    </section>
  )
}

export default CarouselPage

import { useMemo, useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { useApiData } from '../hooks/useApiData'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

const initialOnlineClassForm = {
  title: '',
  date: '',
  time: '',
  description: '',
  img: null,
}

const initialYoutubeLinkForm = {
  title: '',
  link: '',
  description: '',
}

function OnlineClassesPage() {
  const { token } = getStoredSession()
  const [activeType, setActiveType] = useState('online')
  const [onlineClassForm, setOnlineClassForm] = useState(initialOnlineClassForm)
  const [youtubeLinkForm, setYoutubeLinkForm] = useState(initialYoutubeLinkForm)
  const [editingOnlineClassId, setEditingOnlineClassId] = useState('')
  const [editingYoutubeLinkId, setEditingYoutubeLinkId] = useState('')
  const [message, setMessage] = useState('')
  const [saving, setSaving] = useState(false)

  const {
    data: onlineClasses,
    loading: onlineClassesLoading,
    error: onlineClassesError,
    refresh: refreshOnlineClasses,
  } = useApiData('/api/online-classes', { useToken: false })

  const {
    data: youtubeLinks,
    loading: youtubeLinksLoading,
    error: youtubeLinksError,
    refresh: refreshYoutubeLinks,
  } = useApiData('/api/youtube-links', { useToken: false })

  const isEditingOnlineClass = useMemo(() => Boolean(editingOnlineClassId), [editingOnlineClassId])
  const isEditingYoutubeLink = useMemo(() => Boolean(editingYoutubeLinkId), [editingYoutubeLinkId])

  const handleOnlineClassSubmit = async (event) => {
    event.preventDefault()
    if (
      !onlineClassForm.title.trim() ||
      !onlineClassForm.date.trim() ||
      !onlineClassForm.time.trim() ||
      !onlineClassForm.description.trim()
    ) {
      return
    }

    setSaving(true)
    setMessage('')
    try {
      const data = new FormData()
      data.append('title', onlineClassForm.title.trim())
      data.append('date', onlineClassForm.date.trim())
      data.append('time', onlineClassForm.time.trim())
      data.append('description', onlineClassForm.description.trim())
      if (onlineClassForm.img) {
        data.append('img', onlineClassForm.img)
      }

      if (isEditingOnlineClass) {
        await apiRequest(`/api/online-classes/${editingOnlineClassId}`, {
          token,
          method: 'PUT',
          body: data,
          isFormData: true,
        })
        setMessage('Online class updated')
      } else {
        await apiRequest('/api/online-classes', {
          token,
          method: 'POST',
          body: data,
          isFormData: true,
        })
        setMessage('Online class added')
      }

      setOnlineClassForm(initialOnlineClassForm)
      setEditingOnlineClassId('')
      refreshOnlineClasses()
    } catch (requestError) {
      setMessage(requestError.message)
    } finally {
      setSaving(false)
    }
  }

  const handleYoutubeLinkSubmit = async (event) => {
    event.preventDefault()
    if (!youtubeLinkForm.title.trim() || !youtubeLinkForm.link.trim() || !youtubeLinkForm.description.trim()) return

    setSaving(true)
    setMessage('')
    try {
      const payload = {
        title: youtubeLinkForm.title.trim(),
        link: youtubeLinkForm.link.trim(),
        description: youtubeLinkForm.description.trim(),
      }

      if (isEditingYoutubeLink) {
        await apiRequest(`/api/youtube-links/${editingYoutubeLinkId}`, {
          token,
          method: 'PUT',
          body: payload,
        })
        setMessage('Youtube link updated')
      } else {
        await apiRequest('/api/youtube-links', {
          token,
          method: 'POST',
          body: payload,
        })
        setMessage('Youtube link added')
      }

      setYoutubeLinkForm(initialYoutubeLinkForm)
      setEditingYoutubeLinkId('')
      refreshYoutubeLinks()
    } catch (requestError) {
      setMessage(requestError.message)
    } finally {
      setSaving(false)
    }
  }

  const handleEditOnlineClass = (item) => {
    setActiveType('online')
    setEditingOnlineClassId(item._id)
    setOnlineClassForm({
      title: item.title || '',
      date: item.date || '',
      time: item.time || '',
      description: item.description || '',
      img: null,
    })
    setMessage('Select a new image only if you want to replace the existing image.')
  }

  const handleEditYoutubeLink = (item) => {
    setActiveType('youtube')
    setEditingYoutubeLinkId(item._id)
    setYoutubeLinkForm({
      title: item.title || '',
      link: item.link || '',
      description: item.description || '',
    })
    setMessage('')
  }

  const handleDeleteOnlineClass = async (id) => {
    if (!window.confirm('Delete this online class?')) return
    setMessage('')
    try {
      await apiRequest(`/api/online-classes/${id}`, { token, method: 'DELETE' })
      if (editingOnlineClassId === id) {
        setEditingOnlineClassId('')
        setOnlineClassForm(initialOnlineClassForm)
      }
      setMessage('Online class deleted')
      refreshOnlineClasses()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const handleDeleteYoutubeLink = async (id) => {
    if (!window.confirm('Delete this youtube link?')) return
    setMessage('')
    try {
      await apiRequest(`/api/youtube-links/${id}`, { token, method: 'DELETE' })
      if (editingYoutubeLinkId === id) {
        setEditingYoutubeLinkId('')
        setYoutubeLinkForm(initialYoutubeLinkForm)
      }
      setMessage('Youtube link deleted')
      refreshYoutubeLinks()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const clearActiveForm = () => {
    if (activeType === 'online') {
      setEditingOnlineClassId('')
      setOnlineClassForm(initialOnlineClassForm)
    } else {
      setEditingYoutubeLinkId('')
      setYoutubeLinkForm(initialYoutubeLinkForm)
    }
    setMessage('')
  }

  return (
    <section className="card">
      <PageHeader title="Online Class" description="Manage online class cards and YouTube links from one place" />

      <div className="cms-type-buttons">
        <button
          type="button"
          className={activeType === 'online' ? 'btn' : 'btn btn-secondary'}
          onClick={() => setActiveType('online')}
        >
          Online Class
        </button>
        <button
          type="button"
          className={activeType === 'youtube' ? 'btn' : 'btn btn-secondary'}
          onClick={() => setActiveType('youtube')}
        >
          YouTube Links
        </button>
      </div>

      {activeType === 'online' ? (
        <>
          <form className="grid-form two-cols" onSubmit={handleOnlineClassSubmit}>
            <input
              placeholder="Title"
              value={onlineClassForm.title}
              onChange={(event) => setOnlineClassForm((prev) => ({ ...prev, title: event.target.value }))}
              required
            />
            <input
              type="date"
              value={onlineClassForm.date}
              onChange={(event) => setOnlineClassForm((prev) => ({ ...prev, date: event.target.value }))}
              required
            />
            <input
              type="time"
              value={onlineClassForm.time}
              onChange={(event) => setOnlineClassForm((prev) => ({ ...prev, time: event.target.value }))}
              required
            />
            <label>
              <span>Image</span>
              <input
                type="file"
                accept="image/*"
                onChange={(event) =>
                  setOnlineClassForm((prev) => ({
                    ...prev,
                    img: event.target.files && event.target.files[0] ? event.target.files[0] : null,
                  }))
                }
              />
            </label>
            <textarea
              placeholder="Description"
              value={onlineClassForm.description}
              onChange={(event) => setOnlineClassForm((prev) => ({ ...prev, description: event.target.value }))}
              required
            />
            <div className="form-actions">
              <button className="btn" type="submit" disabled={saving}>
                {saving ? 'Saving...' : isEditingOnlineClass ? 'Update Online Class' : 'Add Online Class'}
              </button>
              <button type="button" className="btn btn-secondary" onClick={clearActiveForm}>
                Clear
              </button>
            </div>
          </form>

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Image</th>
                  <th>Title</th>
                  <th>Date</th>
                  <th>Time</th>
                  <th>Description</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {onlineClassesLoading && (
                  <tr>
                    <td colSpan={6}>Loading online classes...</td>
                  </tr>
                )}
                {!onlineClassesLoading &&
                  onlineClasses.map((item) => (
                    <tr key={item._id}>
                      <td>
                        {item.img ? (
                          <img src={item.img} alt={item.title} style={{ width: 60, height: 40, objectFit: 'cover' }} />
                        ) : (
                          '-'
                        )}
                      </td>
                      <td>{item.title}</td>
                      <td>{item.date}</td>
                      <td>{item.time}</td>
                      <td>{item.description}</td>
                      <td>
                        <div className="row-actions">
                          <button type="button" className="btn btn-secondary" onClick={() => handleEditOnlineClass(item)}>
                            Edit
                          </button>
                          <button
                            type="button"
                            className="btn btn-danger"
                            onClick={() => handleDeleteOnlineClass(item._id)}
                          >
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                {!onlineClassesLoading && !onlineClasses.length && (
                  <tr>
                    <td colSpan={6} className="muted">
                      No online classes found
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </>
      ) : (
        <>
          <form className="grid-form two-cols" onSubmit={handleYoutubeLinkSubmit}>
            <input
              placeholder="Title"
              value={youtubeLinkForm.title}
              onChange={(event) => setYoutubeLinkForm((prev) => ({ ...prev, title: event.target.value }))}
              required
            />
            <input
              placeholder="YouTube Link"
              value={youtubeLinkForm.link}
              onChange={(event) => setYoutubeLinkForm((prev) => ({ ...prev, link: event.target.value }))}
              required
            />
            <textarea
              placeholder="Description"
              value={youtubeLinkForm.description}
              onChange={(event) => setYoutubeLinkForm((prev) => ({ ...prev, description: event.target.value }))}
              required
            />
            <div className="form-actions">
              <button className="btn" type="submit" disabled={saving}>
                {saving ? 'Saving...' : isEditingYoutubeLink ? 'Update YouTube Link' : 'Add YouTube Link'}
              </button>
              <button type="button" className="btn btn-secondary" onClick={clearActiveForm}>
                Clear
              </button>
            </div>
          </form>

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Title</th>
                  <th>YouTube Link</th>
                  <th>Description</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {youtubeLinksLoading && (
                  <tr>
                    <td colSpan={4}>Loading youtube links...</td>
                  </tr>
                )}
                {!youtubeLinksLoading &&
                  youtubeLinks.map((item) => (
                    <tr key={item._id}>
                      <td>{item.title}</td>
                      <td>
                        <a href={item.link} target="_blank" rel="noreferrer">
                          {item.link}
                        </a>
                      </td>
                      <td>{item.description}</td>
                      <td>
                        <div className="row-actions">
                          <button type="button" className="btn btn-secondary" onClick={() => handleEditYoutubeLink(item)}>
                            Edit
                          </button>
                          <button
                            type="button"
                            className="btn btn-danger"
                            onClick={() => handleDeleteYoutubeLink(item._id)}
                          >
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                {!youtubeLinksLoading && !youtubeLinks.length && (
                  <tr>
                    <td colSpan={4} className="muted">
                      No youtube links found
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </>
      )}

      {message && <p className="muted">{message}</p>}
      {(onlineClassesError || youtubeLinksError) && <p className="error-text">{onlineClassesError || youtubeLinksError}</p>}
    </section>
  )
}

export default OnlineClassesPage

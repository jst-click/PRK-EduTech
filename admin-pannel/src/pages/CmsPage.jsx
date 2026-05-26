import { useEffect, useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

function CmsPage() {
  const { token } = getStoredSession()
  const [cmsData, setCmsData] = useState({ terms: '', privacy: '' })
  const [activeType, setActiveType] = useState('')
  const [description, setDescription] = useState('')
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    const loadCms = async () => {
      setLoading(true)
      setError('')
      try {
        const response = await apiRequest('/api/cms')
        setCmsData({
          terms: response?.terms || '',
          privacy: response?.privacy || '',
        })
      } catch (requestError) {
        setError(requestError.message)
      } finally {
        setLoading(false)
      }
    }

    loadCms()
  }, [])

  const onSelectType = (type) => {
    setActiveType(type)
    setDescription(cmsData[type] || '')
    setMessage('')
    setError('')
  }

  const saveCms = async (event) => {
    event.preventDefault()
    if (!activeType) {
      setError('Please select Terms or Privacy first.')
      return
    }

    setSaving(true)
    setMessage('')
    setError('')
    try {
      const response = await apiRequest('/api/cms', {
        token,
        method: 'PUT',
        body: {
          type: activeType,
          description,
        },
      })

      const nextData = {
        terms: response?.terms || '',
        privacy: response?.privacy || '',
      }
      setCmsData(nextData)
      setDescription(nextData[activeType] || '')
      setMessage(`${activeType === 'terms' ? 'Terms' : 'Privacy'} saved successfully.`)
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <section className="card">
      <PageHeader
        title="CMS"
        description="Manage Terms and Privacy content shown in the app"
      />

      <div className="cms-type-buttons">
        <button
          type="button"
          className={`btn ${activeType === 'terms' ? '' : 'btn-secondary'}`}
          onClick={() => onSelectType('terms')}
        >
          Terms
        </button>
        <button
          type="button"
          className={`btn ${activeType === 'privacy' ? '' : 'btn-secondary'}`}
          onClick={() => onSelectType('privacy')}
        >
          Privacy
        </button>
      </div>

      {loading && <p className="muted">Loading CMS content...</p>}
      {message && <p className="success-text">{message}</p>}
      {error && <p className="error-text">{error}</p>}

      {!loading && activeType && (
        <form className="cms-form" onSubmit={saveCms}>
          <label htmlFor="cms-description">
            <span>Description</span>
            <textarea
              id="cms-description"
              value={description}
              onChange={(event) => setDescription(event.target.value)}
              placeholder={`Enter ${activeType} description`}
              required
            />
          </label>
          <div className="form-actions">
            <button type="submit" className="btn" disabled={saving}>
              {saving ? 'Saving...' : 'Add'}
            </button>
          </div>
        </form>
      )}
    </section>
  )
}

export default CmsPage

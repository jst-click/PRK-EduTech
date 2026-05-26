import { useMemo, useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { useApiData } from '../hooks/useApiData'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

const initialForm = {
  title: '',
  organisationName: '',
  postName: '',
  noOfVacancies: '',
  qualificationNeeded: '',
  lastDateToApply: '',
  linkToApply: '',
  sector: 'govt',
}

function formatDateForInput(value) {
  if (!value) return ''
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return ''
  return parsed.toISOString().slice(0, 10)
}

function formatDateForTable(value) {
  if (!value) return '-'
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return '-'
  return parsed.toLocaleDateString()
}

function normalizeSector(value) {
  if (value === 'govt') return 'govt'
  return 'pvt'
}

function sectorLabel(value) {
  return normalizeSector(value) === 'govt' ? 'Government' : 'Private'
}

function JobsPage() {
  const { token } = getStoredSession()
  const { data: jobs, loading, error, refresh } = useApiData('/api/jobs', { useToken: false })
  const [form, setForm] = useState(initialForm)
  const [editingId, setEditingId] = useState('')
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState('')
  const [activeFilter, setActiveFilter] = useState('all')

  const isEditing = useMemo(() => Boolean(editingId), [editingId])

  const filteredJobs = useMemo(() => {
    if (activeFilter === 'all') return jobs
    return jobs.filter((item) => normalizeSector(item.sector) === activeFilter)
  }, [jobs, activeFilter])

  const handleSubmit = async (event) => {
    event.preventDefault()
    if (!form.title.trim() || !form.organisationName.trim() || !form.postName.trim()) return

    const noOfVacancies = Number(form.noOfVacancies)
    if (!Number.isInteger(noOfVacancies) || noOfVacancies <= 0) {
      setMessage('Number of vacancies must be a positive whole number')
      return
    }

    const lastDate = new Date(form.lastDateToApply)
    if (!form.lastDateToApply || Number.isNaN(lastDate.getTime())) {
      setMessage('Please provide a valid last date to apply')
      return
    }

    setSaving(true)
    setMessage('')

    const payload = {
      title: form.title.trim(),
      organisationName: form.organisationName.trim(),
      postName: form.postName.trim(),
      noOfVacancies,
      qualificationNeeded: form.qualificationNeeded.trim(),
      lastDateToApply: lastDate.toISOString(),
      linkToApply: form.linkToApply.trim(),
      sector: normalizeSector(form.sector),
    }

    try {
      if (isEditing) {
        await apiRequest(`/api/jobs/${editingId}`, {
          token,
          method: 'PUT',
          body: payload,
        })
        setMessage('Job updated successfully')
      } else {
        await apiRequest('/api/jobs', {
          token,
          method: 'POST',
          body: payload,
        })
        setMessage('Job created successfully')
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
      title: item.title || '',
      organisationName: item.organisationName || '',
      postName: item.postName || '',
      noOfVacancies: String(item.noOfVacancies || ''),
      qualificationNeeded: item.qualificationNeeded || '',
      lastDateToApply: formatDateForInput(item.lastDateToApply),
      linkToApply: item.linkToApply || '',
      sector: normalizeSector(item.sector),
    })
    setMessage('')
  }

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this job listing?')) return
    setMessage('')
    try {
      await apiRequest(`/api/jobs/${id}`, { token, method: 'DELETE' })
      if (editingId === id) {
        setEditingId('')
        setForm(initialForm)
      }
      setMessage('Job deleted successfully')
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const resetForm = () => {
    setForm(initialForm)
    setEditingId('')
    setMessage('')
  }

  return (
    <section className="card">
      <PageHeader title="Jobs" description="Manage government and private jobs shown in app listings" />

      <form className="grid-form two-cols" onSubmit={handleSubmit}>
        <input
          placeholder="Job title"
          value={form.title}
          onChange={(event) => setForm((prev) => ({ ...prev, title: event.target.value }))}
          required
        />
        <input
          placeholder="Organisation name"
          value={form.organisationName}
          onChange={(event) => setForm((prev) => ({ ...prev, organisationName: event.target.value }))}
          required
        />
        <input
          placeholder="Post name"
          value={form.postName}
          onChange={(event) => setForm((prev) => ({ ...prev, postName: event.target.value }))}
          required
        />
        <input
          type="number"
          min={1}
          placeholder="No. of vacancies"
          value={form.noOfVacancies}
          onChange={(event) => setForm((prev) => ({ ...prev, noOfVacancies: event.target.value }))}
          required
        />
        <textarea
          placeholder="Qualification needed"
          value={form.qualificationNeeded}
          onChange={(event) => setForm((prev) => ({ ...prev, qualificationNeeded: event.target.value }))}
          required
        />
        <input
          type="date"
          value={form.lastDateToApply}
          onChange={(event) => setForm((prev) => ({ ...prev, lastDateToApply: event.target.value }))}
          required
        />
        <input
          type="url"
          placeholder="Application link"
          value={form.linkToApply}
          onChange={(event) => setForm((prev) => ({ ...prev, linkToApply: event.target.value }))}
          required
        />
        <select
          value={form.sector}
          onChange={(event) => setForm((prev) => ({ ...prev, sector: event.target.value }))}
          required
        >
          <option value="govt">Government</option>
          <option value="pvt">Private</option>
        </select>
        <div className="form-actions">
          <button className="btn" type="submit" disabled={saving}>
            {saving ? 'Saving...' : isEditing ? 'Update Job' : 'Add Job'}
          </button>
          <button type="button" className="btn btn-secondary" onClick={resetForm}>
            Clear
          </button>
        </div>
      </form>

      <div className="jobs-filter-buttons">
        <button
          type="button"
          className={activeFilter === 'all' ? 'btn btn-secondary btn-active' : 'btn btn-secondary'}
          onClick={() => setActiveFilter('all')}
        >
          All Jobs
        </button>
        <button
          type="button"
          className={activeFilter === 'govt' ? 'btn btn-secondary btn-active' : 'btn btn-secondary'}
          onClick={() => setActiveFilter('govt')}
        >
          Government Jobs
        </button>
        <button
          type="button"
          className={activeFilter === 'pvt' ? 'btn btn-secondary btn-active' : 'btn btn-secondary'}
          onClick={() => setActiveFilter('pvt')}
        >
          Private Jobs
        </button>
      </div>

      {message && <p className="muted">{message}</p>}
      {error && <p className="error-text">{error}</p>}

      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Title</th>
              <th>Organisation</th>
              <th>Post</th>
              <th>Vacancies</th>
              <th>Qualification</th>
              <th>Sector</th>
              <th>Last Date</th>
              <th>Apply Link</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={9}>Loading jobs...</td>
              </tr>
            )}
            {!loading &&
              filteredJobs.map((item) => (
                <tr key={item._id}>
                  <td>{item.title}</td>
                  <td>{item.organisationName}</td>
                  <td>{item.postName}</td>
                  <td>{item.noOfVacancies}</td>
                  <td>{item.qualificationNeeded}</td>
                  <td>{sectorLabel(item.sector)}</td>
                  <td>{formatDateForTable(item.lastDateToApply)}</td>
                  <td className="truncate">{item.linkToApply}</td>
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
            {!loading && !filteredJobs.length && (
              <tr>
                <td colSpan={9} className="muted">
                  No jobs found for selected filter
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </section>
  )
}

export default JobsPage

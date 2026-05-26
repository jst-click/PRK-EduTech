import { useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import DetailsModal from '../components/common/DetailsModal'
import { useApiData } from '../hooks/useApiData'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'
import { truncateWords } from '../utils/text'

const initialForm = {
  title: '',
  courseId: '',
  duration: '',
  instructorName: '',
  language: 'English',
  access: 'online',
  startDate: '',
  endDate: '',
  about: '',
  keyFeatures: '',
  isFree: 'false',
  price: '0',
  difficulty: 'Beginner',
  thumbnail: null,
}

function CoursesPage() {
  const { token } = getStoredSession()
  const { data: courses, loading, error, refresh } = useApiData('/api/courses')
  const [form, setForm] = useState(initialForm)
  const [showAddForm, setShowAddForm] = useState(false)
  const [message, setMessage] = useState('')
  const [selectedCourse, setSelectedCourse] = useState(null)
  const [updatingCourseId, setUpdatingCourseId] = useState('')

  const isTopCourseEnabled = (course) => {
    if (typeof course?.topCourseEnabled === 'boolean') return course.topCourseEnabled
    if (typeof course?.topCourse === 'boolean') return course.topCourse
    return false
  }

  const submitCourse = async (event) => {
    event.preventDefault()
    const data = new FormData()
    Object.entries(form).forEach(([key, value]) => {
      if (key === 'thumbnail') {
        if (value) data.append('thumbnail', value)
      } else if (key === 'keyFeatures') {
        const features = value
          .split(',')
          .map((feature) => feature.trim())
          .filter(Boolean)
        data.append('keyFeatures', JSON.stringify(features))
      } else {
        data.append(key, value)
      }
    })

    setMessage('')
    try {
      await apiRequest('/api/courses', {
        token,
        method: 'POST',
        body: data,
        isFormData: true,
      })
      setMessage('Course created')
      setForm(initialForm)
      setShowAddForm(false)
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const deleteCourse = async (id) => {
    if (!window.confirm('Delete this course?')) return
    try {
      await apiRequest(`/api/courses/${id}`, { token, method: 'DELETE' })
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    }
  }

  const toggleTopCourseStatus = async (course) => {
    const nextStatus = !isTopCourseEnabled(course)
    setUpdatingCourseId(course._id)
    setMessage('')
    try {
      await apiRequest(`/api/courses/${course._id}`, {
        token,
        method: 'PUT',
        body: {
          topCourseEnabled: nextStatus,
        },
      })
      setMessage(nextStatus ? 'Course enabled for Top Courses' : 'Course removed from Top Courses')
      refresh()
    } catch (requestError) {
      setMessage(requestError.message)
    } finally {
      setUpdatingCourseId('')
    }
  }

  return (
    <section className="card">
      <PageHeader
        title="Courses"
        description="Manage all courses available in app"
        action={
          <button type="button" className="btn" onClick={() => setShowAddForm((prev) => !prev)}>
            {showAddForm ? 'Close Form' : 'Add Course'}
          </button>
        }
      />
      {showAddForm && (
        <form className="grid-form two-cols" onSubmit={submitCourse}>
          <input
            placeholder="Title"
            value={form.title}
            onChange={(event) => setForm((prev) => ({ ...prev, title: event.target.value }))}
            required
          />
          <input
            placeholder="Course ID"
            value={form.courseId}
            onChange={(event) => setForm((prev) => ({ ...prev, courseId: event.target.value }))}
            required
          />
          <input
            placeholder="Duration"
            value={form.duration}
            onChange={(event) => setForm((prev) => ({ ...prev, duration: event.target.value }))}
            required
          />
          <input
            placeholder="Instructor"
            value={form.instructorName}
            onChange={(event) => setForm((prev) => ({ ...prev, instructorName: event.target.value }))}
            required
          />
          <input
            placeholder="Language"
            value={form.language}
            onChange={(event) => setForm((prev) => ({ ...prev, language: event.target.value }))}
            required
          />
          <select
            value={form.access}
            onChange={(event) => setForm((prev) => ({ ...prev, access: event.target.value }))}
          >
            <option value="online">Online</option>
            <option value="offline">Offline</option>
            <option value="both">Both</option>
          </select>
          <label>
            <span>Start date</span>
            <input
              type="date"
              value={form.startDate}
              onChange={(event) => setForm((prev) => ({ ...prev, startDate: event.target.value }))}
              required
            />
          </label>
          <label>
            <span>End date</span>
            <input
              type="date"
              value={form.endDate}
              onChange={(event) => setForm((prev) => ({ ...prev, endDate: event.target.value }))}
              required
            />
          </label>
          <input
            placeholder="Key features (comma separated)"
            value={form.keyFeatures}
            onChange={(event) => setForm((prev) => ({ ...prev, keyFeatures: event.target.value }))}
          />
          <select
            value={form.difficulty}
            onChange={(event) => setForm((prev) => ({ ...prev, difficulty: event.target.value }))}
          >
            <option>Beginner</option>
            <option>Intermediate</option>
            <option>Advanced</option>
          </select>
          <select
            value={form.isFree}
            onChange={(event) => setForm((prev) => ({ ...prev, isFree: event.target.value }))}
          >
            <option value="false">Paid Course</option>
            <option value="true">Free Course</option>
          </select>
          <input
            type="number"
            min="0"
            value={form.price}
            onChange={(event) => setForm((prev) => ({ ...prev, price: event.target.value }))}
            placeholder="Price"
          />
          <textarea
            placeholder="About course"
            value={form.about}
            onChange={(event) => setForm((prev) => ({ ...prev, about: event.target.value }))}
            required
          />
          <label>
            <span>Thumbnail</span>
            <input
              type="file"
              accept="image/*"
              onChange={(event) =>
                setForm((prev) => ({
                  ...prev,
                  thumbnail: event.target.files && event.target.files[0] ? event.target.files[0] : null,
                }))
              }
            />
          </label>
          <div className="form-actions">
            <button className="btn" type="submit">
              Save Course
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
              <th>Course ID</th>
              <th>Instructor</th>
              <th>Description</th>
              <th>Price</th>
              <th>Toggle</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={8}>Loading courses...</td>
              </tr>
            )}
            {!loading &&
              courses.map((course) => (
                <tr key={course._id}>
                  {(() => {
                    const enabled = isTopCourseEnabled(course)
                    const isUpdating = updatingCourseId === course._id
                    return (
                      <>
                  <td>{course.title}</td>
                  <td>{course.courseId}</td>
                  <td>{course.instructorName}</td>
                  <td>{truncateWords(course.about, 12)}</td>
                  <td>{course.isFree ? 'Free' : `INR ${course.price || 0}`}</td>
                  <td>
                    <label className="toggle-switch">
                      <input
                        type="checkbox"
                        checked={enabled}
                        onChange={() => toggleTopCourseStatus(course)}
                        disabled={isUpdating}
                      />
                      <span className="toggle-slider" />
                    </label>
                  </td>
                  <td>
                    <span className={`status-pill ${enabled ? 'status-pill-enabled' : 'status-pill-disabled'}`}>
                      {enabled ? 'Enabled' : 'Disabled'}
                    </span>
                  </td>
                  <td>
                    <div className="row-actions">
                      <button
                        type="button"
                        className="btn btn-secondary"
                        onClick={() => setSelectedCourse(course)}
                      >
                        View
                      </button>
                      <button
                        type="button"
                        className="btn btn-danger"
                        onClick={() => deleteCourse(course._id)}
                      >
                        Delete
                      </button>
                    </div>
                  </td>
                      </>
                    )
                  })()}
                </tr>
              ))}
          </tbody>
        </table>
      </div>
      <DetailsModal
        title="Course Details"
        details={
          selectedCourse
            ? [
                { label: 'Title', value: selectedCourse.title },
                { label: 'Course ID', value: selectedCourse.courseId },
                { label: 'Instructor', value: selectedCourse.instructorName },
                { label: 'Language', value: selectedCourse.language },
                { label: 'Access', value: selectedCourse.access },
                { label: 'Duration', value: selectedCourse.duration },
                { label: 'Description', value: selectedCourse.about || '-' },
                {
                  label: 'Top Course Status',
                  value: isTopCourseEnabled(selectedCourse) ? 'Enabled' : 'Disabled',
                },
                {
                  label: 'Key Features',
                  value: Array.isArray(selectedCourse.keyFeatures)
                    ? selectedCourse.keyFeatures.join(', ')
                    : selectedCourse.keyFeatures || '-',
                },
                { label: 'Price', value: selectedCourse.isFree ? 'Free' : `INR ${selectedCourse.price || 0}` },
              ]
            : null
        }
        onClose={() => setSelectedCourse(null)}
      />
    </section>
  )
}

export default CoursesPage

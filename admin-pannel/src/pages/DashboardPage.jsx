import { useEffect, useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

function DashboardPage() {
  const [stats, setStats] = useState([])
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const load = async () => {
      setLoading(true)
      setError('')
      try {
        const { token } = getStoredSession()
        const [courses, batches, tests, ebooks, carousel] = await Promise.all([
          apiRequest('/api/courses', { token }),
          apiRequest('/api/batches', { token }),
          apiRequest('/api/tests'),
          apiRequest('/api/ebooks'),
          apiRequest('/api/carouselImages/withIds'),
        ])

        setStats([
          { label: 'Courses', value: courses.length, color: 'blue' },
          { label: 'Batches', value: batches.length, color: 'green' },
          { label: 'Tests', value: tests.length, color: 'purple' },
          { label: 'Ebooks', value: ebooks.length, color: 'orange' },
          { label: 'Carousel Images', value: carousel.length, color: 'pink' },
        ])
      } catch (requestError) {
        setError(requestError.message)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  return (
    <section className="card">
      <PageHeader title="Dashboard" description="Quick status of all major backend modules" />
      {loading && <p className="muted">Loading analytics...</p>}
      {error && <p className="error-text">{error}</p>}
      <div className="stats-grid">
        {stats.map((item) => (
          <article key={item.label} className={`stat-card stat-${item.color}`}>
            <p>{item.label}</p>
            <strong>{item.value}</strong>
          </article>
        ))}
      </div>
    </section>
  )
}

export default DashboardPage

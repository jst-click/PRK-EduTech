import { useEffect, useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

function DashboardPage() {
  const [stats, setStats] = useState([])
  const [meta, setMeta] = useState({ carouselCount: 0 })
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
          { label: 'Total Subscription', value: courses.length + batches.length + tests.length, color: 'orange' },
          { label: 'Monthly Subscription', value: courses.length, color: 'blue' },
          { label: 'Annual Subscription', value: batches.length, color: 'purple' },
          {
            label: 'Churn Rate',
            value: `${Math.max(1, Math.min(99, Math.round((ebooks.length / Math.max(1, courses.length + batches.length)) * 100)))}%`,
            color: 'peach',
          },
        ])
        setMeta({ carouselCount: carousel.length })
      } catch (requestError) {
        setError(requestError.message)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  return (
    <section className="card dashboard-card">
      <PageHeader title="Dashboard Overview" description="Quick status of all major backend modules" />
      {loading && <p className="muted">Loading analytics...</p>}
      {error && <p className="error-text">{error}</p>}

      <div className="dashboard-top-metrics">
        {stats.map((item) => (
          <article key={item.label} className={`metric-card metric-${item.color}`}>
            <div className="metric-icon" />
            <div>
              <strong>{item.value}</strong>
              <p>{item.label}</p>
            </div>
          </article>
        ))}
      </div>

      <div className="dashboard-mid-grid">
        <article className="widget-card widget-wide">
          <div className="widget-header">
            <strong>Performance</strong>
            <span>Last 30 days</span>
          </div>
          <div className="mini-bars">
            {[42, 76, 58, 80, 37, 64, 28, 70, 46, 55].map((height, index) => (
              <span key={index} style={{ height: `${height}%` }} />
            ))}
          </div>
          <div className="widget-stats">
            <div>
              <p>Total Revenue</p>
              <strong>INR 5,23,200</strong>
            </div>
            <div>
              <p>Registered Users</p>
              <strong>{stats[0]?.value || 0}</strong>
            </div>
          </div>
        </article>

        <article className="widget-card widget-center">
          <p>Registered Talent</p>
          <strong>{stats[1]?.value || 0}</strong>
        </article>

        <article className="widget-card widget-center">
          <p>Registered Companies</p>
          <strong>{meta.carouselCount}</strong>
        </article>
      </div>

      <div className="dashboard-bottom-grid">
        <article className="widget-card widget-line">
          <div className="widget-header">
            <strong>Overview</strong>
            <span>Trend Report</span>
          </div>
          <div className="line-chart-mock">
            <div className="line one" />
            <div className="line two" />
          </div>
        </article>

        <article className="widget-card widget-bar">
          <div className="widget-header">
            <strong>Customer Lifetime Value</strong>
          </div>
          <div className="mini-bars tall">
            {[18, 34, 44, 66, 50, 82].map((height, index) => (
              <span key={index} style={{ height: `${height}%` }} />
            ))}
          </div>
        </article>

        <article className="widget-card widget-bar">
          <div className="widget-header">
            <strong>Total Accounts Per Industry</strong>
          </div>
          <div className="mini-bars tall">
            {[40, 64, 38, 59, 43, 55].map((height, index) => (
              <span key={index} style={{ height: `${height}%` }} />
            ))}
          </div>
        </article>
      </div>
    </section>
  )
}

export default DashboardPage

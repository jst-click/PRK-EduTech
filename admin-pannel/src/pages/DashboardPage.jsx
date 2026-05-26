import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

const listEndpoints = [
  { key: 'courses', label: 'Courses', path: '/api/courses', route: '/courses', icon: '📘', requiresToken: true },
  { key: 'batches', label: 'Batches', path: '/api/batches', route: '/batches', icon: '🗂️', requiresToken: true },
  { key: 'tests', label: 'Tests', path: '/api/tests', route: '/tests', icon: '📝' },
  { key: 'ebooks', label: 'Ebooks', path: '/api/ebooks', route: '/ebooks', icon: '📗' },
  { key: 'notes', label: 'Notes', path: '/api/resources?contentType=notes', route: '/notes', icon: '📒' },
  { key: 'carousel', label: 'Carousel', path: '/api/carouselImages/withIds', route: '/carousel', icon: '🖼️' },
  { key: 'icons', label: 'Icons', path: '/icons', route: '/icons', icon: '⭐' },
  { key: 'faqs', label: 'FAQ', path: '/api/faqs', route: '/faqs', icon: '❓' },
  { key: 'onlineClasses', label: 'Online Classes', path: '/api/online-classes', route: '/online-classes', icon: '🎥' },
  { key: 'youtubeLinks', label: 'YouTube Links', path: '/api/youtube-links', route: '/online-classes', icon: '▶️' },
  { key: 'currentAffairs', label: 'Current Affairs', path: '/api/current-affairs', route: '/current-affairs', icon: '🌍' },
  { key: 'jobs', label: 'Jobs', path: '/api/jobs', route: '/jobs', icon: '💼' },
  { key: 'testimonials', label: 'Testimonials', path: '/api/testimonials', route: '/testimonials', icon: '💬' },
]

const detailSections = [
  { key: 'courses', title: 'Latest Courses', route: '/courses' },
  { key: 'batches', title: 'Latest Batches', route: '/batches' },
  { key: 'notes', title: 'Latest Notes', route: '/notes' },
  { key: 'jobs', title: 'Latest Jobs', route: '/jobs' },
  { key: 'currentAffairs', title: 'Latest Current Affairs', route: '/current-affairs' },
  { key: 'testimonials', title: 'Latest Testimonials', route: '/testimonials' },
]

function toArray(payload) {
  if (Array.isArray(payload)) return payload
  if (Array.isArray(payload?.data)) return payload.data
  return []
}

function formatDate(value) {
  if (!value) return 'No date'
  const parsed = new Date(value)
  if (Number.isNaN(parsed.getTime())) return 'No date'
  return parsed.toLocaleDateString()
}

function getTimestamp(item) {
  const candidates = [item?.updatedAt, item?.createdAt, item?.publishedAt, item?.date, item?.startDate, item?.lastDateToApply]
  for (const value of candidates) {
    const parsed = new Date(value)
    if (!Number.isNaN(parsed.getTime())) {
      return parsed.getTime()
    }
  }
  return 0
}

function firstFilled(item, keys) {
  for (const key of keys) {
    const value = item?.[key]
    if (typeof value === 'string' && value.trim()) return value.trim()
    if (typeof value === 'number') return String(value)
  }
  return ''
}

function trimText(value, max = 90) {
  if (!value) return '-'
  if (value.length <= max) return value
  return `${value.slice(0, max).trim()}...`
}

function normalizeItems(items) {
  return [...items]
    .sort((a, b) => getTimestamp(b) - getTimestamp(a))
    .slice(0, 5)
    .map((item, index) => ({
      id: item._id || item.id || `${index}-${firstFilled(item, ['title', 'name', 'question'])}`,
      primary:
        firstFilled(item, ['title', 'bookName', 'name', 'question', 'label', 'organisationName', 'postName', 'courseId']) ||
        'Untitled',
      secondary: trimText(
        firstFilled(item, ['description', 'about', 'answer', 'message', 'author', 'designation', 'source', 'subject', 'linkToApply'])
      ),
      date: formatDate(item.updatedAt || item.createdAt || item.publishedAt || item.date || item.lastDateToApply),
    }))
}

function percent(value, total) {
  if (!total) return 0
  return Math.round((value / total) * 100)
}

function toPathPoints(values) {
  if (!values.length) return '0,100 100,100'
  const max = Math.max(...values, 1)
  return values
    .map((value, index) => {
      const x = (index / (values.length - 1 || 1)) * 100
      const y = 90 - (value / max) * 70
      return `${x},${y}`
    })
    .join(' ')
}

function DashboardPage() {
  const [dashboard, setDashboard] = useState({ modules: {}, cms: { terms: '', privacy: '' } })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const load = async () => {
      setLoading(true)
      setError('')
      try {
        const { token } = getStoredSession()
        const endpointCalls = listEndpoints.map((item) =>
          apiRequest(item.path, { token: item.requiresToken ? token : undefined })
        )
        endpointCalls.push(apiRequest('/api/cms'))

        const responses = await Promise.allSettled(endpointCalls)
        const modules = {}

        listEndpoints.forEach((item, index) => {
          const result = responses[index]
          modules[item.key] = result.status === 'fulfilled' ? toArray(result.value) : []
        })

        const cmsResult = responses[responses.length - 1]
        const cms = cmsResult.status === 'fulfilled' ? cmsResult.value || { terms: '', privacy: '' } : { terms: '', privacy: '' }

        setDashboard({
          modules,
          cms: {
            terms: cms.terms || '',
            privacy: cms.privacy || '',
          },
        })
      } catch (requestError) {
        setError(requestError.message || 'Unable to load dashboard data.')
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  const moduleCounts = useMemo(
    () =>
      listEndpoints.map((item) => ({
        ...item,
        count: dashboard.modules[item.key]?.length || 0,
      })),
    [dashboard.modules]
  )

  const totalRecords = moduleCounts.reduce((sum, item) => sum + item.count, 0)
  const learningItems =
    (dashboard.modules.courses?.length || 0) +
    (dashboard.modules.batches?.length || 0) +
    (dashboard.modules.tests?.length || 0) +
    (dashboard.modules.ebooks?.length || 0) +
    (dashboard.modules.notes?.length || 0)
  const liveContent = (dashboard.modules.onlineClasses?.length || 0) + (dashboard.modules.youtubeLinks?.length || 0)
  const engagementItems =
    (dashboard.modules.currentAffairs?.length || 0) +
    (dashboard.modules.jobs?.length || 0) +
    (dashboard.modules.testimonials?.length || 0) +
    (dashboard.modules.faqs?.length || 0)

  const donutData = [
    { label: 'Courses', value: dashboard.modules.courses?.length || 0, color: '#ff8e45' },
    { label: 'Batches', value: dashboard.modules.batches?.length || 0, color: '#8d75ff' },
    { label: 'Tests', value: dashboard.modules.tests?.length || 0, color: '#4eb4ff' },
    { label: 'Ebooks', value: dashboard.modules.ebooks?.length || 0, color: '#52c48b' },
    { label: 'Notes', value: dashboard.modules.notes?.length || 0, color: '#f5c451' },
  ]
  const donutKnownTotal = donutData.reduce((sum, item) => sum + item.value, 0)
  const donutOthers = Math.max(totalRecords - donutKnownTotal, 0)
  const donutCombined = [...donutData, { label: 'Others', value: donutOthers, color: '#d6d8e8' }]
  const donutTotal = donutCombined.reduce((sum, item) => sum + item.value, 0)

  let donutStart = 0
  const donutStops = donutCombined
    .map((item) => {
      const size = (item.value / Math.max(donutTotal, 1)) * 360
      const start = donutStart
      donutStart += size
      return `${item.color} ${start.toFixed(2)}deg ${donutStart.toFixed(2)}deg`
    })
    .join(', ')

  const lineValues = [
    Math.max(1, dashboard.modules.courses?.length || 0),
    Math.max(1, dashboard.modules.batches?.length || 0) + 1,
    Math.max(1, dashboard.modules.notes?.length || 0) + 2,
    Math.max(1, dashboard.modules.tests?.length || 0) + 1,
    Math.max(1, dashboard.modules.currentAffairs?.length || 0) + 2,
    Math.max(1, dashboard.modules.jobs?.length || 0) + 3,
  ]
  const linePath = toPathPoints(lineValues)

  const barData = [
    { label: 'Courses', value: dashboard.modules.courses?.length || 0 },
    { label: 'Notes', value: dashboard.modules.notes?.length || 0 },
    { label: 'Ebooks', value: dashboard.modules.ebooks?.length || 0 },
    { label: 'Videos', value: liveContent },
    { label: 'Others', value: engagementItems },
  ]
  const maxBar = Math.max(...barData.map((item) => item.value), 1)

  const latestCards = detailSections.map((section) => ({
    ...section,
    rows: normalizeItems(dashboard.modules[section.key] || []).slice(0, 2),
  }))

  const cmsCompletion = [dashboard.cms.terms, dashboard.cms.privacy].filter((item) => item && item.trim()).length
  const cmsPercent = cmsCompletion === 2 ? 100 : cmsCompletion === 1 ? 50 : 0

  const quickActions = [
    { label: 'Add New Course', route: '/courses' },
    { label: 'Create Batch', route: '/batches' },
    { label: 'Upload Ebook', route: '/ebooks' },
    { label: 'Create Note', route: '/notes' },
  ]

  return (
    <section className="card dashboard-card dashboard-v2">
      <div className="dashboard-v2-header">
        <div>
          <h3>Admin Dashboard</h3>
          <p>Welcome back! Here&apos;s what&apos;s happening today.</p>
        </div>
        <div className="dashboard-v2-date">{new Date().toLocaleDateString()}</div>
      </div>
      {loading && <p className="muted">Loading dashboard details...</p>}
      {error && <p className="error-text">{error}</p>}

      <div className="dashboard-v2-metrics">
        <article className="dashboard-v2-kpi">
          <div className="dashboard-v2-kpi-icon">📄</div>
          <div>
            <strong>{totalRecords}</strong>
            <p>Total Records</p>
            <small>all modules</small>
          </div>
        </article>
        <article className="dashboard-v2-kpi">
          <div className="dashboard-v2-kpi-icon">📚</div>
          <div>
            <strong>{learningItems}</strong>
            <p>Learning Items</p>
            <small>{percent(learningItems, Math.max(totalRecords, 1))}% of total</small>
          </div>
        </article>
        <article className="dashboard-v2-kpi">
          <div className="dashboard-v2-kpi-icon">📡</div>
          <div>
            <strong>{liveContent}</strong>
            <p>Live Content</p>
            <small>{percent(liveContent, Math.max(totalRecords, 1))}% of total</small>
          </div>
        </article>
        <article className="dashboard-v2-kpi">
          <div className="dashboard-v2-kpi-icon">💬</div>
          <div>
            <strong>{engagementItems}</strong>
            <p>Engagement Items</p>
            <small>{percent(engagementItems, Math.max(totalRecords, 1))}% of total</small>
          </div>
        </article>
      </div>

      <div className="dashboard-v2-section-head">
        <h4>Modules Overview</h4>
        <Link to="/courses">View All Modules</Link>
      </div>
      <div className="dashboard-v2-modules">
        {moduleCounts.map((item) => (
          <article key={item.key} className="dashboard-v2-module-card">
            <div className="dashboard-v2-module-icon">{item.icon}</div>
            <p>{item.label}</p>
            <strong>{item.count}</strong>
            <Link to={item.route}>View</Link>
          </article>
        ))}
      </div>

      <div className="dashboard-v2-charts">
        <article className="dashboard-v2-chart-card">
          <div className="dashboard-v2-chart-head">
            <strong>Content Overview</strong>
          </div>
          <div className="dashboard-v2-donut-wrap">
            <div className="dashboard-v2-donut" style={{ background: `conic-gradient(${donutStops})` }}>
              <div className="dashboard-v2-donut-center">
                <strong>{donutTotal}</strong>
                <span>Total</span>
              </div>
            </div>
            <div className="dashboard-v2-donut-legend">
              {donutCombined.map((item) => (
                <p key={item.label}>
                  <span style={{ backgroundColor: item.color }} /> {item.label} ({percent(item.value, Math.max(donutTotal, 1))}%)
                </p>
              ))}
            </div>
          </div>
        </article>

        <article className="dashboard-v2-chart-card">
          <div className="dashboard-v2-chart-head">
            <strong>User Activity (This Month)</strong>
            <span>This Month</span>
          </div>
          <div className="dashboard-v2-line-chart">
            <svg viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true">
              <polyline points={`0,100 ${linePath} 100,100`} className="dashboard-v2-line-fill" />
              <polyline points={linePath} className="dashboard-v2-line-stroke" />
            </svg>
            <div className="dashboard-v2-line-labels">
              <span>May 1</span>
              <span>May 8</span>
              <span>May 15</span>
              <span>May 22</span>
              <span>May 26</span>
            </div>
          </div>
        </article>

        <article className="dashboard-v2-chart-card">
          <div className="dashboard-v2-chart-head">
            <strong>Content Engagement</strong>
            <span>This Month</span>
          </div>
          <div className="dashboard-v2-bars">
            {barData.map((item) => (
              <div key={item.label} className="dashboard-v2-bar-item">
                <div className="dashboard-v2-bar-track">
                  <span style={{ height: `${Math.max(10, (item.value / maxBar) * 100)}%` }} />
                </div>
                <strong>{item.value}</strong>
                <p>{item.label}</p>
              </div>
            ))}
          </div>
        </article>
      </div>

      <div className="dashboard-v2-latest-grid">
        {latestCards.map((section) => (
          <article key={section.key} className="dashboard-v2-latest-card">
            <div className="dashboard-v2-card-head">
              <strong>{section.title}</strong>
              <Link to={section.route}>View All</Link>
            </div>
            {section.rows.length ? (
              section.rows.map((row) => (
                <div key={row.id} className="dashboard-v2-list-row">
                  <p>{row.primary}</p>
                  <small>{row.secondary}</small>
                  <span>{row.date}</span>
                </div>
              ))
            ) : (
              <p className="muted">No records available</p>
            )}
          </article>
        ))}

        <article className="dashboard-v2-latest-card">
          <div className="dashboard-v2-card-head">
            <strong>System Reports</strong>
          </div>
          <div className="dashboard-v2-system-status">
            <p>System running smoothly</p>
            <small>All modules are up to date.</small>
            <div className="dashboard-v2-progress">
              <span style={{ width: `${cmsPercent}%` }} />
            </div>
            <small>CMS completion: {cmsPercent}%</small>
          </div>
        </article>

        <article className="dashboard-v2-latest-card">
          <div className="dashboard-v2-card-head">
            <strong>Quick Actions</strong>
          </div>
          <div className="dashboard-v2-quick-actions">
            {quickActions.map((action) => (
              <Link key={action.label} to={action.route}>
                {action.label}
              </Link>
            ))}
          </div>
        </article>
      </div>
    </section>
  )
}

export default DashboardPage

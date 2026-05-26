import { Navigate, NavLink, Route, Routes } from 'react-router-dom'
import { navItems } from '../constants/navigation'
import DashboardPage from '../pages/DashboardPage'
import UsersPage from '../pages/UsersPage'
import BatchesPage from '../pages/BatchesPage'
import CoursesPage from '../pages/CoursesPage'
import CarouselPage from '../pages/CarouselPage'
import IconsPage from '../pages/IconsPage'
import EbooksPage from '../pages/EbooksPage'
import NotesPage from '../pages/NotesPage'
import TestsPage from '../pages/TestsPage'
import FaqsPage from '../pages/FaqsPage'
import OnlineClassesPage from '../pages/OnlineClassesPage'
import CurrentAffairsPage from '../pages/CurrentAffairsPage'
import JobsPage from '../pages/JobsPage'
import TestimonialsPage from '../pages/TestimonialsPage'
import CmsPage from '../pages/CmsPage'

function AdminLayout({ user, onLogout }) {
  return (
    <div className="admin-shell">
      <aside className="sidebar">
        <div className="sidebar-brand">
          <div className="sidebar-logo-wrap">
            <img src="/img/logo-removebg-preview.png" alt="PRK Edu Power logo" className="sidebar-logo" />
          </div>
        </div>
        <nav className="sidebar-nav">
          {navItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) => (isActive ? 'nav-link nav-link-active' : 'nav-link')}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
      </aside>
      <main className="main-content">
        <header className="topbar">
          <div>
            <h2>Admin Panel</h2>
            <p>Manage app content, users, and academic modules</p>
          </div>
          <div className="topbar-actions">
            <span className="admin-chip">{user?.email || 'Admin'}</span>
            <button type="button" className="btn btn-secondary" onClick={onLogout}>
              Logout
            </button>
          </div>
        </header>
        <div className="page-area">
          <Routes>
            <Route path="/dashboard" element={<DashboardPage />} />
            <Route path="/users" element={<UsersPage />} />
            <Route path="/batches" element={<BatchesPage />} />
            <Route path="/courses" element={<CoursesPage />} />
            <Route path="/carousel" element={<CarouselPage />} />
            <Route path="/icons" element={<IconsPage />} />
            <Route path="/ebooks" element={<EbooksPage />} />
            <Route path="/notes" element={<NotesPage />} />
            <Route path="/tests" element={<TestsPage />} />
            <Route path="/faqs" element={<FaqsPage />} />
            <Route path="/online-classes" element={<OnlineClassesPage />} />
            <Route path="/current-affairs" element={<CurrentAffairsPage />} />
            <Route path="/jobs" element={<JobsPage />} />
            <Route path="/testimonials" element={<TestimonialsPage />} />
            <Route path="/cms" element={<CmsPage />} />
            <Route path="*" element={<Navigate to="/dashboard" replace />} />
          </Routes>
        </div>
      </main>
    </div>
  )
}

export default AdminLayout

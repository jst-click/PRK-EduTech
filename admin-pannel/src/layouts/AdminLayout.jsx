import { Navigate, NavLink, Route, Routes } from 'react-router-dom'
import { navItems } from '../constants/navigation'
import DashboardPage from '../pages/DashboardPage'
import UsersPage from '../pages/UsersPage'
import BatchesPage from '../pages/BatchesPage'
import CoursesPage from '../pages/CoursesPage'
import CarouselPage from '../pages/CarouselPage'
import IconsPage from '../pages/IconsPage'
import EbooksPage from '../pages/EbooksPage'
import TestsPage from '../pages/TestsPage'

function AdminLayout({ user, onLogout }) {
  return (
    <div className="admin-shell">
      <aside className="sidebar">
        <div className="sidebar-brand">
          <h1>PRK Admin</h1>
          <p>React + Vite Panel</p>
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
            <Route path="/tests" element={<TestsPage />} />
            <Route path="*" element={<Navigate to="/dashboard" replace />} />
          </Routes>
        </div>
      </main>
    </div>
  )
}

export default AdminLayout

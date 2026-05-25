import { useState } from 'react'
import { Route, Routes } from 'react-router-dom'
import LoginPage from '../pages/LoginPage'
import AuthGate from '../routes/AuthGate'
import AdminLayout from '../layouts/AdminLayout'
import { clearSession, getStoredSession, saveSession } from '../services/authStorage'

function AppRouter() {
  const [session, setSession] = useState(getStoredSession)

  const onLogin = ({ token, user }) => {
    saveSession({ token, user })
    setSession({ token, user })
  }

  const onLogout = () => {
    clearSession()
    setSession({ token: '', user: null })
  }

  return (
    <Routes>
      <Route path="/login" element={<LoginPage onLogin={onLogin} initialToken={session.token} />} />
      <Route
        path="/*"
        element={
          <AuthGate token={session.token}>
            <AdminLayout user={session.user} onLogout={onLogout} />
          </AuthGate>
        }
      />
    </Routes>
  )
}

export default AppRouter

import { useCallback, useEffect, useState } from 'react'
import PageHeader from '../components/common/PageHeader'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

function UsersPage() {
  const { token } = getStoredSession()
  const [query, setQuery] = useState('a')
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [message, setMessage] = useState('')

  const searchUsers = useCallback(async () => {
    if (!query.trim()) return
    setLoading(true)
    setError('')
    setMessage('')
    try {
      const data = await apiRequest(`/api/search/users?query=${encodeURIComponent(query)}`, { token })
      setUsers(data)
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setLoading(false)
    }
  }, [query, token])

  useEffect(() => {
    const timer = setTimeout(() => {
      searchUsers()
    }, 0)
    return () => clearTimeout(timer)
  }, [searchUsers])

  const handleResetPassword = async (userId) => {
    setMessage('')
    setError('')
    try {
      const response = await apiRequest(`/api/users/${userId}/reset-password`, {
        token,
        method: 'POST',
      })
      setMessage(response.message || 'Password reset email sent')
    } catch (requestError) {
      setError(requestError.message)
    }
  }

  const handleDeleteUser = async (userId) => {
    if (!window.confirm('Delete this user?')) return
    setMessage('')
    setError('')
    try {
      await apiRequest(`/api/users/${userId}`, { token, method: 'DELETE' })
      setUsers((prev) => prev.filter((user) => user._id !== userId))
      setMessage('User deleted')
    } catch (requestError) {
      setError(requestError.message)
    }
  }

  return (
    <section className="card">
      <PageHeader
        title="Users"
        description="Search users and run admin actions"
        action={
          <div className="inline-tools">
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search users..."
            />
            <button className="btn" type="button" onClick={searchUsers} disabled={loading}>
              {loading ? 'Searching...' : 'Search'}
            </button>
          </div>
        }
      />
      {error && <p className="error-text">{error}</p>}
      {message && <p className="success-text">{message}</p>}
      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Phone</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.map((user) => (
              <tr key={user._id}>
                <td>{user.name}</td>
                <td>{user.email}</td>
                <td>{user.phone}</td>
                <td>
                  <div className="row-actions">
                    <button
                      type="button"
                      className="btn btn-secondary"
                      onClick={() => handleResetPassword(user._id)}
                    >
                      Reset Password
                    </button>
                    <button
                      type="button"
                      className="btn btn-danger"
                      onClick={() => handleDeleteUser(user._id)}
                    >
                      Delete
                    </button>
                  </div>
                </td>
              </tr>
            ))}
            {!users.length && (
              <tr>
                <td colSpan={4} className="muted">
                  No users found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </section>
  )
}

export default UsersPage

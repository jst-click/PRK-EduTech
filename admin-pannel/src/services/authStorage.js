const AUTH_TOKEN_KEY = 'adminPanelToken'
const AUTH_USER_KEY = 'adminPanelUser'

export function getStoredSession() {
  const token = localStorage.getItem(AUTH_TOKEN_KEY)
  const rawUser = localStorage.getItem(AUTH_USER_KEY)
  const user = rawUser ? JSON.parse(rawUser) : null
  return { token, user }
}

export function saveSession({ token, user }) {
  localStorage.setItem(AUTH_TOKEN_KEY, token)
  localStorage.setItem(AUTH_USER_KEY, JSON.stringify(user))
}

export function clearSession() {
  localStorage.removeItem(AUTH_TOKEN_KEY)
  localStorage.removeItem(AUTH_USER_KEY)
}

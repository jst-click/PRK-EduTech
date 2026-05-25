import { API_BASE_URL } from '../config/env'

function buildApiUrl(path) {
  const safeBase = API_BASE_URL.replace(/\/+$/, '')
  const safePath = String(path || '').replace(/^\/+/, '')
  return `${safeBase}/${safePath}`
}

export async function apiRequest(path, { token, method = 'GET', body, isFormData = false } = {}) {
  const headers = {}

  if (!isFormData) {
    headers['Content-Type'] = 'application/json'
  }

  if (token) {
    headers.Authorization = `Bearer ${token}`
  }

  const response = await fetch(buildApiUrl(path), {
    method,
    headers,
    body: body ? (isFormData ? body : JSON.stringify(body)) : undefined,
  })

  const payload = await response.json().catch(() => ({}))
  if (!response.ok) {
    throw new Error(payload?.message || 'Request failed')
  }

  return payload
}

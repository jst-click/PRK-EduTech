import { useCallback, useEffect, useState } from 'react'
import { getStoredSession } from '../services/authStorage'
import { apiRequest } from '../services/apiClient'

export function useApiData(path, { useToken = true, transform } = {}) {
  const [data, setData] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const refresh = useCallback(async () => {
    setLoading(true)
    setError('')
    try {
      const { token } = getStoredSession()
      const response = await apiRequest(path, { token: useToken ? token : undefined })
      setData(transform ? transform(response) : response)
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setLoading(false)
    }
  }, [path, transform, useToken])

  useEffect(() => {
    const timer = setTimeout(() => {
      refresh()
    }, 0)
    return () => clearTimeout(timer)
  }, [refresh])

  return { data, setData, loading, error, refresh }
}

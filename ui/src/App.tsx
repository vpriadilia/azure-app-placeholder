import { useState } from 'react'
import './App.css'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? ''

type StatusResponse = {
  message: string
  server: string
  timestampUtc: string
}

type RequestState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: StatusResponse }
  | { status: 'error'; error: string }

function App() {
  const [state, setState] = useState<RequestState>({ status: 'idle' })

  const checkConnection = async () => {
    setState({ status: 'loading' })
    try {
      const response = await fetch(`${API_BASE_URL}/api/status`)
      if (!response.ok) {
        throw new Error(`Request failed with status ${response.status}`)
      }
      const data: StatusResponse = await response.json()
      setState({ status: 'success', data })
    } catch (err) {
      setState({
        status: 'error',
        error: err instanceof Error ? err.message : 'Something went wrong',
      })
    }
  }

  return (
    <main className="app">
      <h1>Azure App Placeholder</h1>
      <p className="subtitle">React UI &rarr; .NET API</p>

      <button
        type="button"
        className="check-button"
        onClick={checkConnection}
        disabled={state.status === 'loading'}
      >
        {state.status === 'loading' ? 'Checking...' : 'Check connection'}
      </button>

      {state.status === 'success' && (
        <div className="result success">
          <p>{state.data.message}</p>
          <p className="meta">
            server: {state.data.server} · {new Date(state.data.timestampUtc).toLocaleString()}
          </p>
        </div>
      )}

      {state.status === 'error' && (
        <div className="result error">
          <p>Could not reach the API.</p>
          <p className="meta">{state.error}</p>
        </div>
      )}
    </main>
  )
}

export default App

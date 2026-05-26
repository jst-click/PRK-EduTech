function DetailsModal({ title, details, onClose }) {
  if (!details) return null

  return (
    <div className="details-modal-overlay" role="presentation" onClick={onClose}>
      <section
        className="details-modal-card"
        role="dialog"
        aria-modal="true"
        aria-label={title || 'Details'}
        onClick={(event) => event.stopPropagation()}
      >
        <header className="details-modal-header">
          <h4>{title || 'Details'}</h4>
          <button type="button" className="btn btn-secondary" onClick={onClose}>
            Close
          </button>
        </header>
        <div className="details-modal-body">
          {details.map((entry) => (
            <article className="details-row" key={entry.label}>
              <strong>{entry.label}</strong>
              <div className="details-value">{entry.value ?? '-'}</div>
            </article>
          ))}
        </div>
      </section>
    </div>
  )
}

export default DetailsModal

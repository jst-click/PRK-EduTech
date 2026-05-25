function PageHeader({ title, description, action }) {
  return (
    <div className="page-header">
      <div>
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
      {action}
    </div>
  )
}

export default PageHeader

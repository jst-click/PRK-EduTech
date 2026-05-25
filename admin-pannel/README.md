# PRK Admin Panel

Responsive React + Vite admin panel for:

- Admin login from backend `.env` credentials (`ADMIN_EMAIL`, `ADMIN_PASSWORD`)
- Dashboard metrics
- User management (search, reset password, delete)
- Batches and courses
- Carousel and icons
- Ebooks and tests

## Setup

1. Create `.env.local` in this folder.
2. Add base URL:

```bash
VITE_API_BASE_URL=http://localhost:5000
```

3. Install dependencies:
```bash
npm install
```

4. Start dev server:

```bash
npm run dev
```

## Backend requirement

Use the updated backend route:

- `POST /api/admin/login`

with payload:

```json
{
  "email": "admin@prkedutech.com",
  "password": "admin123"
}
```

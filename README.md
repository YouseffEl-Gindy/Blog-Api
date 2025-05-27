# Blog API

## How to run

1. Run `docker compose up --build`
2. The app will be accessible on http://localhost:3000
3. Run tests: `docker compose exec web rails test`

## Features

- JWT authentication
- Posts, Comments, Tags
- Token blacklisting on logout
- Auto-delete posts after 24h using Sidekiq and Redis

# Menta Finance - Admin Panel

Flutter Web admin panel ya **Menta Finance** (mfumo wa fedha wa Menta Studio),
inayoongea na `menta-finance-backend` (Spring Boot) kupitia REST API.

## Kuanzisha (Development)

Hakikisha backend (`menta-finance-backend`) inaendeshwa kwanza kwenye
`http://localhost:8080`, kisha:

```bash
flutter pub get
flutter run -d chrome --web-port=3000
```

Port 3000 inatakiwa kwa sababu backend (CORS) inaruhusu `http://localhost:3000`
kwa default (angalia `CORS_ALLOWED_ORIGINS` upande wa backend ukitaka kubadilisha).

## Kubadilisha Backend URL

Kwa default, app inaongea na `http://localhost:8080`. Kubadilisha (mfano
kwa production):

```bash
flutter build web --dart-define=API_BASE_URL=https://api.mentastudio.co.tz
```

## Muundo

- `lib/app/core` - mambo ya msingi: network (ApiClient), storage, routes,
  theme, widgets za pamoja (Sidebar, Topbar, DataTableCard, n.k.)
- `lib/app/modules` - moduli, moja kwa moja na Controllers za backend:
  `auth`, `dashboard`, `clients`, `projects`, `invoices`, `income`,
  `expenses`, `services`, `team`, `reports`, `users`, `settings`.

# HapoPay API reference

The Flutter app talks to Django REST at `API_BASE_URL` (default `http://localhost:8000/api`). The machine-readable contract is [`openapi.yaml`](openapi.yaml). A Postman collection lives in `postman/collections/HapoPay API/`.

Requests use `Authorization: Bearer <access>` except login, register, and token refresh.

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/accounts/token/` | Log in. Body: `email`, `password`. Returns `access`, `refresh`, `user`. |
| POST | `/accounts/register/` | Register. Body: `email`, `password`, `full_name`, `role` (`parent` or `student`). |
| POST | `/accounts/token/refresh/` | Body: `refresh`. Returns a new `access` token. |
| POST | `/accounts/logout/` | Body: `refresh`. Blacklists the refresh token. |
| GET | `/accounts/me/` | Current user profile. |
| GET | `/rewards/{studentId}/` | Points, tier, streak, achievements. |
| POST | `/rewards/{studentId}/claim/` | Body: `achievement_id`. Returns the updated reward state. |
| GET | `/student/account/{studentId}/` | Balance, `daily_limit`, `today_spent`, transactions. |
| PATCH | `/student/account/{studentId}/` | Body: `daily_limit`. `0` locks the card. |
| POST | `/payments/process/` | Body: `student_id`, `qr_payload` (JSON string with `amount` and `description`). `400` when funds, the lock, or the daily limit block the payment. |
| GET | `/parent/dashboard/` | Family balance, children, spend mix, recent transactions. |
| GET | `/parent/ledger/` | Family transactions with `approved` or `flagged` status. |

## Local mock

```bash
dart run tool/mock_api_server.dart
```

That process serves the same in-memory responses the app uses when `USE_MOCK_API=true`.

## Errors

Declined payments return:

```json
{ "detail": "Transaction declined: Insufficient funds." }
```

Other decline messages cover an invalid QR payload, a zero amount, a locked card, and a daily limit.

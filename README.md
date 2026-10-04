# SIMS Mobile

Flutter client for the **SIMS** Spring Boot backend.

## Prerequisites
- Flutter 3.13+ / Dart 3.0+
- Running Spring Boot backend at `http://localhost:8080`
- Android Studio / Xcode

## Setup

1. `flutter pub get`
2. Ensure the backend is running (`swagger-ui.html` reachable)
3. Android: `android/app/src/main/AndroidManifest.xml` should include
   `android:usesCleartextTraffic="true"` inside `<application>`.
   iOS Simulator can use `localhost` directly.
4. Run: `flutter run`

## Test credentials
- Email: `admin@sims.com`
- Password: `admin123`

## Configuration
Edit `lib/core/constants/api_endpoints.dart`:
- `baseUrl` — for a physical device use your PC's LAN IP (e.g. `http://192.168.1.20:8080`)
- `wsUrl`   — matching WebSocket URL (`ws://192.168.1.20:8080/ws`)

## Features
- Animated splash (fade + scale, 2.2s)
- JWT login with secure storage + remember-me
- Dashboard with gradient stat cards, line & bar charts
- Products CRUD (search, filter, swipe delete, add)
- Barcode scanner → SKU lookup → quick stock adjust
- Sales list with detail + refund (admin/manager)
- Real-time STOMP updates on `/topic/stock-updates`
- Material 3 indigo theme, dark mode toggle

## Notes
- The backend `/api/v1/reports/*` endpoints are read defensively — the
  models use fallbacks (e.g. `totalProducts | productCount`) so they work
  with either naming convention.
- If a specific endpoint returns a different shape, update the
  corresponding `fromJson` in `lib/models/`.
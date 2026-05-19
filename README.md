<div align="center">
  <h1>🍲 Food Aid</h1>
  <p>A production-grade, real-time food donation and distribution platform.</p>

  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com/)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
</div>

## 📖 Overview

**Food Aid** is an advanced Flutter application built to bridge the gap between food surplus and food scarcity. It seamlessly connects **Donors** (restaurants, individuals, event organizers), **NGOs** (food banks, shelters), and **Logistics Partners** (volunteer drivers, delivery fleets) through a unified platform to minimize food waste and optimize distribution.

🌍 **Live Web Demo:** [https://food-aid-2026.web.app](https://food-aid-2026.web.app)

---

## ✨ Key Features

### 🏢 Role-Based Ecosystem
- **Donors:** Create food donation listings, specify food types, quantity, and expiration. Track donation status and view impact history.
- **NGOs:** Browse available donations on a live map, accept relevant donations, and manage emergency food requests.
- **Logistics:** Receive optimized pickup and drop-off routes, confirm deliveries via secure OTP/QR, and manage active transport jobs.
- **Admin:** Comprehensive dashboard to oversee platform activity, manage user verifications, and monitor system health.

### 📍 Real-Time Location & Mapping
- Interactive map integration (`flutter_map`) to visualize nearby donations and NGOs.
- Forward and reverse geocoding for precise address resolution.
- Live tracking of logistics partners during active deliveries.

### 🔔 Smart Notifications & SOS
- Real-time push notifications for donation updates and delivery milestones.
- Emergency SOS request broadcasting for NGOs in critical need of supplies.

### 🎨 Premium UI/UX
- Fully responsive design optimized for Mobile (iOS/Android) and Web.
- Dynamic theme switching (Light/Dark mode).
- Fluid animations (`flutter_animate`, `lottie`) and skeleton loaders (`shimmer`) for a polished experience.

---

## 🛠️ Technology Stack

- **Frontend Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend Services:** [Firebase](https://firebase.google.com/)
  - **Authentication:** Secure Email/Password and Role-based access control.
  - **Database:** Cloud Firestore (NoSQL real-time database).
  - **Hosting:** Firebase Hosting (Web Deployment).
- **State Management:** `provider` (Multi-provider architecture).
- **Routing:** `go_router` (Declarative routing for web and mobile).
- **Maps & Location:** `flutter_map`, `geolocator`, `geocoding`, `latlong2`.

---

## 📂 Project Structure

```text
lib/
├── config/         # App-wide configurations (constants, routes, themes)
├── models/         # Data models (User, Donation, EmergencyRequest, etc.)
├── providers/      # State management (Auth, Logistics, Theme, Admin, etc.)
├── screens/        # UI Views (categorized by role: donor, ngo, logistics, admin)
├── services/       # External API integrations (Firebase, Maps, Analytics)
├── utils/          # Helper functions, formatters, and extensions
├── widgets/        # Reusable UI components
├── main.dart       # Application entry point
└── app.dart        # MaterialApp and Router configuration
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.11.1 or higher)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Code Editor (VS Code / Android Studio)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/food-aid.git
   cd food-aid
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   - Copy the `.env.example` file to `.env`.
   - Update the variables (e.g., Google Maps API Key) with your own credentials.
   ```bash
   cp .env.example .env
   ```

4. **Connect to Firebase:**
   - Make sure you have the Firebase CLI installed and logged in.
   - Run the FlutterFire CLI to configure the project for your own Firebase instance:
   ```bash
   flutterfire configure
   ```

5. **Run the Application:**
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**. 
Please refer to the [PROJECT GUIDE.md](PROJECT%20GUIDE.md) for architectural details and development guidelines.

## 🛡️ Security

If you discover any security related issues, please refer to our [Security Policy](SECURITY.md).

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

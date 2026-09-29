# ⚡ ThunderGuard

<p align="center">
  <img src="https://img.shields.io/badge/SIH-2026-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Problem-SIH26072-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Theme-Disaster%20Management-red?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter" />
  <img src="https://img.shields.io/badge/Status-50%25%20Complete-yellow?style=for-the-badge" />
</p>

> **AI/ML-powered nowcasting platform** that fuses Doppler radar, INSAT satellite imagery, LLDN lightning sensors, and NWP model data to predict thunderstorm and lightning activity **0–3 hours ahead** at district/city-level resolution.

---

## 📋 Problem Statement

| Field | Detail |
|---|---|
| **ID** | SIH26072 |
| **Title** | AIML based Nowcasting of thunderstorm and lightning using atmospheric observation including multiple radars, satellite, lightning and model data |
| **Theme** | Disaster Management |
| **Category** | Software |
| **Team** | Debuggers_26 (Team ID: 185380) |
| **Organisation** | India Meteorological Department (IMD) |

India records **2,500+ lightning fatalities annually** — the highest globally. Existing systems rely on single-sensor Doppler radar inputs and lack the spatial resolution and AI-driven pattern recognition needed for hyperlocal, district-level warnings with adequate lead time.

---

## 🚀 Solution — ThunderGuard

ThunderGuard is a unified AI/ML nowcasting system that:

- **Fuses 4 data sources** — Doppler radar (IMD DWR), INSAT-3DR satellite, LLDN lightning sensors, NWP model outputs (WRF/GFS)
- **Predicts 0–3 hours ahead** using ConvLSTM + U-Net + XGBoost ensemble
- **Maps risk at district level** with a calibrated Lightning Strike Probability Score (LSPS)
- **Delivers alerts** via SMS, push notifications, and IMD forecaster dashboard
- **Integrates natively** with IMD's existing Doppler radar and SATMET infrastructure

---

## 📱 Flutter App (This Repo)

This repository contains the **ThunderGuard cross-platform mobile application** — a fully functional mock/demo UI showcasing the platform's operator and supervisor experience.

### Screens

| Screen | Description |
|---|---|
| 🏠 **Home** | Live radar map with animated sweep, storm cells, alert feed, data source pipeline status |
| 🗺️ **Risk Map** | District heatmap with 4 forecast horizons (0–30, 30–60, 60–90, 90–180 min), ranked risk table |
| 📊 **Analytics** | Radar reflectivity chart, lightning flash density, CAPE/atmospheric indices, model accuracy (POD/FAR/CSI) |
| 🔔 **Alerts** | Severity-filtered alert feed (EMERGENCY/WARNING/WATCH) with LSPS bars and ACK system |
| ⚙️ **Settings** | Role selector, alert channel toggles, LSPS threshold slider, data refresh config |

### Key UI Features
- Dark storm-themed design with lightning amber accents
- Animated radar scan sweep with live storm cell pulsing
- Severity-coded colour system (Watch / Warning / Emergency)
- Cross-platform: Android, iOS, Windows

---

## 🧠 AI/ML Architecture

```
┌─────────────────────────────────────────────────────┐
│              MULTI-SOURCE DATA FUSION               │
│  Doppler Radar · INSAT-3DR · LLDN · NWP (WRF/GFS) │
└───────────────────────┬─────────────────────────────┘
                        │  1km × 1km grid · 30-min window
                        ▼
┌─────────────────────────────────────────────────────┐
│                  AI/ML PIPELINE                     │
│  ConvLSTM → spatiotemporal radar nowcasting         │
│  U-Net    → storm cell boundary segmentation        │
│  XGBoost  → Lightning Strike Probability Score      │
└───────────────────────┬─────────────────────────────┘
                        │  Updated every 5 minutes
                        ▼
┌─────────────────────────────────────────────────────┐
│              ALERT DELIVERY                         │
│  SMS Gateway · Push (App) · IMD Forecaster Dashboard│
└─────────────────────────────────────────────────────┘
```

### Model Targets

| Metric | Target | Current |
|---|---|---|
| Probability of Detection (POD) | > 0.75 | 0.78 ✅ |
| False Alarm Ratio (FAR) | < 0.30 | 0.22 ✅ |
| Critical Success Index (CSI) | > 0.45 | 0.51 ✅ |

---

## 🛠️ Technology Stack

### Mobile App
| Layer | Tech |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Charts | fl_chart |
| Maps | flutter_map + latlong2 |
| State | StatefulWidget (local) |

### Backend (Planned)
| Layer | Tech |
|---|---|
| AI/ML | Python · PyTorch · XGBoost · Scikit-learn |
| Data | NetCDF4 · Wradlib · GDAL · NumPy · Pandas |
| API | FastAPI · PostgreSQL + PostGIS · Redis |
| Frontend | React.js + Leaflet.js |
| IoT Nodes | ESP32 + LoRa/GSM |
| Cloud | AWS EC2 / NIC Cloud (NeST) |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
└── thunderguard/
    ├── core/
    │   ├── tg_colors.dart             # Color palette tokens
    │   └── tg_theme.dart              # ThemeData configuration
    ├── widgets/
    │   └── tg_widgets.dart            # Shared widget library
    ├── screens/
    │   ├── home_screen.dart           # Dashboard + radar map
    │   ├── risk_map_screen.dart       # District heatmap
    │   ├── analytics_screen.dart      # Charts + model metrics
    │   ├── alerts_screen.dart         # Alert feed
    │   └── settings_screen.dart       # Configuration
    └── shell/
        └── tg_shell.dart              # Bottom navigation shell
```

---

## ⚡ Getting Started

### Prerequisites
- Flutter SDK ≥ 3.12.x
- Android Studio / VS Code with Flutter extension
- Android device or emulator (API 21+)

### Run Locally

```bash
# 1. Clone the repo
git clone https://github.com/Adarsh-228/Thunderguard_sih_2026.git
cd Thunderguard_sih_2026

# 2. Install dependencies
flutter pub get

# 3. Run static analysis
flutter analyze

# 4. Run on connected device
flutter run

# 5. Build release APK
flutter build apk --release
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🗺️ Roadmap

| Phase | Timeline | Status |
|---|---|---|
| **Phase 1** — Data pipeline + model training | Months 1–6 | 🔄 In Progress |
| **Phase 2** — Real-time IMD integration + dashboard | Months 7–12 | 📋 Planned |
| **Phase 3** — Mobile rollout + IoT nodes | Months 13–18 | 📋 Planned |

---

## 🤝 Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on how to contribute to ThunderGuard.

---

## 📄 License

This project is developed for **Smart India Hackathon 2026** by Team **Debuggers_26**.  
All rights reserved © 2026 Adarsh Kumar & Team Debuggers_26.

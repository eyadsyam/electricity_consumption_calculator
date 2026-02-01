# ⚡ Electricity Consumption Calculator

A modern, production-ready Flutter application designed to track electricity readings, calculate bills based on usage tiers, and manage monthly energy budgets.

![Flutter](https://img.shields.io/badge/Flutter-3.27-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0-blue?logo=dart)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Web-lightgrey)

---

## ✨ Key Features

### 📊 tracking & Analytics
- **Smart Meter Reading:** Record daily or monthly meter readings.
- **OCR Integration:** Scan meter numbers directly using the camera (Google ML Kit).
- **Voice Input:** Add readings hands-free using voice commands.
- **Visual Charts:** Monitor consumption trends with interactive line charts.

### 💰 Financial Management
- **Tier-Based Calculation:** Automatically calculates bills based on Egyptian electricity tariffs.
- **Budget Control:** Set monthly budgets and get visual alerts when approaching limits.
- **History Log:** detailed transaction history of all past readings and bills.

### 🎨 Premium UI/UX
- **Modern Design:** Material 3 aesthetics with a custom animations engine.
- **Animations:** 15+ custom animations including staggered lists, glassmorphism, and page transitions.
- **Theming:** Full Light/Dark mode support.
- **Localization:** Complete support for **English** and **Arabic (RTL)**.

---

## 🏗️ Architecture

This project follows a strict **Clean Architecture** pattern to ensure scalability and maintainability.

```
lib/
├── core/                # Shared kernels (Animations, Widgets, Theme, Errors)
├── features/            # Business features (Domain layer)
├── screens/             # UI Presentation layer
├── services/            # Data layer (Calculation, Supabase, Local Storage)
└── config/              # App configuration (Routes, Translations)
```

**Key Technologies:**
- **State Management:** GetX
- **Local Storage:** Hive (NoSQL)
- **OCR:** Google ML Kit
- **Charts:** FL Chart

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/eyadsyam/electricity_consumption_calculator.git
   cd electricity_consumption_calculator
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run

   # For Windows
   flutter run -d windows
   ```

---

## 📱 Screenshots

| Home Screen | History | Analysis | Profile |
|:---:|:---:|:---:|:---:|
| <img src="https://via.placeholder.com/200x400?text=Home" width="200" /> | <img src="https://via.placeholder.com/200x400?text=History" width="200" /> | <img src="https://via.placeholder.com/200x400?text=Charts" width="200" /> | <img src="https://via.placeholder.com/200x400?text=Profile" width="200" /> |

*(Note: Replace placeholders with actual screenshots)*

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

# 🎨 StockCraft — Microstock AI Assistant

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-4CAF50" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License" />
  <img src="https://img.shields.io/badge/AI_Engine-FLUX.1%20%7C%20Gemini%203.7%20Flash-FF6F00" alt="AI Engine" />
  <img src="https://img.shields.io/badge/Compliance-Adobe%20Stock%20Standards-FF0000" alt="Adobe Stock" />
</p>

<p align="center">
  <strong>The Ultimate AI-Powered Contributor Tool for Adobe Stock & Microstock Marketplaces</strong><br />
  Automate market trend research, visual prompt reasoning, 4MP+ stock image generation, defect inspection, and bulk CSV metadata export — all in one unified mobile pipeline.
</p>

---

## 📖 Overview

<img width="215" height="450" alt="photo_2026-09-08_18-27-32" src="https://github.com/user-attachments/assets/56ba14db-0495-4518-921c-70e1d170e235" />  <img width="215" height="450" alt="photo_2026-09-08_18-27-56" src="https://github.com/user-attachments/assets/d5156f65-09c4-4ff1-837b-15e7080fde9d" />  <img width="215" height="450" alt="photo_2026-09-08_18-27-59" src="https://github.com/user-attachments/assets/88e876ff-5a4a-4e38-b908-2171607e8e6d" />

**StockCraft** is an end-to-end companion tool engineered for microstock contributors, designers, and prompt artists selling stock photos and illustrations on **Adobe Stock**, Shutterstock, and Freepik.

Generating acceptable commercial stock imagery requires strict technical criteria (minimum 4 Megapixels, sRGB standard, zero artifacts, no gibberish text, correct metadata). StockCraft automates this entire pipeline using a unique **2-Stage Hybrid AI Architecture**:

1. **🧠 Stage 1: Reasoning Brain (Gemini 3.7 Flash - Free Tier)**: Evaluates user intent, breaks down lighting geometry, depth of field, camera perspective, textures, and strictly enforces commercial microstock constraints.
2. **🎨 Stage 2: Visual Engine (Pollinations FLUX.1 - 100% Free)**: Renders high-fidelity, stock-grade 4.19 MP+ (2048×2048) illustrations out-of-the-box without requiring billing accounts or credit cards.

---

## ✨ Key Features

### 1. 📈 Adobe Stock Market Trends & Research
* **Curated Trending Niches**: Real-time trending styles (*3D Isometric, Clay Style, Artisan Food, Clean Vector, Paper Cutout, Cinematic Studio*).
* **21 Official Adobe Stock Categories**: Full validation against official Adobe Stock taxonomy.
* **Smart Filter & Search**: Search demand volume badges and high-yield keyword suggestions.

### 2. 🧠 2-Stage Visual Reasoning & Multi-Provider Generation
* **Reasoning Brain (Gemini 3.7 Flash)**:
  * Analyzes subject posture, anatomy, spatial relations, and ambient reflections.
  * Translates multilingual prompts (e.g. Indonesian) into diffusion-optimized commercial English prompts.
  * One-tap manual prompt expansion (`✨`) or seamless automatic reasoning before rendering.
* **Multi-Provider AI Image Engine**:
  * **Pollinations AI (FLUX.1)**: *Default & 100% Free* — No API key or registration required. Native 2048×2048 (4.19 MP) output.
  * **Hugging Face (FLUX.1-schnell)**: Free serverless inference via Hugging Face User Access Token.
  * **Google Gemini (Nano Banana 2 / gemini-3.1-flash-image)**: For developers with active Google Cloud billing.
* **Smart Auto-Fallback**: If a paid API returns quota or billing errors (e.g. HTTP 429), StockCraft automatically falls back to Pollinations FLUX.1 to guarantee zero broken generations.

### 3. 🔍 Quality Lab & Defect Inspector
* **Multimodal Defect Scanner**: Checks for mangled hands, extra fingers, blurry textures, AI hallucinations, and accidental logos/watermarks.
* **Strict Technical Compliance**:
  * Resolution ceiling & floor: **4 MP to 100 MP**.
  * File size limitation: **≤ 45 MB**.
  * Format: JPEG with sRGB color profile.
* **1-Click Upscaler**: High-performance local Lanczos/bicubic upscaling (2x: 4096×4096 = 16.77 MP, 4x: 8192×8192) to maximize royalty placement.

### 4. 🏷️ Metadata Studio & Bulk CSV Exporter
* **AI Metadata Generation**: High-converting commercial titles and 30–50 relevant stock keywords.
* **RFC 4180 Adobe Stock CSV**: Direct export of contributor-ready CSV formatted precisely for Adobe Stock Contributor Portal bulk uploads.
* **Embedded IPTC Header**: Embeds title and keywords directly into JPEG EXIF/IPTC binary markers.

### 5. 🔐 Authentication & Session Persistence
* **Google OAuth Sign-In**: Native Google login flow.
* **Encrypted Storage**: API keys and tokens are securely encrypted using `flutter_secure_storage`.
* **State Management**: Clean architecture backed by `provider`.

---

## 🏛️ Architecture & Clean Code

StockCraft follows a modular, feature-first Clean Architecture:

```
lib/
├── core/
│   ├── constants/            # Adobe categories, style presets, metadata standards
│   ├── theme/                # Wabi Aesthetic design system (colors, typography, decorations)
│   ├── utils/                # AdobeValidator, ImageUpscaler, AdobeCsvExporter
│   └── widgets/              # Reusable UI components (GlossyOrb, buttons, badges)
└── features/
    ├── auth/                 # Google OAuth, UserProfile, SecureStorage, AuthProvider
    ├── trends/               # TrendRepository, TrendItem, HomeTrendsScreen
    ├── generator/            # PromptStudioScreen, GeminiService, ImagenService,
    │   │                     # PollinationsService, HuggingFaceService, ImageProviderType
    ├── review_lab/           # ReviewLabScreen, Image inspection & upscale controls
    └── inspector/            # DefectReport models, Quality inspection rules
```

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (`^3.24.0` or later)
* [Dart SDK](https://dart.dev/get-dart) (`^3.5.0` or later)
* Android Studio / Xcode (for mobile deployment)
* An Android device or emulator with USB Debugging enabled

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/DeniFirmansyah18/microstock_tools.git
   cd microstock_tools
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify code quality:**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Run on connected device / emulator:**
   ```bash
   flutter run
   ```

---

## ⚙️ Configuration & API Setup

StockCraft is designed to work **out-of-the-box with zero initial setup**:

| Provider / Feature | Necessity | Setup Instructions |
| :--- | :--- | :--- |
| **Pollinations AI (FLUX.1)** | **Default** | No setup needed! 100% Free image generation. |
| **Gemini 3.7 Flash** | Recommended | Free API key from [Google AI Studio](https://aistudio.google.com/apikey) for prompt ideas, reasoning, and metadata. |
| **Hugging Face Token** | Optional | Free User Access Token from [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens) (Role: Read). |

API keys can be configured directly inside the app in **Welcome Screen > Configure Key** or within **Prompt Studio**.

---

## 🧪 Testing

StockCraft includes extensive unit and integration tests covering the complete pipeline:

```bash
# Run all unit and widget tests
flutter test

# Run individual test suites
flutter test test/pollinations_service_test.dart
flutter test test/prompt_reasoning_test.dart
flutter test test/adobe_validator_test.dart
flutter test test/end_to_end_test.dart
```

---

## 📱 Supported Devices & Rendering Engines
* **Android**: Supports Android 7.0 (API 24) to Android 16 (API 36). Verified on **Motorola Moto G67 5G** with Vulkan Impeller backend.
* **iOS**: iOS 13.0+.
* **Desktop**: Windows 10/11 x64, macOS.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---


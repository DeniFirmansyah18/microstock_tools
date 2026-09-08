# Design Specification: Adobe Stock Contributor AI Image Tool (Flutter)

**Date**: 2026-09-08  
**Status**: Approved (Brainstorming Phase)  
**Target Platforms**: Flutter Android & iOS  
**Framework Version**: Flutter 3.41+ / Dart 3.11+  

---

## 1. Overview & Objective
An all-in-one Flutter mobile application designed for microstock contributors (specifically Adobe Stock Contributor). The application empowers contributors to:
1. Research high-demand image styles, categories, and keywords currently trending on Adobe Stock.
2. Formulate and refine high-converting illustration prompts with automated recommendations.
3. Generate high-resolution illustrations using Google's Imagen 3 model (`imagen-3.0-generate-002`).
4. Perform automated AI defect analysis (verifying anatomy, fingers, blur, noise, gibberish text, watermarks).
5. Upscale images locally via high-fidelity interpolation (Lanczos3/Bicubic with unsharp masking) to strictly satisfy Adobe Stock's technical criteria (4 Megapixels to 100 Megapixels, maximum 45MB file size, sRGB color profile, JPEG format).
6. Automatically synthesize Adobe Stock-compliant Content Titles, standard Categories (21 official categories), and 40–50 ranked SEO keywords.
7. Inject metadata directly into the binary JPEG headers (`APP13` IPTC Core & `APP1` XMP), so that when uploaded to the Adobe Contributor portal, metadata fields are pre-populated automatically.
8. Deliver a world-class, fluid user experience adhering to the **Wabi Minimalist aesthetic** (clean white surfaces, floating pill bars, glossy 3D orbs, and soft diffused elevation).

---

## 2. Adobe Stock Contributor Technical Standards
Every generated asset exported by this application must strictly pass these requirements:
* **Resolution**: Minimum 4 MP (e.g., 2048×2048 = 4.19 MP, 4096×4096 = 16.8 MP), Maximum 100 MP.
* **File Size**: Maximum 45 MB per file.
* **Format**: JPEG with sRGB color profile.
* **Content Integrity**: 100% free of artificial watermarks, creator stamps, camera timestamps, or brand trademarks.
* **Visual Quality**: Sharp focus, no motion blur, balanced exposure, and free from visible generative AI hallucinations (e.g. malformed hands/fingers, distorted faces, unreadable garbled script).
* **Metadata Standard**: IPTC Core `ObjectName` (Title), `Keywords` (list of 30-50 tags), and XMP metadata embedded in standard JPEG markers.

---

## 3. Architecture & Data Flow

### 3.1 The 6-Stage Pipeline
```
┌─────────────────────────┐
│ 1. Market Trends Screen │ <── Curated High-Volume DB + Gemini Dynamic Refresh
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ 2. Prompt Studio        │ <── Smart Prompt Expander, Style Chips, Negative Prompt Injector
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ 3. Imagen 3 Generation  │ <── Google AI Studio REST API (`imagen-3.0-generate-002`)
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ 4. AI Defect Inspection │ <── Client Rule Check + Gemini Vision Defect Analysis
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ 5. Image Upscaler       │ <── Pure Dart Lanczos3 / Bicubic (4MP–32MP, sRGB, <45MB)
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ 6. Metadata & IPTC/XMP  │ <── Gemini Auto-Title/Category/50 Keywords + Binary JPEG Injector
└───────────┬─────────────┘
            ▼
┌─────────────────────────┐
│ Ready-To-Upload JPEG    │ <── Direct Save to Gallery / Share + Adobe Stock CSV
└─────────────────────────┘
```

---

## 4. Subsystem Specifications

### 4.1 Authentication & Quota Management (`features/auth`)
* **Google Sign-In UI**: Elegant pill button `"Continue with Google"` matching the reference screen.
* **Secure API Storage**: Utilizes `flutter_secure_storage` to encrypt and persist Gemini API Keys on Android Keystore and iOS Keychain.
* **Tier Detection & Throttling**:
  * **Free Tier**: Implements request queuing and rate limiting (15 RPM) to prevent `429 Too Many Requests`.
  * **Pro / Paid Tier**: Unlocks high-concurrency requests and high-resolution generation pipelines.
  * **Offline/Sandbox Mode**: Allows testing with mocked data and sample assets.

### 4.2 Market Research & Trends (`features/trends`)
* **Built-in Curated Database**:
  * Trending Visual Styles: *3D Clay Style, Isometric Vector, Cyberpunk Noir, Paper Cutout Art, Minimalist Pastel Flat, Cinematic Photorealism, Retro 90s Grain*.
  * High-Demand Categories: *Business & Remote Work, Eco-Sustainability & Green Energy, Medical & Biotechnology, AI & Cybernetics, Modern Healthy Lifestyle*.
  * Search Velocity Metrics: Demand percentages, competition index, and top tags.
* **Dynamic AI Refresh**:
  * Gemini 2.0/1.5 Flash endpoint analyzes current seasonal and microstock market search trends to recommend emerging niches.

### 4.3 Prompt Studio & Ideation (`features/generator`)
* **Mood Board Visual Hero**: Soft gradient border card with 3D glossy metallic orb.
* **Dynamic Idea Generator**: Button `"🔄 Refresh Ideas"` querying Gemini for fresh conceptual prompts tailored to commercial stock photography and vector illustrations.
* **Stock Negative Prompt Injector**: Automatically appends negative constraints to generation prompts:
  `"watermark, signature, text, logo, blurry, extra limbs, bad anatomy, deformed fingers, low resolution, artifact, noisy"`.
* **Style Selector Chips**: Horizontally scrollable capsule chips for instant style application.

### 4.4 Image Generation (`features/generator/imagen_service.dart`)
* Integrates directly with Google AI Studio's Imagen 3 endpoint.
* Returns raw high-fidelity image bytes (JPEG sRGB).
* Configurable aspect ratios: 1:1 Square, 4:3 Standard, 16:9 Landscape, 9:16 Portrait.

### 4.5 AI Defect Inspector (`features/inspector`)
* **Dual Validation Mechanism**:
  1. **Deterministic Rule Checks**: File size (<45MB), color profile (sRGB verification), minimum dimension check.
  2. **Multimodal Vision Defect Scan**: Passes image to `gemini-2.0-flash` vision model with a structured evaluation rubric:
     - Hand & finger anatomy integrity (count, shape, distortion).
     - Facial and figure symmetry.
     - Presence of unauthorized logos, brands, or text stamps.
     - Unnatural edge tearing or pixel blur.
  3. **Output**: Detailed score card (Passed / Warning / Failed) with diagnostic tags and actionable tips.

### 4.6 In-App Image Upscaler (`core/utils/image_upscaler.dart`)
* High-performance pure Dart image processing using the `image` package.
* **Scaling Algorithms**:
  * Lanczos3 high-order resampling for clean vector/illustration lines.
  * Bicubic interpolation with mild unsharp masking for enhanced photographic texture.
* **Target Resolution**: Multiplies base 1024/2048 dimensions to 4096×4096 (16.8 MP) or up to 32 MP, well above Adobe Stock's 4 MP floor.
* Encodes output to 95% quality JPEG sRGB, strictly verified to remain well under the 45 MB ceiling.

### 4.7 Metadata Generation & Binary IPTC/XMP Writer (`core/utils/exif_iptc_writer.dart`)
* **Metadata Generation**:
  * **Content Title**: 5 to 10 words, grammatically sound, descriptive English title optimized for search indexing.
  * **Category**: Automated mapping to one of the 21 official Adobe Stock categories:
    *Animals, Buildings and Architecture, Business, Drinks, Environment, States of Mind, Food, Graphic Resources, Hobbies and Leisure, Industry, Landscapes, Lifestyle, People, Plants and Flowers, Culture and Religion, Science, Social Issues, Sports, Technology, Transport, Travel.*
  * **Keywords**: 35 to 50 relevant keywords, ordered strictly with the top 10 most descriptive tags first (following Adobe's search algorithm ranking rule).
* **Binary JPEG IPTC/XMP Injection**:
  * Injects `APP13` marker (`0xFF, 0xED`) containing Photoshop 3.0 / IPTC-NAA record:
    - Dataset `2:05` (Object Name / Title).
    - Dataset `2:25` (Keywords repeatable dataset).
    - Dataset `2:120` (Caption / Abstract).
  * Injects `APP1` marker (`0xFF, 0xE1`) containing standard XMP Dublin Core schema (`dc:title`, `dc:subject`, `dc:description`).
  * Adobe Stock Contributor automatically parses these markers upon file upload, populating form fields instantly.
* **Adobe Stock CSV Exporter**:
  * Generates an RFC 4180-compliant CSV file with columns: `Filename, Title, Keywords, Category`.

---

## 5. UI/UX Design System (Impeccable & Wabi Aesthetic)

### 5.1 Design Tokens
* **Background**: Light canvas `#FBFBFD`, Pure white `#FFFFFF`.
* **Surface**: Card background `#FFFFFF`, subtle stroke `#ECECED` (`0.8px`), subtle outer glow `rgba(0, 0, 0, 0.03)` with blur radius `16`.
* **Typography**: *Plus Jakarta Sans* / *Inter*.
  * Title: 28sp / Bold (900 weight for hero titles, 700 for screen headers).
  * Body: 14sp - 15sp / Medium (400-500 weight, `#1A1A1A` and `#707075`).
* **Corner Radii**:
  * Pill buttons & floating dock: `30px` (fully rounded capsule).
  * Feature cards & hero boards: `24px`.
  * Badges & small chips: `14px`.

### 5.2 Screen Breakdown
1. **Screen 1: Splash Screen**: Minimalist branding, clean white background, signature floral/circle motif, top `"Highlight"` badge.
2. **Screen 2: Onboarding / Welcome Screen**: 3D floating ambient spheres, bold headline `"Meet StockCraft. The first personal software platform."`, pill buttons `"Continue with Google"` and `"Continue with Apple"`.
3. **Screen 3: Home / Market Trends Screen**: Top header with user profile & tier badge, grid cards for trending styles (`@adobe_trends`, demand indicators), and floating pill navigation dock.
4. **Screen 4: Prompt Studio & Mood Board**: Hero card with soft pastel gradient border, 3D glossy orb centerpiece, `"🔄 Refresh Ideas"` action pill, and bottom floating prompt bar.
5. **Screen 5: Quality Lab & Detail Review**: Top segmented tab bar (`Quality Check`, `Upscale`, `Metadata`, `Export`), preview with interactive zoom, defect status cards, Adobe specs verification badge, keyword cloud chips, and one-tap IPTC JPEG export button.

---

## 6. Verification & Testing Strategy
* **Unit Tests**:
  * `adobe_validator_test.dart`: Verifies resolution calculations (4MP-100MP), file size ceiling (<45MB), and aspect ratio rules.
  * `exif_iptc_writer_test.dart`: Validates JPEG SOI/EOI integrity and parsing of injected IPTC datasets (Title, Keywords) in generated byte streams.
  * `metadata_generator_test.dart`: Verifies valid Adobe category matching and keyword formatting.
* **Widget Tests**:
  * Verify rendering of the 5 key screens and state transitions without layout overflow or navigation issues.
* **Integration Verification**:
  * Test end-to-end flow: Prompt -> Generation/Simulation -> Defect Inspection -> Upscale -> IPTC Injection -> File Export.

---

## 7. Delivery Status
This specification document is frozen and ready for implementation planning.

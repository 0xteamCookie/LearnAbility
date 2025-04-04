![LearnAbility Banner](https://github.com/user-attachments/assets/97f0e1ca-e42a-46ec-a676-7f4500e8b718)

# LearnAbility: Personalized & Accessible Learning 🚀

[![Platforms](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue?logo=flutter)](https://flutter.dev) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![GitHub stars](https://img.shields.io/github/stars/0xteamCookie/LearnAbility?style=social)](https://github.com/0xteamCookie/LearnAbility) [![GitHub forks](https://img.shields.io/github/forks/0xteamCookie/LearnAbility?style=social)](https://github.com/0xteamCookie/LearnAbility)

**Important Backend Notice:**
> The backend code (API, database setup, AI service integration) resides in its own repository. Please refer to the [**LearnAbility Backend Repository**](https://github.com/0xteamCookie/LearnAbility-backend) for backend setup instructions and code. You will need to have the backend services running for the frontend application to function fully.
---

## ✨ Our Solution: LearnAbility

Meet LearnAbility – your personalized learning co-pilot! 🧑‍✈️ We're transforming how students learn using AI to turn standard course materials (notes, PDFs, etc.) into tailored, interactive lessons.

**Key Ideas:**
*   🧠 **Personalized Paths:** Content adapts to individual learning styles and pace.
*   ♿ **Accessibility Core:** Built with features for visual, auditory, and cognitive accessibility.
*   📱 **Mobile First:** Delivered through a cross-platform Flutter application.

We aim to provide an equitable and engaging learning experience for every student.

## 🌟 Core Features

*   🤖 **AI Content Generation:** Automatically creates lessons, quizzes, and summaries from your uploaded materials (notes, PDFs, etc.).
*   📈 **Adaptive Learning:** Intelligently adjusts content difficulty and provides personalized feedback based on your progress.
*   ♿ **Accessibility Suite:** Includes high-contrast themes, adjustable text sizes, dyslexia-friendly fonts (like OpenDyslexic), text-to-speech output, and potential for voice navigation.
*   🎮 **Interactive Learning:** Offers engaging lesson formats, dynamic quizzes, and visual progress tracking to keep you motivated.
*   🔍 **Smart Search:** Leverages vector search (Milvus) to quickly find the most relevant information within your study materials.

## ✨ App Showcase

![App Showcase](https://github.com/user-attachments/assets/1b25feed-4714-4844-ac09-2a1c537ec550)

---

### 🚀 Live Demo

🔗 [**Click here to try the app**](https://web-la.rkr.cx:8443/)  
> **Username**: `rakesh@kumar.com`  
> **Password**: `rakesh@kumar.com`

---

### 🎥 Video Demo
 
➡️ [**Watch on YouTube**](https://youtu.be/yxvSMyIkjQY)

---

## 🛠️ Technology Stack

*   **Frontend:** Flutter, Dart 📱
*   **Backend:** Node.js, Express.js, TypeScript ⚙️
*   **Database:** PostgreSQL, Milvus (Vector DB) 💾
*   **AI:** Google Vertex AI (Gemini API, RAG) 🧠
*   **Validation:** Zod (Backend) ✅
*   **Authentication:** JWT 🔑
*   **Containerization:** Docker & Docker Compose (for Backend Services) 🐳

## 🏗️ Architecture Overview

* The application consists of a Flutter frontend communicating with the backend API built with Node.js and written in TypeScript. The backend handles business services logic, data storage, and AI interactions.
* Prisma ORM for PostgreSQL, Milvus for vector search, and Google Vertex AI (Gemini) for AI tasks.

```mermaid
flowchart LR
    User[User via Flutter App] --> API[Backend Express API]
    API --> Auth[Auth Middleware]
    Auth --> Routes[API Routes]
    Routes --> Handlers[Request Handlers]
    Handlers --> Services[Business Logic Services]
    Services --> Gemini[Gemini AI Service]
    Services --> Milvus[Milvus Service]
    Services --> Prisma[Prisma ORM]
    Prisma --> DB[(PostgreSQL DB)]
    Milvus --> MilvusDB[(Milvus Vector DB)]
    Gemini --> VertexAI[Google Vertex AI]

    style API fill:#f9f,stroke:#333,stroke-width:2px
    style DB fill:#ccf,stroke:#333,stroke-width:2px
    style MilvusDB fill:#cdf,stroke:#333,stroke-width:2px
    style VertexAI fill:#fca,stroke:#333,stroke-width:2px
```

## 🌍 Our Commitment to Quality Education (UN SDG 4)

*   **Learning for Everyone:** Not everyone learns the same way. LearnAbility adapts to *your* pace and style, making sure no one gets left behind. This is especially helpful for students who find standard methods challenging.
*   **Breaking Down Barriers:** We've included features like dyslexia-friendly fonts (like OpenDyslexic), adjustable text sizes, and text-to-speech. It's about making sure the platform is usable and comfortable for learners with different needs.
*   **Smarter Learning, Not Just More Studying:** Using AI, we turn your notes and materials into engaging lessons and quizzes. It's about understanding concepts better, not just memorizing facts. The adaptive feedback helps you focus where you need it most.
*   **Learning Beyond the Classroom:** Education doesn't stop after school. LearnAbility lets you use your own materials, supporting continuous learning and skill development throughout life.

## 🚀 Getting Started (Overview)

This repository contains the **Flutter Frontend** for LearnAbility. The backend service is maintained in a separate repository.

**Important Backend Notice:**
> The backend code (API, database setup, AI service integration) resides in its own repository. Please refer to the [**LearnAbility Backend Repository**](https://github.com/0xteamCookie/LearnAbility-backend) for backend setup instructions and code. You will need to have the backend services running for the frontend application to function fully.

**Frontend Setup:**

1.  Ensure you have the [Flutter SDK](https://flutter.dev/) installed.
2.  Clone this repository: `git clone https://github.com/0xteamCookie/LearnAbility.git`
3.  Navigate to the project directory: `cd LearnAbility`
4.  Install dependencies: `flutter pub get`
5.  **Ensure the backend services are running** (see the [Backend Repository](https://github.com/0xteamCookie/LearnAbility-backend) for instructions).
6.  Run the Flutter application: `flutter run` (select your target device/emulator).

*(Prerequisites: Flutter, Dart, Git. See backend repository for its prerequisites like Node.js, Docker)*

## 🔗 Project Repositories

*   **Frontend (This Repository):** [https://github.com/0xteamCookie/LearnAbility](https://github.com/0xteamCookie/LearnAbility)
*   **Backend Repository:** [https://github.com/0xteamCookie/LearnAbility-backend](https://github.com/0xteamCookie/LearnAbility-backend)

## 🍪 Meet the Team: teamCookie()

*   **[shaunakc11](https://github.com/shaunakc11)** - Full Stack Developer | AI Engineer
*   **[0xPixelNinja](https://github.com/0xPixelNinja)** - Backend Developer
*   **[Kathrina-dev](https://github.com/Kathrina-dev)** - Frontend and UI/UX Designer
*   **[pranjal-kumar-0](https://github.com/pranjal-kumar-0)** - Frontend and UI/UX Designer

## 📜 License

Licensed under the **GNU General Public License v3.0**.
# Neurova

> An intelligent AI-powered academic assistant platform combining a Node.js backend with a Flutter mobile app for personalized learning, task management, and focus optimization.

[![License: MIT](https://img.shields.io/badge/License-MIT-C8B8E8?style=flat-square)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-20%2B-BEB0D0?style=flat-square&logo=node.js)](https://nodejs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-E8C898?style=flat-square&logo=flutter)](https://flutter.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5%2B-C8B8E8?style=flat-square&logo=typescript)](https://www.typescriptlang.org/)
[![Dart](https://img.shields.io/badge/Dart-3%2B-BEB0D0?style=flat-square&logo=dart)](https://dart.dev/)

---
## �🎯 Overview

Neurova is a comprehensive academic productivity and AI-assisted learning platform built for students, professionals, and lifelong learners. It combines intelligent tutoring, task automation, focus optimization, and gamified motivation into a unified mobile experience.

### Why Neurova?

**Fragmented Learning:** Students juggle multiple apps (note-taking, to-do lists, calendars, chat) losing time switching contexts.

**Neurova Solution:** One integrated platform where:
- You ask the AI anything about your studies, it remembers your learning style and weak areas
- You mention "add these 5 tasks", they're auto-created and prioritized
- You study, every minute is tracked and rewarded
- Your progress becomes visible, motivation increases through achievements

### Core Capabilities

- **AI-Powered Tutoring**: Conversational learning with Claude, Gemini, or OpenRouter. The AI remembers what you've studied, identifies knowledge gaps, and adapts explanations to your level.
- **Semantic Note Search**: Ask "what did I learn about photosynthesis?" and get relevant notes instantly via vector embeddings.
- **Smart Task Planning**: Natural language task creation ("create a study schedule for the MCAT") with automatic subtask generation.
- **Focus Session Tracking**: Pomodoro-style study sessions with real-time timer, 35-day heatmap showing study consistency, and streak analytics.
- **Gamification Engine**: XP rewards (scaled by task difficulty), achievement unlocks, leaderboards, and daily challenges to sustain motivation.
- **Calendar Integration**: Google Calendar sync shows study sessions alongside classes and deadlines.
- **Faith Mode**: Prayer time reminders, spiritual study content integration, and faith-based daily challenges.
- **Smart Notifications**: Contextual reminders for tasks, prayer times, achievements, and daily challenges (customizable per preference).
- **Multi-Language Support**: Full support for English, French, and Arabic with AI responses in your preferred language.

---

## 🛠 Tech Stack

### Backend
| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Runtime** | Node.js 20+ | JavaScript runtime |
| **Framework** | Express.js + TypeScript | REST API & server |
| **Database** | PostgreSQL + Prisma ORM | Relational data & migrations |
| **Vector Search** | Supabase Vector DB | Semantic search & embeddings |
| **AI** | Claude, Gemini, OpenRouter, Ollama | Multi-provider LLM fallback |
| **Auth** | JWT + Google OAuth | Authentication & authorization |
| **Email** | Brevo | Transactional emails & campaigns |
| **Docs** | Swagger/OpenAPI | API documentation |

### Frontend (Flutter)
| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Framework** | Flutter 3.0+ | Cross-platform mobile app |
| **State** | Riverpod | Type-safe reactive state |
| **HTTP** | Dio | API client with interceptors |
| **Storage** | Shared Preferences | Local key-value storage |
| **Auth** | Google Sign-In + Firebase | User authentication |
| **UI** | Custom Material + NeuropaColors | Theme system & design |
| **Platforms** | Android, iOS, Web | Target platforms |

---



## 📚 API Documentation

The backend exposes RESTful endpoints grouped by feature:

| Module | Endpoints | Auth |
|--------|-----------|------|
| **Auth** | POST `/auth/login`, `/auth/register`, `/auth/verify` | Public |
| **Tasks** | CRUD `/tasks`, `/tasks/lists`, `/tasks/status` | Bearer Token |
| **Notes** | CRUD `/notes`, `/notes/search` | Bearer Token |
| **AI Chat** | POST `/ai/chat`, `/ai/chat/memory` | Bearer Token |
| **Focus Sessions** | CRUD `/sessions`, `/sessions/history` | Bearer Token |
| **Gamification** | GET `/achievements`, `/leaderboard`, `/daily-challenges` | Bearer Token |
| **Notifications** | GET `/notifications`, `/settings` | Bearer Token |

**Full API spec:** Available via Swagger at `/api-docs` when backend is running.

---

## 🧪 Testing

### Backend Tests
```bash
cd Backend
npm run test                // Run all tests
npm run test:watch         // Watch mode
npm run test:coverage      // Coverage report
```

**Test files located in:** `Backend/test/`

### Frontend Tests
```bash
cd neurova_app
flutter test                # Run all tests
flutter test --coverage     # Coverage report
```

---

## 🤝 Architecture Highlights

### Backend
- Clean Architecture: Entities → Repositories → Use Cases → Controllers
- Dependency Injection: Service providers via constructor injection
- Error Handling: Centralized error handler with consistent HTTP responses
- Database: Prisma migrations for version control
- AI Fallback: Automatic provider failover (Claude → Gemini → OpenRouter → Ollama)

---

### Frontend
- Riverpod State Management: Type-safe, reactive state with providers
- Theme System: NeuropaColors extension with light/dark mode support
- Navigation: GoRouter with deep linking support
- API Integration: Dio with interceptors for token refresh and error handling
---
## 📦 Key Features Deep Dive

### AI Assistant
- Context-aware responses using Retrieval-Augmented Generation (RAG)
- Memory system to track user progress and preferences
- Multi-language support (English, French, Arabic)
- Automatic task creation from natural language

### Task Management
- Hierarchical task lists with categories and priorities
- Status tracking (PENDING → IN_PROGRESS → COMPLETED)
- Automatic study plan generation from text prompts
- Calendar view integration

### Focus Sessions
- Session timer with start/stop/pause controls
- 35-day productivity heatmap visualization
- Session history and duration analytics
- Integration with gamification system

### Gamification
- XP earned per completed task (scaled by priority/category)
- Achievements with badge system
- Global leaderboard
- Daily challenges with streak tracking

---

## 🛤 Development Roadmap

- Offline mode for mobile app
- Advanced analytics dashboard
- Collaborative study groups
- Video explanation generation from notes
- Mobile web synchronization
- Admin dashboard
---
## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

**Guidelines:**
- Follow TypeScript/Dart style conventions
- Write tests for new features
- Update documentation
- Keep commits atomic and descriptive

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📞 Support & Contact

For issues, feature requests, or questions:
- **Issues:** [GitHub Issues](https://github.com/Rezouali-Imane/NeuroVa/issues)


---

**Made with ❤️ for students and learners worldwide.**

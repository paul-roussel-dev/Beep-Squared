# 📚 Beep Squared Documentation

## 🎯 Project Overview

Beep Squared is a modern Flutter alarm application with adaptive day/evening theming and hybrid Flutter + Android native architecture.

## 📋 Core Documentation

### Architecture & Development

- **[Architecture Guide](ARCHITECTURE.md)** - System architecture and design patterns
- **[Development Guide](DEVELOPMENT.md)** - Setup, coding standards, and workflows
- **[Kotlin Integration](KOTLIN_RESTRUCTURE.md)** - Android native service architecture

### Migration Reports

- **[Constants Migration](CONSTANTS_MIGRATION_REPORT.md)** ⭐ **COMPLETE** - Full centralization of app constants

## 🚀 Quick Start

1. **Clone & Setup**

   ```bash
   git clone <repo-url>
   cd beep_squared
   flutter pub get
   ```

2. **Run Development**

   ```bash
   flutter run --hot
   ```

3. **Build Release**
   ```bash
   flutter build apk --release
   ```

## 🏗️ Architecture Highlights

- **Constants System**: Centralized AppStrings, AppColors, AppSizes
- **Adaptive Theming**: Automatic day/evening color switching
- **Hybrid Architecture**: Flutter UI + Android native alarm services
- **Material Design 3**: Modern UI components and theming

## 📱 Key Features

- ⏰ Reliable alarm scheduling with Android AlarmManager
- 🎨 Adaptive day/evening theming (blue/orange)
- 🧮 Math challenge dismiss options
- 🔊 Custom ringtone support
- 📳 Vibration patterns
- ⏰ Snooze functionality

## 🔧 Development Status

- ✅ **Constants Architecture**: Complete migration (100%)
- ✅ **UI Components**: Material Design 3 implementation
- ✅ **Theming System**: Adaptive day/evening themes
- ✅ **Compilation**: 0 errors, production ready

## 📖 Additional Resources

- `/docs/features/` - Feature-specific documentation
- `/docs/fixes/` - Bug fix documentation and solutions

---

**Last Updated**: January 2025  
**Status**: Production Ready ✅

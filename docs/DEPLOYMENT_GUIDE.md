# 🚀 Guide de Déploiement - Beep Squared

## 📋 Prérequis

### Environnement
- **Flutter** 3.8.1+
- **Android SDK** 34+
- **Gradle** 8.0+
- **Java** 17+

### Certificats
```bash
# Générer keystore pour signature
keytool -genkey -v -keystore beep-squared-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias beep-squared
```

## 🔧 Configuration Build

### android/key.properties
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=beep-squared
storeFile=../beep-squared-key.jks
```

### android/app/build.gradle
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.paulrousseldev.beep_squared"
        minSdkVersion 23
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## 📱 Commandes de Build

### Debug Build
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release Build
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build avec obfuscation
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## 🏪 Google Play Store

### Checklist Pre-Publication
- [ ] **Tests** sur devices physiques
- [ ] **Permissions** justifiées et minimales
- [ ] **Privacy Policy** rédigée
- [ ] **Screenshots** 16:9 et 9:16
- [ ] **Description** attractive
- [ ] **Metadata** complets
- [ ] **Content Rating** approprié

### Métadonnées Suggérées
```
Titre: Beep Squared - Smart Alarm
Description courte: Réveil intelligent avec défis mathématiques et thèmes adaptatifs

Description longue:
🌅 Réveil intelligent avec thèmes adaptatifs jour/soir
🧮 Défis mathématiques pour un réveil en douceur
🎵 Sonneries personnalisables avec aperçu
📳 Vibrations configurables
⏰ Snooze intelligent
🔄 Répétitions flexibles
🎨 Interface Material Design 3

Parfait pour transformer votre réveil en moment agréable !
```

### Screenshots Recommandés
1. **Écran principal** avec liste d'alarmes
2. **Création d'alarme** avec tous les paramètres
3. **Sélection thème** jour/soir
4. **Défi mathématique** en action
5. **Paramètres** de l'application

## 🔒 Sécurité & Permissions

### Permissions Requises
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

### Justifications
- **RECEIVE_BOOT_COMPLETED** : Restaurer alarmes après redémarrage
- **WAKE_LOCK** : Réveiller l'écran pour les alarmes
- **VIBRATE** : Vibrations d'alarme
- **USE_FULL_SCREEN_INTENT** : Affichage plein écran des alarmes
- **SCHEDULE_EXACT_ALARM** : Alarmes précises (Android 12+)

## 📊 Monitoring Post-Déploiement

### Analytics Recommandés
```dart
// Firebase Analytics events
analytics.logEvent(
  name: 'alarm_created',
  parameters: {
    'unlock_method': 'math',
    'difficulty': 'medium',
    'has_repeat': true,
  },
);
```

### Métriques Clés
- **Retention** : Utilisateurs actifs après 7/30 jours
- **Engagement** : Nombre d'alarmes créées par utilisateur
- **Reliability** : Taux de succès des alarmes
- **Performance** : Temps de démarrage de l'app

## 🔄 CI/CD GitHub Actions

### .github/workflows/release.yml
```yaml
name: Release Build
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
          
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.1'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Analyze code
        run: flutter analyze
        
      - name: Run tests
        run: flutter test --coverage
        
      - name: Build APK
        run: flutter build apk --release
        
      - name: Build App Bundle
        run: flutter build appbundle --release
        
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: release-builds
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab
```

## 📈 Roadmap Post-Launch

### Version 1.1.0
- [ ] Backup cloud des alarmes
- [ ] Widget Android
- [ ] Plus de sonneries

### Version 1.2.0
- [ ] Internationalisation (FR, ES, DE)
- [ ] Thèmes personnalisés
- [ ] Statistiques de sommeil

### Version 2.0.0
- [ ] Sync multi-devices
- [ ] Smart wake-up basé sur cycles
- [ ] Intégration santé/fitness

---

🎯 **Objectif** : Déploiement réussi avec 0 crash et feedback utilisateur positif !

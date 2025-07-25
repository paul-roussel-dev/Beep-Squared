# 💬 Instructions Messages de Commit - Beep Squared

## 🎯 Format Obligatoire : Conventional Commits

**Structure :**
```
type(scope): description
```

**Règles strictes :**
- Maximum 50 caractères
- Minuscules uniquement
- Pas de point final
- Verbe à l'impératif présent

## 📝 Types Autorisés

- **feat** : Nouvelle fonctionnalité
- **fix** : Correction de bug  
- **docs** : Documentation
- **style** : Formatage, linting
- **refactor** : Refactoring
- **test** : Tests
- **chore** : Maintenance, nettoyage

## 🏷️ Scopes Projet

- **alarm** : Gestion des alarmes
- **ringtone** : Sons et sonneries
- **ui** : Interface utilisateur
- **native** : Code Android/iOS
- **audio** : Fonctionnalités audio
- **storage** : Persistance données
- **service** : Services Flutter

## ✅ Exemples Corrects

```
feat(alarm): add snooze functionality
fix(ui): resolve card overflow issue
docs: update installation guide
style: apply dart format rules
refactor(service): optimize monitoring
test(alarm): add unit tests
chore: remove unused dependencies
```

## ❌ Exemples Incorrects

```
❌ Add snooze functionality for alarms
❌ fix: Fixed the overflow bug in alarm card widget
❌ feat(alarm): Add comprehensive snooze functionality with customizable options
❌ Updated documentation and fixed bugs
```

## 🎯 Messages Types par Contexte

### Nouvelles Fonctionnalités
```
feat(alarm): add weekly repeat
feat(ringtone): support custom import
feat(ui): implement dark theme
feat(audio): add volume control
```

### Corrections
```
fix(alarm): prevent duplicate triggers
fix(ui): handle text overflow
fix(native): resolve timezone issues
fix(storage): fix data persistence
```

### Documentation
```
docs: update readme
docs(api): add service documentation
docs: fix installation steps
```

### Nettoyage & Maintenance
```
chore: remove unused files
chore: update dependencies
chore: clean build artifacts
refactor: simplify alarm logic
```

---

**IMPORTANT :** Utilisez UNIQUEMENT le titre du commit. Pas de description détaillée, pas de bullet points, juste : `type(scope): description`

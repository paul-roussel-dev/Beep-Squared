# Système de Défi Mathématique - Version Unifiée

## Vue d'ensemble

Le système de défi mathématique unifié permet aux utilisateurs de configurer des alarmes avec un seul type "Math" personnalisable. Les utilisateurs peuvent ajuster la difficulté et les types d'opérations selon leurs préférences.

## Types de Déverrouillage

### 1. Simple

- Déverrouillage instantané avec bouton "DISMISS"
- Aucun défi requis

### 2. Math (Personnalisable)

- **3 niveaux de difficulté** :

  - **Facile** : Nombres 1-50, multiplications 1-10
  - **Moyen** : Nombres 1-100, multiplications 1-12
  - **Difficile** : Nombres 1-200, multiplications 1-15

- **4 types d'opérations** :
  - **Addition** : Uniquement des additions
  - **Soustraction** : Uniquement des soustractions
  - **Multiplication** : Uniquement des multiplications
  - **Mélangé** : Mélange aléatoire des trois opérations

## Interface Utilisateur Améliorée

### Configuration des Alarmes

1. **Sélection du type** : Simple ou Math
2. **Si Math sélectionné** : Dialog de configuration automatique **compacte**
3. **Interface optimisée** :
   - **Difficulté** : 3 boutons horizontaux (Facile/Moyen/Difficile)
   - **Opérations** : 4 boutons icônes `+` `−` `×` `±×`
   - **Exemple en temps réel** : Aperçu du calcul selon la sélection
   - **Pas d'overflow** : Interface adaptée aux petits écrans

### Écran d'Alarme

- **Zone de défi** : Question mathématique en grand format
- **Pavé numérique** : Interface moderne avec tous les chiffres
- **Boutons d'action** :
  - `C` : Effacer la saisie
  - `⌫` : Supprimer le dernier chiffre
  - `VALIDATE` : Valider la réponse
  - `SNOOZE` : Reporter l'alarme (toujours disponible)

## Exemples de Défis

### Difficulté Facile

```
Addition:        23 + 17 = ?
Soustraction:    45 - 12 = ?
Multiplication:   7 × 6 = ?
```

### Difficulté Moyenne

```
Addition:        67 + 84 = ?
Soustraction:    89 - 34 = ?
Multiplication:  11 × 12 = ?
```

### Difficulté Difficile

```
Addition:        156 + 127 = ?
Soustraction:    178 - 89 = ?
Multiplication:   14 × 15 = ?
```

## Architecture Technique

### Flutter (Dart)

- **Enum simplifié** : `AlarmUnlockMethod` avec `simple` et `math`
- **Nouveaux Enums** :
  - `MathDifficulty` : easy, medium, hard
  - `MathOperations` : additionOnly, subtractionOnly, multiplicationOnly, mixed
- **Interface** : Dialog de configuration automatique pour personnaliser

### Android Native (Kotlin)

- **Paramètres transmis** : `mathDifficulty` et `mathOperations`
- **Génération intelligente** : Défis adaptés selon les paramètres
- **Interface visible** : Correction du problème d'affichage

## Avantages du Système Unifié

### ✅ **Simplicité**

- Un seul type "Math" au lieu de 3 types séparés
- Configuration centralisée et intuitive
- Interface plus claire pour l'utilisateur

### ✅ **Flexibilité**

- Personnalisation fine de la difficulté
- Choix précis des opérations
- Expérience adaptée à chaque utilisateur

### ✅ **Extensibilité**

- Facile d'ajouter de nouveaux niveaux de difficulté
- Simple d'intégrer de nouveaux types d'opérations
- Structure prête pour des fonctionnalités avancées

## Test du Système

### Étapes de Test

1. **Créer une alarme** → Sélectionner "Math"
2. **Configurer** → Choisir difficulté et opérations
3. **Tester l'alarme** → Vérifier l'affichage du défi
4. **Résoudre** → Utiliser le pavé numérique
5. **Valider** → Bouton "VALIDATE" pour confirmer

### Points de Vérification

- [ ] Interface de calcul visible et centrée
- [ ] Génération correcte selon difficulté/opérations
- [ ] Pavé numérique fonctionnel
- [ ] Validation des réponses exacte
- [ ] Snooze disponible même pendant défi
- [ ] Feedback en cas de mauvaise réponse

## Configuration Recommandée

- **Utilisateurs débutants** : Facile + Addition
- **Utilisateurs intermédiaires** : Moyen + Mélangé
- **Utilisateurs avancés** : Difficile + Multiplication
- **Réveil urgent** : Toujours garder une alarme "Simple"

Le nouveau système unifié offre une expérience plus fluide et personnalisable tout en maintenant la robustesse du système d'alarme.

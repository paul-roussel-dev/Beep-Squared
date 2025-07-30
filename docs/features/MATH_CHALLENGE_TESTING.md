# Guide de Test - Système de Défi Mathématique

## Instructions de Test

### 1. Créer une Alarme avec Défi Mathématique

1. Ouvrez l'application Beep Squared
2. Appuyez sur le bouton "+" pour créer une nouvelle alarme
3. Configurez l'heure souhaitée
4. **Important** : Cliquez sur "Méthode de déverrouillage"
5. Sélectionnez un type de défi :
   - **Addition** : Problèmes comme `34 + 67 = ?`
   - **Soustraction** : Problèmes comme `85 - 23 = ?`
   - **Multiplication** : Problèmes comme `8 × 7 = ?`
6. Sauvegardez l'alarme

### 2. Tester l'Alarme

1. Attendez que l'alarme se déclenche ou créez une alarme dans 1-2 minutes
2. L'écran d'alarme s'affiche avec :
   - Le défi mathématique au centre
   - Un pavé numérique en bas
   - Les boutons "Snooze" et "C" (Effacer)

### 3. Résoudre le Défi

1. **Calculez mentalement** la réponse au problème affiché
2. **Saisissez la réponse** avec le pavé numérique
3. **Validez** en appuyant sur le bouton de validation
4. **Si correct** : L'alarme s'arrête immédiatement
5. **Si incorrect** : Message d'erreur, nouveau défi généré

### 4. Test de Snooze

1. Même avec un défi mathématique actif, le bouton **"Snooze"** reste disponible
2. Appuyez sur "Snooze" pour reporter l'alarme de 5 minutes
3. Une notification apparaît confirmant le snooze
4. L'alarme se redéclenchera avec un nouveau défi mathématique

## Exemples de Défis par Type

### Addition

```
23 + 45 = ?    (Réponse: 68)
67 + 89 = ?    (Réponse: 156)
12 + 34 = ?    (Réponse: 46)
```

### Soustraction

```
84 - 27 = ?    (Réponse: 57)
95 - 18 = ?    (Réponse: 77)
73 - 24 = ?    (Réponse: 49)
```

### Multiplication

```
7 × 8 = ?      (Réponse: 56)
9 × 12 = ?     (Réponse: 108)
6 × 6 = ?      (Réponse: 36)
```

## Points de Validation

### ✅ Fonctionnalités à Vérifier

- [ ] Sélection du type de déverrouillage dans l'interface de création
- [ ] Génération correcte des défis mathématiques
- [ ] Pavé numérique fonctionnel avec tous les chiffres (0-9)
- [ ] Bouton "C" pour effacer la saisie
- [ ] Bouton de suppression (←) pour supprimer le dernier chiffre
- [ ] Validation des réponses correctes
- [ ] Gestion des réponses incorrectes avec nouveau défi
- [ ] Snooze disponible même pendant un défi
- [ ] Notification de snooze correcte
- [ ] Re-déclenchement après snooze avec nouveau défi

### ⚠️ Cas d'Erreur à Tester

- [ ] Que se passe-t-il si l'utilisateur entre une réponse vide ?
- [ ] Comportement avec des nombres très longs
- [ ] Gestion des erreurs de génération de défi
- [ ] Fallback vers mode simple en cas de problème

## Logs à Surveiller

Lorsque vous testez, surveillez les logs Android avec :

```bash
adb logcat | grep -E "(AlarmOverlay|MathChallenge|AlarmTrigger)"
```

Logs attendus :

- `Processing alarm trigger with unlock method: [type]`
- `Math challenge generated: [question]`
- `Answer validation: [correct/incorrect]`
- `New challenge generated after wrong answer`

## Problèmes Courants et Solutions

### L'interface mathématique n'apparaît pas

- Vérifiez que l'unlockMethod est correctement passé
- Regardez les logs pour les erreurs de génération

### Les réponses correctes ne sont pas acceptées

- Vérifiez la logique de validation dans `validateAnswer()`
- Confirmez que les calculs sont corrects

### Le pavé numérique ne fonctionne pas

- Testez les listeners de clic sur chaque bouton
- Vérifiez la mise à jour de l'affichage de la réponse

## Améliorations Suggérées (Future)

1. **Niveaux de Difficulté** : Facile/Moyen/Difficile
2. **Types Supplémentaires** : Division, fractions, géométrie
3. **Statistiques** : Temps de résolution, taux de réussite
4. **Mode Entraînement** : Pratiquer sans alarme
5. **Personnalisation** : Ranges personnalisés pour les nombres

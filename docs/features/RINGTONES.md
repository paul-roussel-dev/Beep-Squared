# 🎵 Système de Sonneries - Beep Squared

## Fonctionnalités

### 🔊 Sonneries Intégrées
L'application inclut 8 sonneries de haute qualité :
- **Default** - Sonnerie système par défaut
- **Alarm Clock** - Sonnerie d'alarme classique
- **Bright Electronic** - Boucle électronique énergique
- **Level Up** - Son de jeu amusant
- **Melody Ring** - Mélodie harmonieuse
- **Original Phone** - Sonnerie de téléphone rétro
- **Ringtone** - Sonnerie moderne standard
- **Soft Ring** - Sonnerie douce et apaisante

### 📱 Import de Sonneries Personnalisées
- **Import facile** : Ajoutez vos propres fichiers audio
- **Formats supportés** : MP3, WAV, M4A, et autres formats audio courants
- **Stockage local** : Les sonneries sont copiées dans l'application
- **Noms automatiques** : Noms d'affichage générés automatiquement

### 🗑️ Gestion des Sonneries
- **Suppression** : Supprimez les sonneries personnalisées
- **Persistance** : Les sonneries sont sauvegardées entre les sessions
- **Nettoyage** : Suppression automatique des fichiers inutilisés

## Utilisation

### Ajouter une Alarme avec Sonnerie
1. Appuyez sur "+" pour créer une nouvelle alarme
2. Dans la section "Settings", appuyez sur "Ringtone"
3. Choisissez parmi les sonneries disponibles
4. Ou appuyez sur "Import Custom Ringtone" pour ajouter la vôtre

### Importer une Sonnerie Personnalisée
1. Dans le sélecteur de sonneries, appuyez sur "Import Custom Ringtone"
2. Sélectionnez un fichier audio depuis votre appareil
3. La sonnerie sera automatiquement ajoutée à votre liste
4. Vous pouvez maintenant l'utiliser pour vos alarmes

### Supprimer une Sonnerie Personnalisée
1. Dans le sélecteur de sonneries, trouvez votre sonnerie personnalisée
2. Appuyez sur l'icône de suppression (🗑️) à côté
3. La sonnerie sera supprimée de l'application

## Architecture Technique

### Service RingtoneService
- **Singleton** : Instance unique pour toute l'application
- **Cache** : Chargement efficace des sonneries
- **Persistance** : Sauvegarde via SharedPreferences
- **Gestion des fichiers** : Copie et suppression automatique

### Stockage
- **Sonneries par défaut** : `assets/sounds/`
- **Sonneries personnalisées** : `documents/custom_sounds/`
- **Métadonnées** : SharedPreferences avec clé `custom_ringtones`

### Format des Données
```dart
{
  'name': 'Nom d\'affichage',
  'path': 'chemin/vers/fichier.mp3',
  'type': 'asset' | 'custom' | 'system'
}
```

## Dépendances
- `file_picker` : Sélection de fichiers audio
- `path_provider` : Accès aux dossiers de l'application
- `shared_preferences` : Sauvegarde des préférences

## Bonnes Pratiques
- ✅ Vérification de l'existence des fichiers avant utilisation
- ✅ Gestion des erreurs avec try-catch
- ✅ Nettoyage automatique des ressources
- ✅ Interface utilisateur responsive
- ✅ Feedback utilisateur avec SnackBar

## Limitations
- Taille maximale des fichiers : Dépend de l'espace disponible
- Formats supportés : Ceux pris en charge par Flutter
- Pas de prévisualisation audio dans le sélecteur

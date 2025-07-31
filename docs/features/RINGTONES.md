# 🎵 Sonneries

## 🔊 Sonneries Intégrées

7 sonneries haute qualité incluses :
- **Default** - Sonnerie système
- **Alarm Clock** - Sonnerie classique
- **Bright Electronic** - Boucle énergique
- **Level Up** - Son de jeu
- **Melody Ring** - Mélodie harmonieuse
- **Original Phone** - Sonnerie rétro
- **Soft Ring** - Sonnerie douce

## 📱 Fonctionnalités

### Prévisualisation
- Écoute avant sélection (max 3s)
- Contrôles play/stop intuitifs
- Arrêt automatique à la sélection

### Gestion
- **Storage** : Assets intégrés dans l'application
- **Formats** : MP3 optimisés
- **Noms** : Affichage convivial automatique

## ⚙️ Implémentation

Service `RingtoneService` avec chargement lazy et cache des noms d'affichage.
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

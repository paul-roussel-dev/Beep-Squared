# Script PowerShell pour remplacer toutes les couleurs de texte par du blanc
# Chemin vers le dossier lib
$libPath = "lib"

# Fonction pour remplacer les couleurs dans un fichier
function Replace-TextColors {
    param($FilePath)
    
    Write-Host "Processing: $FilePath"
    
    # Lire le contenu du fichier
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $originalContent = $content
    
    # Remplacements pour les couleurs de texte (color: Theme.of...)
    $content = $content -replace 'color:\s*Theme\.of\(context\)\.colorScheme\.on[A-Za-z]+,', 'color: const Color(0xFFFFFFFF),'
    $content = $content -replace 'color:\s*Theme\.of\(context\)\.colorScheme\.primary,', 'color: const Color(0xFFFFFFFF),'
    $content = $content -replace 'color:\s*Theme\.of\(context\)\.colorScheme\.secondary,', 'color: const Color(0xFFFFFFFF),'
    $content = $content -replace 'color:\s*Theme\.of\(context\)\.colorScheme\.tertiary,', 'color: const Color(0xFFFFFFFF),'
    $content = $content -replace 'color:\s*Theme\.of\(context\)\.colorScheme\.error,', 'color: const Color(0xFFFFFFFF),'
    
    # Remplacements pour les icônes (sans virgule finale)
    $content = $content -replace 'color:\s*Theme\.of\(context\)\.colorScheme\.on[A-Za-z]+\s*\)', 'color: const Color(0xFFFFFFFF))'
    $content = $content -replace 'color:\s*Theme\.of\(context\)\.colorScheme\.primary\s*\)', 'color: const Color(0xFFFFFFFF))'
    $content = $content -replace 'color:\s*Theme\.of\(context\)\.colorScheme\.secondary\s*\)', 'color: const Color(0xFFFFFFFF))'
    $content = $content -replace 'color:\s*Theme\.of\(context\)\.colorScheme\.tertiary\s*\)', 'color: const Color(0xFFFFFFFF))'
    $content = $content -replace 'color:\s*Theme\.of\(context\)\.colorScheme\.error\s*\)', 'color: const Color(0xFFFFFFFF))'
    
    # Remplacements pour les expressions ternaires (condition ? color : autre_color)
    $content = $content -replace '\?\s*Theme\.of\(context\)\.colorScheme\.on[A-Za-z]+', '? const Color(0xFFFFFFFF)'
    $content = $content -replace '\?\s*Theme\.of\(context\)\.colorScheme\.primary', '? const Color(0xFFFFFFFF)'
    $content = $content -replace '\?\s*Theme\.of\(context\)\.colorScheme\.secondary', '? const Color(0xFFFFFFFF)'
    $content = $content -replace '\?\s*Theme\.of\(context\)\.colorScheme\.tertiary', '? const Color(0xFFFFFFFF)'
    $content = $content -replace '\?\s*Theme\.of\(context\)\.colorScheme\.error', '? const Color(0xFFFFFFFF)'
    
    $content = $content -replace ':\s*Theme\.of\(context\)\.colorScheme\.on[A-Za-z]+', ': const Color(0xFFFFFFFF)'
    $content = $content -replace ':\s*Theme\.of\(context\)\.colorScheme\.primary', ': const Color(0xFFFFFFFF)'
    $content = $content -replace ':\s*Theme\.of\(context\)\.colorScheme\.secondary', ': const Color(0xFFFFFFFF)'
    $content = $content -replace ':\s*Theme\.of\(context\)\.colorScheme\.tertiary', ': const Color(0xFFFFFFFF)'
    $content = $content -replace ':\s*Theme\.of\(context\)\.colorScheme\.error', ': const Color(0xFFFFFFFF)'
    
    # Sauvegarder si des changements
    if ($content -ne $originalContent) {
        Set-Content $FilePath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "Updated: $FilePath"
    } else {
        Write-Host "No changes: $FilePath"
    }
}

# Traiter tous les fichiers Dart dans lib/
Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse | ForEach-Object {
    Replace-TextColors $_.FullName
}

Write-Host "Finished processing all Dart files."

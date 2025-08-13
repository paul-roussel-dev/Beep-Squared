# Script PowerShell pour corriger les erreurs de syntaxe dans les fichiers Dart

# Fichiers à corriger
$files = @(
    "lib\screens\add_alarm_screen.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Correction de $file..."
        
        # Lire le contenu du fichier
        $content = Get-Content $file -Raw -Encoding UTF8
        
        # Corriger 'Color(0xFFFFFFFF)Container' en 'Color(0xFFFFFFFF)'
        $content = $content -replace 'const Color\(0xFFFFFFFF\)Container', 'const Color(0xFFFFFFFF)'
        
        # Corriger 'checkmarkcolor' en 'checkmarkColor'
        $content = $content -replace 'checkmarkcolor:', 'checkmarkColor:'
        
        # Sauvegarder le fichier corrigé
        Set-Content -Path $file -Value $content -Encoding UTF8 -NoNewline
        
        Write-Host "✓ $file corrigé"
    } else {
        Write-Host "✗ Fichier non trouvé: $file"
    }
}

Write-Host "Correction terminée!"

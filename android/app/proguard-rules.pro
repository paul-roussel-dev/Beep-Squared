# Flutter Local Notifications Plugin - Minimal rules for release builds
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep gson classes used by flutter_local_notifications  
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Keep model classes that may be obfuscated
-keep class y0.** { *; }

# General Flutter rules (minimal)
-keep class io.flutter.** { *; }
-keep class com.example.beep_squared.** { *; }

# Keep essential annotations for generics
-keepattributes Signature
-keepattributes *Annotation*

# Proguard rules for Flutter and plugins

# Google Play Core deferred components
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn com.google.android.play.core.**

# Flutter wrapper rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google ML Kit Text Recognition & Translation
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google_mlkit_text_recognition.**
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

-dontwarn com.google.mlkit.nl.translate.**
-dontwarn com.google_mlkit_translation.**
-keep class com.google.mlkit.nl.translate.** { *; }
-keep class com.google_mlkit_translation.** { *; }

-dontwarn com.google.mlkit.commons.**
-keep class com.google.mlkit.commons.** { *; }

# Image Picker & UCrop
-dontwarn com.yalantis.ucrop.**
-keep class com.yalantis.ucrop.** { *; }

# Flutter TTS
-dontwarn com.tundralabs.fluttertts.**
-keep class com.tundralabs.fluttertts.** { *; }

# Shared Preferences
-dontwarn io.flutter.plugins.sharedpreferences.**
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Connectivity Plus
-dontwarn dev.fluttercommunity.plus.connectivity.**
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# General Android & Google Play Services Keep Rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepclassmembers class * {
    @com.google.android.gms.common.annotation.KeepName *;
}
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

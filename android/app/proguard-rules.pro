# Proguard rules for ML Kit Text Recognition and Translation
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google_mlkit_text_recognition.**
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

-dontwarn com.google.mlkit.nl.translate.**
-dontwarn com.google_mlkit_translation.**
-keep class com.google.mlkit.nl.translate.** { *; }
-keep class com.google_mlkit_translation.** { *; }

# General Flutter & ML Kit rules
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.android.gms.common.annotation.KeepName *;
}


# ProGuard and R8 rules for NeuroScript AI

# ML Kit Text Recognition
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google_mlkit_text_recognition.**
-keep class com.google.mlkit.vision.text.** { *; }
-keep interface com.google.mlkit.vision.text.** { *; }

# Image Picker
-dontwarn io.flutter.plugins.imagepicker.**
-keep class io.flutter.plugins.imagepicker.** { *; }

# Flutter's default ProGuard rules for release builds.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.**  { *; }

# Rules for Google Play Core Libraries (required for deferred components, etc.)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Mantener anotaciones necesarias
-keepattributes *Annotation*

# Mantener registrador de plugins de Flutter
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Mantener métodos usados por WebView con JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Mantener nombres útiles para depuración
-keepattributes SourceFile,LineNumberTable
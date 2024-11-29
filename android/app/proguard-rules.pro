# Include the generated missing rules here
# Example:
-keep class com.example.missing.ClassName { *; }
-dontwarn com.example.missing.**
-keepclassmembers class * {
    public <init>(...);
}
-keep public class * extends android.app.Activity

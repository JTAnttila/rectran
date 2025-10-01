# Add project specific ProGuard rules here.

# Keep Google Play Services Wearable classes
-keep class com.google.android.gms.wearable.** { *; }
-dontwarn com.google.android.gms.wearable.**

# Keep Compose classes
-keep class androidx.compose.** { *; }
-keep class androidx.wear.compose.** { *; }

# Keep MediaRecorder
-keep class android.media.MediaRecorder { *; }

# Keep coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

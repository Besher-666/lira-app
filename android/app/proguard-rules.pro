# حماية كود جلب وتحليل البيانات من التعتيم
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class com.google.gson.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# حماية حزم فلاتر الأساسية
-keep class io.flutter.** { *; }
# 🎯 حل مشكلة اختفاء كلاسات Play Core المسببة لفشل بناء الـ Release
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# حماية كلاسات تتبع المهام المرتبطة بها
-dontwarn com.google.android.play.core.tasks.**
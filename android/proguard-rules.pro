# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable
# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile
#########################################################################
# Retrofit 2
#########################################################################
-keepattributes Signature
-keepclassmembernames,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
#########################################################################
# OkHttp
#########################################################################
-dontwarn okhttp3.**
-dontwarn okhttp2.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
#-dontobfuscate
-optimizations !code/allocation/variable
-keep class company.tap.gosellapi.** { *; }
-keep public class gotap.com.tapglkitandroid.** { *; }
# GSON.
-keepnames class com.google.gson.** {*;}
-keepnames enum com.google.gson.** {*;}
-keepnames interface com.google.gson.** {*;}
-keep class com.google.gson.** { *; }
-keepnames class org.** {*;}
-keepnames enum org.** {*;}
-keepnames interface org.** {*;}
-keep class org.** { *; }
-keepclassmembers enum * { *; }

# Retrofit
-keepattributes Signature
-keepattributes RuntimeVisibleAnnotations
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }
-keepclassmembers class * {
    @retrofit2.http.* <methods>;
}

# OkHttp
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Gson
-keep class com.google.gson.** { *; }
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Signature

# Prevent stripping of your models (adjust the package name)
-keep class tap.company.go_sell_sdk_flutter.** { *; }
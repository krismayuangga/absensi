plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.attendance_kpi_mobile"
    compileSdk = 35  // Update ke SDK 35 sesuai rekomendasi plugin
    // ndkVersion = "27.0.12077973"  // Comment NDK version untuk menggunakan default

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8  // Turunkan ke Java 8
        targetCompatibility = JavaVersion.VERSION_1_8
        // isCoreLibraryDesugaringEnabled = true  // Disable untuk sementara
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()  // Update ke Java 8
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.attendance_kpi_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 35  // Update target SDK ke 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")  // Comment sementara
}

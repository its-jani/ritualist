plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.itsjani.ritualist"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Bytecode targets track the JDK that runs Gradle (17, see android/gradle.properties).
    // Keeping them aligned avoids the "Inconsistent JVM-target compatibility" check
    // firing when a plugin or the Flutter engine ships 17-level class files.
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.itsjani.ritualist"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release signing is opt-in: CI decodes upload-keystore.jks and injects the
    // ANDROID_KEYSTORE_* env vars (see .github/workflows/release.yml). Local debug
    // release builds without a keystore fall back to debug signing so `flutter run
    // --release` keeps working.
    val releaseKeystorePresent =
        file("upload-keystore.jks").exists() &&
            System.getenv("ANDROID_KEYSTORE_PASSWORD") != null &&
            System.getenv("ANDROID_KEY_ALIAS") != null &&
            System.getenv("ANDROID_KEY_PASSWORD") != null

    signingConfigs {
        create("release") {
            if (releaseKeystorePresent) {
                storeFile = file("upload-keystore.jks")
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (releaseKeystorePresent) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

flutter {
    source = "../.."
}

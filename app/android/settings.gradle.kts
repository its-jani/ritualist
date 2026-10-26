pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// Gradle 8.12 only runs on JVM 17..23. When Android Studio's bundled JBR (25.x)
// wins as JAVA_HOME, the launcher usually dies earlier with a bare "25.0.3" from
// native-platform; this guard is the readable version of that failure for any
// Gradle release that boots on a too-new JVM but then breaks AGP/Flutter below.
// How to pin the JDK: android/gradle.properties.
val gradleJvmMajor = JavaVersion.current().majorVersion.toInt()
if (gradleJvmMajor > 23) {
    throw GradleException(
        "Ritualist builds with Gradle 8.12, which cannot run on JVM $gradleJvmMajor. " +
            "Point the build at a JDK 17-21 install, e.g. " +
            "flutter config --jdk-dir=\"C:\\Program Files\\Java\\jdk-17\" " +
            "(CLI) or org.gradle.java.home in \${'$'}HOME/.gradle/gradle.properties " +
            "(Android Studio / ./gradlew).",
    )
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Kept in lockstep with gradle-wrapper.properties (AGP 8.9.1 requires Gradle >= 8.11.1).
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")

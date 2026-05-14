plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = (System.getenv("KEY_ALIAS") ?: keystoreProperties["keyAlias"]) as String?
            keyPassword = (System.getenv("KEY_PASSWORD") ?: keystoreProperties["keyPassword"]) as String?
            val storeFilePath = (System.getenv("STORE_FILE") ?: keystoreProperties["storeFile"]) as String?
            storeFile = if (storeFilePath != null) file(storeFilePath) else null
            storePassword = (System.getenv("STORE_PASSWORD") ?: keystoreProperties["storePassword"]) as String?
        }
    }

    buildTypes {
        release {
            // Ensure signing config is only applied if it's completely valid,
            // falling back to debug if no valid signing info exists (like in CI before secrets are added)
            val releaseConfig = signingConfigs.getByName("release")
            if (releaseConfig.storeFile != null && releaseConfig.storeFile?.exists() == true && releaseConfig.storePassword != null) {
                signingConfig = releaseConfig
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

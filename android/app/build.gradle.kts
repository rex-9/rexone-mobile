import java.io.File
import java.io.FileInputStream
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // AGP 9.0+ has built-in Kotlin compilation. The Flutter Gradle Plugin must be applied after the Android plugin.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase
    id("com.google.gms.google-services")
}

// Firebase dependencies are managed natively by Flutter plugins (firebase_core & firebase_analytics)
dependencies {
    // Required by 'flutter_local_notifications' (and 'background_downloader'):
    // Modern Android Gradle plugin requires core library desugaring to backport
    // Java 8+ APIs (such as java.time and streams) to older Android versions without runtime crashes.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

android {
    // Kotlin/Java code namespace (matches source package in MainActivity.kt).
    // Note: namespace MUST remain static across both Prod & UAT so Kotlin classes compile without
    // disk refactoring. The unique store package identifier is controlled via defaultConfig.applicationId below.
    namespace = "com.rex9.rexone"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Flag to enable Java 8+ API desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    // Resolve target environment from environment variables, project properties, or dart-defines
    val dartDefines = project.findProperty("dart-defines") as String?
    val targetEnvFromDefines = if (!dartDefines.isNullOrEmpty()) {
        dartDefines.split(",").mapNotNull {
            try {
                String(Base64.getDecoder().decode(it))
            } catch (_: Exception) {
                it
            }
        }.firstOrNull { it.startsWith("TARGET_ENV=") || it.startsWith("APP_ENV=") }?.substringAfter("=") ?: ""
    } else {
        ""
    }
    val targetEnv = System.getenv("TARGET_ENV") ?: project.findProperty("target_env") as String? ?: targetEnvFromDefines
    val isUat = targetEnv.contains("uat")

    defaultConfig {
        // Dynamically assigns package name, display name, and deep-link scheme for Prod vs UAT
        applicationId = if (isUat) "com.rex9.rexone.uat" else "com.rex9.rexone"
        manifestPlaceholders["appName"] = if (isUat) "RexOne UAT" else "RexOne"
        manifestPlaceholders["deepLinkScheme"] = if (isUat) "rexone-uat" else "rexone"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
    }

    val keystoreProps = Properties()
    val keyPropsFile = file("key.properties").takeIf { it.exists() } ?: file("../key.properties")
    if (keyPropsFile.exists()) {
        FileInputStream(keyPropsFile).use { keystoreProps.load(it) }
    }

    signingConfigs {
        create("release") {
            val configuredKeystore = file("../keystores/rexone-upload-keystore.jks")
            val keystoreFile = if (configuredKeystore.exists()) {
                configuredKeystore
            } else {
                file("../keystores").listFiles()?.firstOrNull { it.name.endsWith("-upload-keystore.jks") && !it.name.contains(".example") } ?: configuredKeystore
            }
            val storePass = System.getenv("KEYSTORE_PASSWORD") ?: keystoreProps.getProperty("storePassword")
            val keyPass = System.getenv("KEY_PASSWORD") ?: keystoreProps.getProperty("keyPassword") ?: storePass
            val alias = System.getenv("KEY_ALIAS") ?: keystoreProps.getProperty("keyAlias") ?: "upload"

            if (keystoreFile.exists() && !storePass.isNullOrEmpty()) {
                storeFile = keystoreFile
                storePassword = storePass
                keyAlias = alias
                keyPassword = keyPass
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.getByName("release")
            if (releaseConfig.storeFile?.exists() == true && !releaseConfig.storePassword.isNullOrEmpty()) {
                signingConfig = releaseConfig
            } else {
                throw GradleException("❌ Release signing failed: Keystore file or password missing. Please set android/key.properties or KEYSTORE_PASSWORD.")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
    }
}

flutter {
    source = "../.."
}

plugins {
    id("com.android.application")
    // AGP 9.0+ has built-in Kotlin compilation. The Flutter Gradle Plugin must be applied after the Android plugin.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase
    id("com.google.gms.google-services")
}

// Firebase dependencies are managed by flutter plugins (firebase_core & firebase_analytics)
// Somehow no need
// dependencies {
//   // Import the Firebase BoM
//   implementation(platform("com.google.firebase:firebase-bom:34.19.0"))


//   // TODO: Add the dependencies for Firebase products you want to use
//   // When using the BoM, don't specify versions in Firebase dependencies
//   implementation("com.google.firebase:firebase-analytics")


//   // Add the dependencies for any other desired Firebase products
//   // https://firebase.google.com/docs/android/setup#available-libraries
// }

dependencies {
    // Required by 'flutter_local_notifications' (and 'background_downloader'):
    // Modern Android Gradle plugin requires core library desugaring to backport
    // Java 8+ APIs (such as java.time and streams) to older Android versions without runtime crashes.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

android {
    namespace = "com.rex9.rexone" // $APPLICATION_ID
    compileSdk = 37
    // compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Flag to enable Java 8+ API desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rex9.rexone" // $APPLICATION_ID
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
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

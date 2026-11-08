plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.caller"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by the call_log plugin (uses java.time APIs which need
        // to be desugared for older Android versions).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.caller"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // CallScreeningService.onScreenCall + rejection APIs require Android 10 (API 29).
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Auto-copy the built APK to the Flutter project root after every build, so the
// latest app-release.apk / app-debug.apk is always sitting next to the project
// (the Gradle build dir is redirected to C:/b/caller, which is awkward to find).
// `flutter-apk` is produced by the Flutter Gradle plugin late in the build, so
// finalize the assemble tasks rather than copying eagerly.
val projectRoot = rootProject.projectDir.parentFile // .../caller
tasks.matching { it.name == "assembleRelease" || it.name == "assembleDebug" }
    .configureEach {
        doLast {
            val variant = if (name.contains("Release")) "release" else "debug"
            val apk = layout.buildDirectory.file("outputs/flutter-apk/app-$variant.apk").get().asFile
            if (apk.exists()) {
                apk.copyTo(File(projectRoot, "app-$variant.apk"), overwrite = true)
                println("Copied ${apk.name} -> ${projectRoot}\\app-$variant.apk")
            }
        }
    }

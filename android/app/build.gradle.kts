plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")  // no version here
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.navis.alarm_app" // <-- your package name
    compileSdk = 36

    defaultConfig {
        applicationId = "com.navis.alarm_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

flutter {
    source = "../.."
}

import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}



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




    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as String?
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            } else {
                println("⚠️ storeFile is null — check your key.properties path!")
            }
            storePassword = keystoreProperties["storePassword"] as String?
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false


        }
    }
    dependencies {
        implementation("org.jetbrains.kotlin:kotlin-stdlib")
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    }

    flutter {
        source = "../.."
    }
}

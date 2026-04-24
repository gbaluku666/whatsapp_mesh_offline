plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.whatsapp_mesh_offline"
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.whatsapp_mesh_offline"
        
        // These must be explicitly set as integers
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        
        // This is likely the "Line 26" culprit. We force it to an Int.
        val flutterVersionCode = project.findProperty("flutter.versionCode") as? String
        versionCode = flutterVersionCode?.toIntOrNull() ?: 1
        
        val flutterVersionName = project.findProperty("flutter.versionName") as? String
        versionName = flutterVersionName ?: "1.0"
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

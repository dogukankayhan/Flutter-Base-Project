plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.base.project"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.base.project"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationId = "com.base.project.dev"
            resValue("string", "app_name", "base project Dev")
            resValue("string", "base_url", "https://pokeapi.co/api/v2/")
            resValue("string", "google_server_client_id", "931829859624-3d5ib41gnn6stb9d3ffqlmeiqirfmc8a.apps.googleusercontent.com")
        }
        create("staging") {
            dimension = "environment"
            applicationId = "com.base.project.staging"
            resValue("string", "app_name", "base project Stage")
            resValue("string", "base_url", "https://pokeapi.co/api/v2/")
            resValue("string", "google_server_client_id", "931829859624-anjibo8ph93hlrrt3rl32gd18grhi02s.apps.googleusercontent.com")
        }
        create("prod") {
            dimension = "environment"
            applicationId = "com.base.project"
            resValue("string", "app_name", "base project")
            resValue("string", "base_url", "https://pokeapi.co/api/v2/")
            resValue("string", "google_server_client_id", "931829859624-94dg5gqdnj6vnbh7h3ktmmbt1r36eacb.apps.googleusercontent.com")
        }
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
    // Chucker - HTTP Inspector for Android
    debugImplementation("com.github.chuckerteam.chucker:library:4.0.0")
    releaseImplementation("com.github.chuckerteam.chucker:library-no-op:4.0.0")
}

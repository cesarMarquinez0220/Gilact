import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.gilact.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gilact.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Hardening: minSdk 29 (Android 10) para eliminar vulnerabilidades de versiones antiguas
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // --- Configuración de Signing para Release ---
    signingConfigs {
        create("release") {
            try {
                val keystorePropertiesFile = rootProject.file("key.properties")
                val keystoreProperties = Properties()
                
                if (keystorePropertiesFile.exists()) {
                    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                    
                    val keyAliasValue = keystoreProperties["keyAlias"] as String?
                    val keyPasswordValue = keystoreProperties["keyPassword"] as String?
                    val storePasswordValue = keystoreProperties["storePassword"] as String?
                    val keystorePath = keystoreProperties["storeFile"] as String?
                    
                    if (keyAliasValue != null && keyPasswordValue != null && 
                        storePasswordValue != null && keystorePath != null) {
                        keyAlias = keyAliasValue
                        keyPassword = keyPasswordValue
                        storePassword = storePasswordValue
                        // La ruta del keystore es relativa a android/app/
                        val keystoreFile = file(keystorePath)
                        if (keystoreFile.exists()) {
                            storeFile = keystoreFile
                        } else {
                            throw Exception("Keystore file not found: $keystorePath")
                        }
                    } else {
                        throw Exception("Missing required signing properties in key.properties")
                    }
                } else {
                    throw Exception("key.properties file not found. Release signing requires a keystore.")
                }
            } catch (e: Exception) {
                println("WARNING: Release signing configuration failed: ${e.message}")
                println("Falling back to debug signing. This should NOT be used in production!")
                // No lanzar excepción para permitir builds de desarrollo, pero registrar el error
            }
        }
    }

    buildTypes {
        release {
            // Configuración de signing para release
            signingConfig = signingConfigs.getByName("release")
            
            // Optimizaciones de MobSF: ofuscación y reducción de recursos
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
    
    // Nota: Los splits de ABI se manejan automáticamente por Flutter
    // cuando se usa: flutter build apk --split-per-abi --release
    // No es necesario configurarlos aquí para evitar conflictos en modo debug
    
    // Optimizaciones de compilación
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "/META-INF/DEPENDENCIES"
            excludes += "/META-INF/LICENSE"
            excludes += "/META-INF/LICENSE.txt"
            excludes += "/META-INF/license.txt"
            excludes += "/META-INF/NOTICE"
            excludes += "/META-INF/NOTICE.txt"
            excludes += "/META-INF/notice.txt"
            excludes += "/META-INF/ASL2.0"
            excludes += "/META-INF/*.kotlin_module"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

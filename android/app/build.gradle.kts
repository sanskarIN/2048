import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasDistributionSigning = keystorePropertiesFile.exists()

if (hasDistributionSigning) {
    FileInputStream(keystorePropertiesFile).use { stream ->
        keystoreProperties.load(stream)
    }
}

fun requiredSigningProperty(name: String): String {
    val value = keystoreProperties.getProperty(name)
    if (value.isNullOrBlank() || value.startsWith("REPLACE_WITH_")) {
        throw GradleException(
            "android/key.properties must define a real $name value before distribution signing.",
        )
    }
    return value
}

val distributionStoreFile = if (hasDistributionSigning) {
    rootProject.file(requiredSigningProperty("storeFile")).also { file ->
        if (!file.isFile) {
            throw GradleException(
                "Android distribution signing keystore does not exist: ${file.absolutePath}",
            )
        }
    }
} else {
    null
}

android {
    namespace = "com.sanskarin.nova_2048"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Stable Android application ID for 2048 Nova.
        applicationId = "com.sanskarin.nova_2048"
        // Keep SDK levels aligned with the Flutter toolchain selected by the project.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasDistributionSigning) {
            create("release") {
                keyAlias = requiredSigningProperty("keyAlias")
                keyPassword = requiredSigningProperty("keyPassword")
                storeFile = distributionStoreFile
                storePassword = requiredSigningProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // R8 + resource shrinking keep production APK/AAB output smaller and remove
            // Android code/resources that the release build cannot reach.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )

            // A local, ignored android/key.properties enables real distribution signing
            // without putting credentials or keystores in Git. Hosted qualification builds
            // intentionally fall back to the debug key so release-mode compilation can still
            // be verified in CI without distribution credentials.
            signingConfig = if (hasDistributionSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

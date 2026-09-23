import com.android.build.api.dsl.ApplicationExtension
import com.android.build.api.dsl.LibraryExtension
import com.android.build.api.variant.ApplicationAndroidComponentsExtension
import com.android.build.api.variant.LibraryAndroidComponentsExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// better_player ships compileSdk 34; wakelock_plus / package_info_plus need 36+.
// finalizeDsl runs after each module's own android {} block, so this sticks.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions
            .findByType(LibraryAndroidComponentsExtension::class.java)
            ?.finalizeDsl { extension: LibraryExtension ->
                if ((extension.compileSdk ?: 0) < 37) {
                    extension.compileSdk = 37
                }
            }
    }
    pluginManager.withPlugin("com.android.application") {
        extensions
            .findByType(ApplicationAndroidComponentsExtension::class.java)
            ?.finalizeDsl { extension: ApplicationExtension ->
                if ((extension.compileSdk ?: 0) < 37) {
                    extension.compileSdk = 37
                }
            }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Firebase
plugins {
  // ...

  // Add the dependency for the Google services Gradle plugin
  id("com.google.gms.google-services") version "4.5.0" apply false

}

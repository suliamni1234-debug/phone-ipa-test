allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Standard Flutter build-dir redirect: send Gradle output to the Flutter project's
// own build/ folder (../../build = <project>/build), which is exactly where
// `flutter run` looks for the apk. The previous config redirected to an external
// absolute path (C:/b/caller) for MAX_PATH reasons, but that broke apk discovery.
// Windows long-path support (LongPathsEnabled) is on, so the short path isn't needed.
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

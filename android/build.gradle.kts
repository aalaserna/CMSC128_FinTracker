allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Use the default Gradle build directories expected by Flutter.
// Overriding buildDirectory to a custom path can break tooling.

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

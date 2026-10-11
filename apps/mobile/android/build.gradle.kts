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
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    val configureCompileSdk = {
        val androidExt = project.extensions.findByName("android")
        if (androidExt != null) {
            for (m in androidExt.javaClass.methods) {
                if (m.name in listOf("setCompileSdk", "compileSdkVersion", "compileSdk")) {
                    try {
                        m.isAccessible = true
                        m.invoke(androidExt, 36)
                    } catch (_: Exception) {}
                }
            }
        }
    }

    if (project.state.executed) {
        configureCompileSdk()
    } else {
        project.afterEvaluate {
            configureCompileSdk()
        }
    }
}
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

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
    afterEvaluate {
        val androidExt = project.extensions.findByName("android")
        if (androidExt != null) {
            try {
                val method = androidExt.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                method.invoke(androidExt, 36)
            } catch (_: Exception) {
                try {
                    val method = androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    method.invoke(androidExt, 36)
                } catch (_: Exception) {}
            }
        }
    }
}
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

## Stack: Java

Detection markers: pom.xml, build.gradle, gradlew

- Detect package manager / build tool from project files; do not assume defaults.
- Prefer ./mvnw or ./gradlew when present
- Prefer scripts defined in the repository over global tooling.

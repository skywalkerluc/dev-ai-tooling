## Stack: .NET

Detection markers: *.csproj, *.sln

- Detect package manager / build tool from project files; do not assume defaults.
- Use dotnet CLI from repo root or solution directory
- Prefer scripts defined in the repository over global tooling.

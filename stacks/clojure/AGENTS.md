## Stack: Clojure

Detection markers: deps.edn, project.clj

- Detect package manager / build tool from project files; do not assume defaults.
- Use clojure -M:* or lein based on project layout
- Prefer scripts defined in the repository over global tooling.

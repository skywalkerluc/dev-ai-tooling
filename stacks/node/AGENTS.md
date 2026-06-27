## Stack: Node / TypeScript

Detection markers: package.json, lockfiles

- Detect package manager / build tool from project files; do not assume defaults.
- Infer npm/yarn/pnpm/bun from lockfile; warn if multiple lockfiles exist
- Prefer scripts defined in the repository over global tooling.

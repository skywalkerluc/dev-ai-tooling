## Stack: Python

Detection markers: pyproject.toml, requirements.txt, poetry.lock, uv.lock

- Detect package manager / build tool from project files; do not assume defaults.
- Prefer poetry/uv/pytest only when project files indicate them
- Prefer scripts defined in the repository over global tooling.

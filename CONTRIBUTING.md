# Contributing

1. Fork and branch from `main`.
2. Make your change; keep it small. The plugin is intentionally just `hooks/hooks.json` + one shell script.
3. Run `bash tests/cni.test.sh`, `shellcheck scripts/*.sh tests/*.sh` and `claude plugin validate .`.
4. Add a line under `## [Unreleased]` in `CHANGELOG.md`.
5. Open a PR (the template asks which terminal(s) you tested in).

## Docs

- `README.md` stays a landing page: pitch, install, config. Anything longer goes in `docs/`.
- Change behaviour, change the docs in the same PR.
- Images live in `docs/assets/` as SVG.

## Releases

Bump `version` in `.claude-plugin/plugin.json`, move the changelog entry under the new version, tag `vX.Y.Z`.

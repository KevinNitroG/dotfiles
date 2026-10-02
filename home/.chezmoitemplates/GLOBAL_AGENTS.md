## Tool can use

- `gh`: While need to do some operations on GitHub
- `jq`, `yq` for parsing JSON and YAML files
- Should prefer using mise to run pip/npx tools, example `mise exec npm:renovate@latest -- renovate`
- Prefer using `pnpm` over `npm` for global cases, except project require

## Behaviours

- Do not write unnecessary/obvious comments for the code can be implied itself
  > We are men, talk less, do more
- For technologies used, or asked, should prefer searching with websearch or context7 (ctx7) if need
- If context7 mcp is not available, use `ctx7` cli

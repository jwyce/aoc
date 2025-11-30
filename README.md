# Advent of Code 2025

Solutions in TypeScript (🥟 Bun) and 🐫 OCaml.

## Setup

```bash
bun install
```

Requires environment variables in `.env`:
- `AOC_COOKIE` - session cookie from adventofcode.com
- `AOC_REPO` - your repository URL
- `AOC_CONTACT` - your contact email

## Usage

```bash
# Fetch input and scaffold day (defaults to today in December)
bun run get [day]

# Run solutions
bun run day <day>
dune exec ./<DD>/solution.exe
```

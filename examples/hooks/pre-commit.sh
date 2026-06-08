#!/bin/bash
# Sample pre-commit hook for Vect-managed projects.
# Place under .vect/hooks/ or wire from your agent's hook config.
set -e

pnpm typecheck
pnpm test --silent
pnpm lint --max-warnings 0

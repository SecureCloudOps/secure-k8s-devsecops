#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 0 ]]; then
  for arg in "$@"; do
    case "$arg" in
      apply|destroy)
        echo "Apply/Destroy must be run via GitHub Actions workflow_dispatch"
        exit 1
        ;;
    esac
  done
fi

exit 0

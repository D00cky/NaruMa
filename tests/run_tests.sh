#!/usr/bin/env bash
cd "$(dirname "$0")/.."
exec bats tests/naruma_apps.bats tests/naruma_menu.bats tests/naruma_theme.bats tests/themes.bats tests/config.bats "$@"

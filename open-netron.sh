#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_MODEL='D:/Models/RVT2/model_99.pth'
MODEL_PATH="${1:-$DEFAULT_MODEL}"

if [[ ! -f "$SCRIPT_DIR/package.py" ]]; then
    echo "Error: package.py was not found in '$SCRIPT_DIR'." >&2
    exit 1
fi

if [[ ! -f "$MODEL_PATH" ]]; then
    echo "Error: model file was not found: $MODEL_PATH" >&2
    echo "Usage: $0 [MODEL_FILE]" >&2
    exit 1
fi

PYTHON=()

find_python() {
    local candidate

    for candidate in python3 python; do
        if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import sys' >/dev/null 2>&1; then
            PYTHON=("$candidate")
            return 0
        fi
    done

    if command -v py >/dev/null 2>&1 && py -3 -c 'import sys' >/dev/null 2>&1; then
        PYTHON=(py -3)
        return 0
    fi

    # Fallback for the Python runtime currently available on this Windows host.
    for candidate in \
        '/c/Program Files (x86)'/WXWork/*/WeComAgent/python/*/python.exe \
        'C:/Program Files (x86)'/WXWork/*/WeComAgent/python/*/python.exe; do
        if [[ -x "$candidate" ]] && "$candidate" -c 'import sys' >/dev/null 2>&1; then
            PYTHON=("$candidate")
            return 0
        fi
    done

    return 1
}

if ! find_python; then
    echo 'Error: no usable Python 3 interpreter was found.' >&2
    echo 'Install Python 3 or add python/python3/py to PATH.' >&2
    exit 1
fi

echo "Opening model: $MODEL_PATH"
echo 'Netron will run locally and open in the default browser.'

cd -- "$SCRIPT_DIR"
exec "${PYTHON[@]}" package.py build start "$MODEL_PATH" --browse

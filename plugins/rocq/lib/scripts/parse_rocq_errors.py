#!/usr/bin/env python3
"""Parse Rocq compiler errors to structured JSON.

Usage:
    parse_rocq_errors.py <error_output>

Reads coqc stderr output and produces structured JSON for the proof-repair agent.
"""

import json
import re
import sys


def parse_errors(text):
    """Parse coqc error output into structured records."""
    errors = []

    # Pattern: File "path", line N, characters C1-C2:
    # Error: message
    blocks = re.split(r'(?=File ")', text)

    for block in blocks:
        if not block.strip():
            continue

        loc_match = re.match(
            r'File "([^"]+)", line (\d+), characters (\d+)-(\d+):\s*\n(.*)',
            block, re.DOTALL
        )

        if loc_match:
            file_path = loc_match.group(1)
            line = int(loc_match.group(2))
            char_start = int(loc_match.group(3))
            char_end = int(loc_match.group(4))
            message = loc_match.group(5).strip()

            # Classify error type
            error_type = classify_error(message)

            errors.append({
                'file': file_path,
                'line': line,
                'char_start': char_start,
                'char_end': char_end,
                'errorType': error_type,
                'message': message,
            })

    return errors


def classify_error(message):
    """Classify a Rocq error message."""
    msg_lower = message.lower()

    if 'has type' in msg_lower and 'expected to have type' in msg_lower:
        return 'type_mismatch'
    if 'unable to unify' in msg_lower:
        return 'type_mismatch'
    if 'was not found' in msg_lower or 'not a defined object' in msg_lower:
        return 'unknown_ident'
    if 'no matching clauses' in msg_lower:
        return 'unsolved_goals'
    if 'universe inconsistency' in msg_lower:
        return 'universe_error'
    if 'cannot guess decreasing' in msg_lower:
        return 'termination'
    if 'timeout' in msg_lower or 'stack overflow' in msg_lower:
        return 'timeout'
    if 'admitted' in msg_lower:
        return 'admitted_present'
    if 'syntax error' in msg_lower:
        return 'syntax_error'

    return 'unknown'


def main():
    if len(sys.argv) < 2:
        text = sys.stdin.read()
    else:
        text = sys.argv[1]

    errors = parse_errors(text)
    print(json.dumps(errors, indent=2))


if __name__ == '__main__':
    main()

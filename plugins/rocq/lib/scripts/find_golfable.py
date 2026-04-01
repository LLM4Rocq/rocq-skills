#!/usr/bin/env python3
"""Find proof optimization opportunities in Rocq .v files.

Usage:
    find_golfable.py <file> [--filter-false-positives]

Outputs JSON array of golfable patterns found.
"""

import argparse
import json
import re
import sys
from pathlib import Path


def find_patterns(filepath, filter_fp=False):
    """Find golfable patterns in a .v file."""
    try:
        content = filepath.read_text(encoding='utf-8')
    except (OSError, UnicodeDecodeError):
        return []

    lines = content.splitlines()
    patterns = []

    for i, line in enumerate(lines, 1):
        stripped = line.strip()

        # Pattern: intros. reflexivity. → reflexivity.
        if stripped == 'intros.' and i < len(lines):
            next_line = lines[i].strip() if i < len(lines) else ''
            if next_line == 'reflexivity.':
                patterns.append({
                    'file': str(filepath),
                    'line': i,
                    'pattern': 'intros-reflexivity',
                    'before': 'intros. reflexivity.',
                    'after': 'reflexivity.',
                    'priority': 'high',
                    'savings': 1,
                })

        # Pattern: apply H. exact H'. → exact (H H').
        if re.match(r'\s*apply\s+\w+\s*\.', stripped):
            if i < len(lines):
                next_line = lines[i].strip() if i < len(lines) else ''
                if re.match(r'exact\s+\w+\s*\.', next_line):
                    patterns.append({
                        'file': str(filepath),
                        'line': i,
                        'pattern': 'apply-exact-chain',
                        'before': f'{stripped} {next_line}',
                        'after': 'exact (H H\').',
                        'priority': 'high',
                        'savings': 1,
                    })

        # Pattern: split. exact H1. exact H2. → exact (conj H1 H2).
        if stripped == 'split.':
            if i + 1 < len(lines):
                line2 = lines[i].strip() if i < len(lines) else ''
                line3 = lines[i + 1].strip() if i + 1 < len(lines) else ''
                if re.match(r'[-+*]?\s*exact\s+', line2) and re.match(r'[-+*]?\s*exact\s+', line3):
                    patterns.append({
                        'file': str(filepath),
                        'line': i,
                        'pattern': 'split-exact-pair',
                        'before': 'split. exact H1. exact H2.',
                        'after': 'exact (conj H1 H2).',
                        'priority': 'high',
                        'savings': 2,
                    })

        # Pattern: simpl. auto. → auto. (when auto subsumes)
        if stripped == 'simpl.' and i < len(lines):
            next_line = lines[i].strip() if i < len(lines) else ''
            if next_line == 'auto.':
                patterns.append({
                    'file': str(filepath),
                    'line': i,
                    'pattern': 'simpl-auto',
                    'before': 'simpl. auto.',
                    'after': 'auto.',
                    'priority': 'medium',
                    'savings': 1,
                })

        # Pattern: sequential rewrites
        if re.match(r'\s*rewrite\s+\w+\s*\.', stripped):
            if i < len(lines):
                next_line = lines[i].strip() if i < len(lines) else ''
                if re.match(r'rewrite\s+\w+\s*\.', next_line):
                    patterns.append({
                        'file': str(filepath),
                        'line': i,
                        'pattern': 'sequential-rewrite',
                        'before': 'rewrite H1. rewrite H2.',
                        'after': 'rewrite H1, H2.',
                        'priority': 'medium',
                        'savings': 1,
                    })

        # Pattern: omega → lia (deprecated tactic)
        if re.search(r'\bomega\b', stripped):
            patterns.append({
                'file': str(filepath),
                'line': i,
                'pattern': 'omega-to-lia',
                'before': 'omega.',
                'after': 'lia.',
                'priority': 'high',
                'savings': 0,
                'note': 'omega is deprecated, use lia',
            })

    return patterns


def main():
    parser = argparse.ArgumentParser(description='Find golfable patterns in Rocq files')
    parser.add_argument('file', help='File to analyze')
    parser.add_argument('--filter-false-positives', action='store_true',
                        help='Filter likely false positives')
    args = parser.parse_args()

    filepath = Path(args.file)
    if not filepath.exists():
        print(f"File not found: {args.file}", file=sys.stderr)
        sys.exit(1)

    patterns = find_patterns(filepath, filter_fp=args.filter_false_positives)
    print(json.dumps(patterns, indent=2))


if __name__ == '__main__':
    main()

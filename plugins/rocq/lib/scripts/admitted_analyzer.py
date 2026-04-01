#!/usr/bin/env python3
"""Find Admitted/admit in Rocq .v files with context.

Usage:
    admitted_analyzer.py <path> [--format=text|json|markdown|summary] [--report-only]

Outputs:
    text (default): Human-readable list
    json: Structured JSON
    markdown: Markdown table
    summary: Counts only
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path


def find_v_files(path):
    """Find all .v files under path."""
    p = Path(path)
    if p.is_file():
        return [p] if p.suffix == '.v' else []
    return sorted(p.rglob('*.v'))


def find_admitted(filepath):
    """Find Admitted/admit occurrences in a .v file."""
    results = []
    try:
        content = filepath.read_text(encoding='utf-8')
    except (OSError, UnicodeDecodeError):
        return results

    lines = content.splitlines()

    # Find the enclosing theorem/lemma/definition for context
    current_decl = None
    current_decl_line = None

    for i, line in enumerate(lines, 1):
        # Track current declaration
        decl_match = re.match(
            r'\s*(Theorem|Lemma|Proposition|Corollary|Fact|Remark|Definition|Fixpoint|'
            r'Program\s+Definition|Program\s+Fixpoint|Instance|Global\s+Instance|'
            r'Local\s+Instance)\s+(\w+)',
            line
        )
        if decl_match:
            current_decl = decl_match.group(2)
            current_decl_line = i

        # Find Admitted
        if re.search(r'\bAdmitted\s*\.', line):
            context_start = max(0, i - 6)
            context_end = min(len(lines), i + 2)
            context = '\n'.join(lines[context_start:context_end])

            results.append({
                'file': str(filepath),
                'line': i,
                'theorem': current_decl or '<unknown>',
                'theorem_line': current_decl_line,
                'type': 'Admitted',
                'context': context,
            })

        # Find admit tactic
        if re.search(r'\badmit\s*\.', line) and not re.search(r'\bAdmitted\s*\.', line):
            context_start = max(0, i - 6)
            context_end = min(len(lines), i + 2)
            context = '\n'.join(lines[context_start:context_end])

            results.append({
                'file': str(filepath),
                'line': i,
                'theorem': current_decl or '<unknown>',
                'theorem_line': current_decl_line,
                'type': 'admit',
                'context': context,
            })

    return results


def format_text(all_results):
    """Format results as human-readable text."""
    if not all_results:
        return "No Admitted/admit found."

    lines = []
    for r in all_results:
        lines.append(f"{r['file']}:{r['line']} ({r['type']}) in {r['theorem']}")
        for ctx_line in r['context'].splitlines():
            lines.append(f"  {ctx_line}")
        lines.append("")
    return '\n'.join(lines)


def format_json(all_results):
    """Format results as JSON."""
    return json.dumps({
        'total': len(all_results),
        'results': all_results,
    }, indent=2)


def format_markdown(all_results):
    """Format results as Markdown table."""
    if not all_results:
        return "No Admitted/admit found."

    lines = [
        "| File | Line | Theorem | Type |",
        "|------|------|---------|------|",
    ]
    for r in all_results:
        lines.append(f"| {r['file']} | {r['line']} | {r['theorem']} | {r['type']} |")
    return '\n'.join(lines)


def format_summary(all_results):
    """Format results as counts only."""
    if not all_results:
        return "Admitted: 0"

    files = set(r['file'] for r in all_results)
    admitted_count = sum(1 for r in all_results if r['type'] == 'Admitted')
    admit_count = sum(1 for r in all_results if r['type'] == 'admit')

    parts = [f"Admitted: {admitted_count}"]
    if admit_count:
        parts.append(f"admit: {admit_count}")
    parts.append(f"in {len(files)} file(s)")
    return ', '.join(parts)


def main():
    parser = argparse.ArgumentParser(description='Find Admitted/admit in Rocq files')
    parser.add_argument('path', help='File or directory to scan')
    parser.add_argument('--format', choices=['text', 'json', 'markdown', 'summary'],
                        default='text', help='Output format')
    parser.add_argument('--report-only', action='store_true',
                        help='Suppress exit 1 on findings')
    args = parser.parse_args()

    files = find_v_files(args.path)
    if not files:
        print(f"No .v files found in {args.path}", file=sys.stderr)
        sys.exit(1 if not args.report_only else 0)

    all_results = []
    for f in files:
        all_results.extend(find_admitted(f))

    formatters = {
        'text': format_text,
        'json': format_json,
        'markdown': format_markdown,
        'summary': format_summary,
    }
    print(formatters[args.format](all_results))

    if all_results and not args.report_only:
        sys.exit(1)


if __name__ == '__main__':
    main()

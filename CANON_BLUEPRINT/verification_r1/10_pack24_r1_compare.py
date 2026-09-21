#!/usr/bin/env python3
"""PACK ABI-24 R1 candidate comparator.

Input: normalized DUT JSONL, one row per case.
This comparator is a CANDIDATE and does not authorize historical PASS stamps.
"""
from __future__ import annotations
import argparse, json, pathlib, sys

HERE = pathlib.Path(__file__).resolve().parent
EXPECTED_PATH = HERE / '09_pack24_r1_expected.json'

def load_jsonl(path):
    rows = {}
    with open(path, 'r', encoding='utf-8') as f:
        for ln, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            obj = json.loads(line)
            cid = obj.get('case_id')
            if not cid:
                raise SystemExit(f'{path}:{ln}: missing case_id')
            if cid in rows:
                raise SystemExit(f'{path}:{ln}: duplicate case_id {cid}')
            rows[cid] = obj
    return rows

def norm_hex(v):
    if v is None:
        return None
    if isinstance(v, int):
        return f'{v:08x}'
    s = str(v).strip().lower()
    return s[2:] if s.startswith('0x') else s

def add_err(errors, cid, msg):
    errors.append(f'{cid}: {msg}')

def compare_row(exp, row, errors):
    cid = exp['case_id']
    if norm_hex(row.get('uart_token')) != exp['uart_token']:
        add_err(errors, cid, f"uart_token got={row.get('uart_token')} expected={exp['uart_token']}")
    if row.get('capture_valid') is not True:
        add_err(errors, cid, 'capture_valid != true')
    if row.get('overflow') is not False:
        add_err(errors, cid, 'overflow must be false')

    policy = exp['commit_policy']
    if policy == 'MUST_COMMIT_FLIP':
        if row.get('commit_event') is not True:
            add_err(errors, cid, 'commit_event != true')
        if row.get('same_capture_epoch') is not True:
            add_err(errors, cid, 'same_capture_epoch != true')
        b, a = norm_hex(row.get('generation_before')), norm_hex(row.get('generation_after'))
        if b is None or a is None:
            add_err(errors, cid, 'generation before/after must be observed')
        elif b == a:
            add_err(errors, cid, f'generation did not change ({b})')
        if row.get('generation_flipped') is not True:
            add_err(errors, cid, 'generation_flipped != true')
        if exp.get('require_destination_complete') and row.get('destination_complete') is not True:
            add_err(errors, cid, 'destination_complete != true')
    elif policy == 'MUST_NOT_COMMIT':
        if row.get('observation_window_complete') is not True:
            add_err(errors, cid, 'negative COMMIT proof requires observation_window_complete=true')
        if row.get('commit_count') != 0:
            add_err(errors, cid, f"commit_count got={row.get('commit_count')} expected=0")
        if row.get('commit_event') not in (False, None):
            add_err(errors, cid, 'commit_event must be false/null for MUST_NOT_COMMIT')
        if 'generation_flipped' in row and row.get('generation_flipped') is not None:
            add_err(errors, cid, 'generation_flipped must be absent/null when no COMMIT occurred')
    else:
        add_err(errors, cid, f'unknown commit policy {policy}')

    q = exp.get('query')
    if q:
        if row.get('query_status') != q['status']:
            add_err(errors, cid, f"query_status got={row.get('query_status')} expected={q['status']}")
        if row.get('query_reason') != q['reason']:
            add_err(errors, cid, f"query_reason got={row.get('query_reason')} expected={q['reason']}")
        if cid == 'PA24-G-04' and row.get('g04_lifecycle') != q['lifecycle']:
            add_err(errors, cid, 'G-04 lifecycle is not self-contained active-gen2→failed-B→stale-query')

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('dut_jsonl')
    args = ap.parse_args()
    expected = json.loads(EXPECTED_PATH.read_text(encoding='utf-8'))
    rows = load_jsonl(args.dut_jsonl)
    errors = []
    exp_map = {x['case_id']: x for x in expected['cases']}
    for cid, exp in exp_map.items():
        if cid not in rows:
            add_err(errors, cid, 'missing row')
            continue
        compare_row(exp, rows[cid], errors)
    extra = sorted(set(rows) - set(exp_map))
    if extra:
        errors.append('extra rows: ' + ', '.join(extra))
    if errors:
        print(f'PACK_ABI24_R1_CANDIDATE: FAIL ({len(errors)} findings)')
        for e in errors:
            print('FAIL', e)
        return 1
    print('PACK_ABI24_R1_CANDIDATE: 24/24 contract match')
    print('NOTE: candidate success does NOT authorize historical PACK_ABI_24_24_PASS.')
    return 0

if __name__ == '__main__':
    sys.exit(main())

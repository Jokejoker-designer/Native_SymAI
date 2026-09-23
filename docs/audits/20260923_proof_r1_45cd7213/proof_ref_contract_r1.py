"""Candidate proof_ref contract. Not Canon. Not an ANSWER authorization.

Canon §3.3 names the ProofObject fields and does not lock a binary layout.
Canon §2.4.4 names knowledge_state and does not lock its numeric enum.
This checker only accepts or rejects the reference shape below.
A shape that passes still has ANSWER_ALLOWED=NO.
"""

from __future__ import annotations


class ShapeError(Exception):
    def __init__(self, reason: str) -> None:
        super().__init__(reason)
        self.reason = reason


def check_shape(
    *,
    txn_id: int,
    generation: int,
    proof_ref: int,
    answer_ref: int,
    support_edge_refs: list[int],
    provenance_refs: list[int],
    context_match: int,
    timestamp: int,
    provenance_required: bool,
    bound_txn_id: int,
    bound_generation: int,
) -> str:
    """Return SHAPE_OK or raise ShapeError.

    proof_ref is a semantic id for this transaction and generation.
    It is not a T2 byte address. support_edge_refs are those addresses.
    """
    if proof_ref == 0:
        if support_edge_refs or provenance_refs:
            raise ShapeError("ZERO_PROOF_WITH_BODY")
        return "SHAPE_OK_NO_PROOF"
    if proof_ref in support_edge_refs:
        raise ShapeError("PROOF_REF_ALIASED_TO_EDGE_ADDRESS")
    if not support_edge_refs:
        raise ShapeError("PROOF_WITHOUT_SUPPORT")
    if len(support_edge_refs) > 3:
        raise ShapeError("SUPPORT_DEEPER_THAN_R1")
    if any(ref == 0 for ref in support_edge_refs):
        raise ShapeError("NULL_EDGE_IN_SUPPORT")
    if txn_id != bound_txn_id:
        raise ShapeError("TXN_MISMATCH")
    if generation != bound_generation:
        raise ShapeError("GENERATION_MISMATCH")
    if answer_ref == 0:
        raise ShapeError("PROOF_WITHOUT_ANSWER_REF")
    if timestamp == 0:
        raise ShapeError("MISSING_CREATION_TICK")
    if provenance_required and not provenance_refs:
        raise ShapeError("PROVENANCE_REQUIRED_MISSING")
    if context_match < 0:
        raise ShapeError("CONTEXT_MATCH_MISSING")
    return "SHAPE_OK_PROOF_BODY"


def answer_allowed(shape: str) -> str:
    if shape.startswith("SHAPE_OK"):
        return "NO"
    return "NO"


def run_cases() -> None:
    base = dict(
        txn_id=1,
        generation=2,
        proof_ref=0,
        answer_ref=0,
        support_edge_refs=[],
        provenance_refs=[],
        context_match=0,
        timestamp=0,
        provenance_required=False,
        bound_txn_id=1,
        bound_generation=2,
    )
    cases: list[tuple[str, dict, str]] = [
        ("no_proof", {}, "SHAPE_OK_NO_PROOF"),
        (
            "body_on_zero_proof",
            {"support_edge_refs": [0x20]},
            "ZERO_PROOF_WITH_BODY",
        ),
        (
            "alias_edge_address",
            {
                "proof_ref": 0x20,
                "answer_ref": 0x20100,
                "support_edge_refs": [0x20],
                "timestamp": 9,
            },
            "PROOF_REF_ALIASED_TO_EDGE_ADDRESS",
        ),
        (
            "proof_without_support",
            {"proof_ref": 0x51, "answer_ref": 0x20100, "timestamp": 9},
            "PROOF_WITHOUT_SUPPORT",
        ),
        (
            "txn_mismatch",
            {
                "proof_ref": 0x51,
                "answer_ref": 0x20100,
                "support_edge_refs": [0x20],
                "timestamp": 9,
                "bound_txn_id": 8,
            },
            "TXN_MISMATCH",
        ),
        (
            "generation_mismatch",
            {
                "proof_ref": 0x51,
                "answer_ref": 0x20100,
                "support_edge_refs": [0x20],
                "timestamp": 9,
                "bound_generation": 1,
            },
            "GENERATION_MISMATCH",
        ),
        (
            "missing_provenance",
            {
                "proof_ref": 0x51,
                "answer_ref": 0x20100,
                "support_edge_refs": [0x20],
                "timestamp": 9,
                "provenance_required": True,
            },
            "PROVENANCE_REQUIRED_MISSING",
        ),
        (
            "shape_with_body",
            {
                "proof_ref": 0x51,
                "answer_ref": 0x20100,
                "support_edge_refs": [0x20],
                "provenance_refs": [0x70],
                "context_match": 1,
                "timestamp": 9,
                "provenance_required": True,
            },
            "SHAPE_OK_PROOF_BODY",
        ),
    ]
    for name, patch, expect in cases:
        args = dict(base)
        args.update(patch)
        try:
            got = check_shape(**args)
        except ShapeError as exc:
            got = exc.reason
        if got != expect:
            raise SystemExit(f"CASE_FAIL {name} got {got} expect {expect}")
        if answer_allowed(got) != "NO":
            raise SystemExit(f"ANSWER_LEAK {name}")
        print(f"CASE {name} {got} ANSWER_ALLOWED=NO")
    print("KNOWLEDGE_STATE_ENUM_LOCKED=NO")
    print("CANON_PROOF_LAYOUT_LOCKED=NO")
    print("PROOF_REF_CONTRACT=CANDIDATE")
    print("ANSWER_ALLOWED=NO")
    print("PROOF_REF_CONTRACT_R1=PASS_CHECK")


if __name__ == "__main__":
    run_cases()

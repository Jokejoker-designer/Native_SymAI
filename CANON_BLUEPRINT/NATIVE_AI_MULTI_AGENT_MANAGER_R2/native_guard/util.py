from __future__ import annotations
import hashlib, json, os, pathlib, tempfile, time
from typing import Any, Iterable


def sha256_file(path: pathlib.Path, chunk: int = 1024 * 1024) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while True:
            b = f.read(chunk)
            if not b:
                break
            h.update(b)
    return h.hexdigest()


def canonical_json(obj: Any) -> str:
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def sha256_obj(obj: Any) -> str:
    return hashlib.sha256(canonical_json(obj).encode("utf-8")).hexdigest()


def atomic_write_text(path: pathlib.Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=path.name + ".", dir=str(path.parent))
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def atomic_write_json(path: pathlib.Path, obj: Any) -> None:
    atomic_write_text(path, json.dumps(obj, indent=2, sort_keys=True, ensure_ascii=False) + "\n")


def load_json(path: pathlib.Path, default: Any = None) -> Any:
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError, UnicodeDecodeError):
        return default


def utc_ts() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())


def safe_resolve(root: pathlib.Path, p: str | pathlib.Path) -> pathlib.Path:
    root = root.resolve()
    q = (root / p).resolve() if not pathlib.Path(p).is_absolute() else pathlib.Path(p).resolve()
    try:
        q.relative_to(root)
    except ValueError:
        raise ValueError(f"Path escapes project root: {q}")
    return q


def iter_files(root: pathlib.Path, include_suffixes: Iterable[str] | None = None, exclude_dirs: Iterable[str] = ()):
    ex = set(exclude_dirs)
    for p in root.rglob("*"):
        if not p.is_file():
            continue
        if any(part in ex for part in p.relative_to(root).parts):
            continue
        if include_suffixes and p.suffix.lower() not in set(x.lower() for x in include_suffixes):
            continue
        yield p

# 16 — CHANGE CONTROL AND VERSIONING

## 1. Mục tiêu

Ngăn “drift” do mỗi session tự sửa semantic schema.

## 2. Version classes

- Schema version
- ABI version
- Knowledge pack version
- RTL candidate version
- Checkpoint generation
- Vocabulary/adapter version

## 3. Breaking changes

Các thay đổi sau bắt buộc bump ABI/schema:

- node/relation ID reassignment
- record layout change
- direction/inverse semantics change
- value encoding change
- context/provenance interpretation change

## 4. Non-breaking changes

- thêm alias
- thêm fact mới dùng schema hiện tại
- thêm provenance records tương thích
- thêm source documents không thay semantics

## 5. Required artifacts per change

- CHANGELOG
- schema diff
- migration note
- validator result
- reference tests
- RTL/board evidence nếu implementation bị ảnh hưởng

## 6. Freeze rule

Historical Board Pass không bị rewrite. Artifact mới = lineage mới.

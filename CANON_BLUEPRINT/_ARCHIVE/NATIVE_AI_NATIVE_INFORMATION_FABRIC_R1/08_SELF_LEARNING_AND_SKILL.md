# 08 — SELF-LEARNING AND SKILL

## 1. Self-learning không ghi trực tiếp vào verified facts

Self-learning tạo hoặc cập nhật:

- learned scores/preferences
- affordance statistics
- candidate relations
- skill descriptors/policies
- failure prototypes
- episodes

## 2. Skill lifecycle

```text
CANDIDATE
→ LEARNED
→ VERIFIED
→ STABLE
→ COMPACTED
→ REOPENED if regression
```

Một procedure trong manual chưa phải Skill. Nó là static knowledge until executable behavior is bound and verified.

## 3. Credit rule

Chỉ action thực sự executed mới nhận credit.

`UNEXECUTED ACTION → ΔW = 0`

## 4. Static knowledge usage

Learner không cần “học lại” FACT.

Ví dụ FACT:

`GP11 --USES_REFRIGERANT--> R32`

Learner có thể học:

- khi goal X thì query relation này hữu ích
- action lookup này có utility cao

Không biến FACT thành weight.

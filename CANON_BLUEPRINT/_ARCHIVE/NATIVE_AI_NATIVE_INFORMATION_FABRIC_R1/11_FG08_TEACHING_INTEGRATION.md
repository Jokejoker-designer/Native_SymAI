# 11 — FG08 TEACHING INTEGRATION

## 1. Boundary

FG08 không được bypass verified knowledge authority.

Flow:

```text
UNKNOWN
→ ASK_TEACHER
→ candidate knowledge
→ verify
→ promote / reject / conflict
→ rerun original query
```

## 2. Candidate isolation

`TEACH != FACT`

Teacher proposal phải ở candidate store/plane riêng.

## 3. Native teaching

Teacher nên dạy bằng structured native code hoặc demonstration khi có thể:

- identity IDs
- relation IDs
- value/context
- action/effect trajectories

Human language chỉ là adapter giúp tạo candidate structured record.

## 4. Anti-parrot

Hệ thống chỉ được answer sau verification/promotion phù hợp; không được lặp lại nguyên teacher text như proof.

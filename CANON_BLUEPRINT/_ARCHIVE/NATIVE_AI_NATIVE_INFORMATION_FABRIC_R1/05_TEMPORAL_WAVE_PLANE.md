# 05 — TEMPORAL / WAVE PLANE

## 1. Khi nào dùng waveform/event

Dùng cho:

- sensor samples
- edge/event pulses
- GPIO/state changes
- action timing
- phase/frequency
- motor/actuator trajectories
- event ordering
- reward pulse/scalar
- before/after state streams

Không dùng waveform như thay thế cho exact semantic identity.

## 2. Primitive experience record

```text
Episode/Event:
  t0_state
  action_id
  action_params
  temporal_trace
  t1_state
  observed_effect
  reward
  context
  provenance
```

## 3. Dạy hành động bằng demonstration

Ví dụ bật LED3:

```text
before = 00000000
action = GPIO_WRITE(target=3, value=1)
after  = 00001000
reward = +1
```

Hệ thống có thể tạo candidate relation:

`ACTION_A --CAUSES--> EFFECT_B`

Tên “bật LED3” chỉ được gán sau qua alias.

## 4. 4-bit → 8-bit generalization

Không dạy bằng câu “0001 là một”.

Dạy bằng transition/structure:

```text
0000 → 0001
0001 → 0010
0010 → 0011
0011 → 0100
```

và primitives như carry/toggle/bit-position. Mục tiêu là học rule/composition, không memorization toàn bộ pattern.

## 5. Wave is evidence, not truth

Một pulse train không tự có meaning. Meaning đến từ source, context, before/after state và relation được kiểm chứng.

#!/usr/bin/env python3
"""两倍凯利边界的实算核对（DayTradingAgent `notes/cumulative-return-derivation.md` §7.3 修订用）

核实的两个数字：
  ① 文档例子（p=0.55, R_W=1.5, |R_L|=1）的精确 f*、g(2f*) 与真实临界点 f_c 的偏差；
  ② 随机扫描中 f_c > 2f* 的比例，以及最极端的反例参数。

运行：python3 scripts/twice-kelly-scan.py（约 2 分钟）
"""

import math
import random


def g(f: float, p: float, RW: float, RL: float) -> float:
    """两结果模型精确对数增长率 g(f) = p·ln(1+f·R_W) + q·ln(1−f·|R_L|)。"""
    return p * math.log(1 + f * RW) + (1 - p) * math.log(1 - f * RL)


def true_critical(p: float, RW: float, RL: float):
    """真实临界点 f_c：g(f*) 之后 g 的第二个零点（g 严格凹 ⇒ 唯一）。"""
    fs = p / RL - (1 - p) / RW  # 精确凯利
    a, b = fs, (1 / RL) * 0.999999
    for _ in range(200):  # 二分
        m = (a + b) / 2
        if g(m, p, RW, RL) > 0:
            a = m
        else:
            b = m
    return (a + b) / 2, fs


def main() -> None:
    # ① 文档例子
    p, RW, RL = 0.55, 1.5, 1.0
    fc, fs = true_critical(p, RW, RL)
    print(
        f"例子: f*={fs:.4f} 2f*={2 * fs:.4f} g(2f*)={g(2 * fs, p, RW, RL):+.4f} "
        f"真实 f_c={fc:.4f}（相对 2f* 偏差 {(fc / (2 * fs) - 1) * 100:+.2f}%）"
    )

    # ② 随机扫描：f_c > 2f* 的比例与最极端反例（与 2026-10-11 核对时同一随机序列）
    random.seed(1)
    n_valid = exceed = 0
    worst = None
    for _ in range(500_000):
        p = random.uniform(0.02, 0.98)
        RW = random.uniform(0.05, 20)
        RL = random.uniform(0.05, 20)
        if p * RW - (1 - p) * RL <= 0:  # 只统计 EV > 0
            continue
        fs = p / RL - (1 - p) / RW
        if not (0 < fs < 0.999999 / RL):  # 只统计 f* 落在可行区
            continue
        n_valid += 1
        a, b = fs, (1 / RL) * 0.999999
        if g(a, p, RW, RL) <= 0 or g(b, p, RW, RL) >= 0:
            continue
        for _ in range(200):
            m = (a + b) / 2
            if g(m, p, RW, RL) > 0:
                a = m
            else:
                b = m
        fc = (a + b) / 2
        if fc / (2 * fs) > 1 + 1e-12:
            exceed += 1
        if worst is None or fc / (2 * fs) > worst[0]:
            worst = (fc / (2 * fs), p, RW, RL, fs, fc)
    print(f"扫描: 有效 {n_valid} 组, f_c>2f* 共 {exceed} 组（{exceed / n_valid * 100:.1f}%）")
    print(
        f"最极端: f_c/(2f*)={worst[0]:.3f}  参数 p={worst[1]:.4f} R_W={worst[2]:.3f} |R_L|={worst[3]:.5f}"
    )
    print(
        f"        精确 f*={worst[4]:.4f} 2f*={2 * worst[4]:.4f} "
        f"g(2f*)={g(2 * worst[4], worst[1], worst[2], worst[3]):+.4f} f_c={worst[5]:.4f}"
    )


if __name__ == "__main__":
    main()

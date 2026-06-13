# shavit-telefrez

**Press-hold Teleport + Freeze** — 按住按键传送到检查点并冻结计时器与移动，松开后恢复。
A bhoptimer extension plugin: hold a key to teleport to your checkpoint and freeze the timer & movement, release to resume.

移植自 / Ported from [Shavit-Surf-Timer commit 1b62486e](https://github.com/bhopppp/Shavit-Surf-Timer/commit/1b62486e15f568399011b8cf8793e71ab50cc7e9)，以独立插件形式适配 [bhoptimer](https://github.com/shavitush/bhoptimer)，不修改任何核心文件。
Adapted for bhoptimer as a standalone extension — no core files modified.

## 功能 / Features

| Press / 按下 | Release / 松开 |
|--------------|----------------|
| 传送到当前检查点<br>Teleport to current checkpoint | 恢复碰撞 (`SOLID_BBOX`)<br>Restore collision |
| 冻结计时器<br>Pause timer | 重建移动速度<br>Rebuild movement speed |
| 移除碰撞 (`SOLID_NONE`)<br>Remove collision | 恢复计时器<br>Resume timer |
| 停止移动<br>Halt movement | — |

## 使用 / Usage

```
sm_save                          // 保存一个检查点 / save a checkpoint
bind <key> "+teleport"           // 绑定按键 / bind a key
```

## 依赖 / Dependencies

| Plugin | Info |
|--------|------|
| `shavit-core.smx` | bhoptimer 核心 / core |
| `shavit-checkpoints.smx` | 检查点系统 / checkpoint system |

## 编译环境 / Build Environment

| 组件 / Component | 版本 / Version |
|------------------|----------------|
| SourceMod | 1.12.0.7239 |
| SourcePawn Compiler | 1.12.0.7239 (spcomp64) |
| SourcePawn API | v1 = 5, v2 = 16 |
| Engine | Counter-Strike: Source (CS:S) |

## 编译 / Build

```bash
cd "<cs:s>/cstrike/addons/sourcemod/scripting"
./spcomp64.exe shavit-telefrez.sp -o../plugins/shavit-telefrez.smx
```

需要 bhoptimer 头文件 `core.inc` 和 `checkpoints.inc` 位于 `include/shavit/`。
Requires bhoptimer includes `core.inc` and `checkpoints.inc` under `include/shavit/`.

## 兼容性说明 / Compatibility

本插件**不使用 `cp_cache_t` 结构体操作**（如 `Shavit_GetCheckpoint`、`Shavit_LoadCheckpointCache`），仅使用索引型 native（`Shavit_GetCurrentCheckpoint`、`Shavit_TeleportToCheckpoint`），因此不受不同 include 版本间 `cp_cache_t` 二进制布局差异的影响，任何版本的 shavit includes 均可正常编译。

This plugin deliberately avoids `cp_cache_t` struct operations (e.g. `Shavit_GetCheckpoint`, `Shavit_LoadCheckpointCache`). It only uses index-based natives (`Shavit_GetCurrentCheckpoint`, `Shavit_TeleportToCheckpoint`), so `cp_cache_t` binary layout differences between include versions are irrelevant — the plugin compiles cleanly against any version of shavit includes.

## 开发 / Development

使用 Claude Code · DeepSeek 辅助开发。
Developed with the assistance of Claude Code · DeepSeek.

## 许可 / License

GPL-3.0 (inherited from bhoptimer / 继承自 bhoptimer)

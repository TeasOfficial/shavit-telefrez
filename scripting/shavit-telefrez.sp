/*
 * shavit-telefrez — Press-hold Teleport + Freeze
 * by: TeasOfficial
 *
 * 移植自 Shavit-Surf-Timer commit 1b62486e，以扩展插件形式适配 bhoptimer，无需修改核心文件。
 * Claude Code · DeepSeek 辅助开发。
 * Ported from Shavit-Surf-Timer, as a standalone extension — no core files modified.
 * Developed with the assistance of Claude Code · DeepSeek.
 *
 * 不使用 cp_cache_t 结构体操作（如 Shavit_GetCheckpoint / Shavit_LoadCheckpointCache），
 * 仅使用索引型 native（GetCurrentCheckpoint / TeleportToCheckpoint），
 * 因此不受 include 版本间 cp_cache_t 二进制布局差异影响，任何 shavit include 版本均可编译。
 * We deliberately avoid cp_cache_t struct operations — only index-based natives are used,
 * so the plugin compiles cleanly against any version of shavit includes.
 */

#include <sourcemod>
#include <shavit/core>
#include <shavit/checkpoints>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.1.0"

#define SOLID_NONE 0
#define SOLID_BBOX 2

public Plugin myinfo =
{
	name        = "[shavit] Teleport Freeze",
	author      = "TeasOfficial",
	description = "Pause movement & timer on press-hold teleport button",
	version     = PLUGIN_VERSION,
	url         = ""
};

chatstrings_t gS_ChatStrings;
bool         gB_Frozen[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("shavit-common.phrases");
	LoadTranslations("shavit-misc.phrases");

	RegConsoleCmd("+teleport", Command_TeleportPress,
		"Teleport to checkpoint, freeze timer & movement while held.");
	RegConsoleCmd("-teleport", Command_TeleportRelease,
		"Unfreeze timer & movement when released.");
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (gB_Frozen[i])
			UnfreezePlayer(i);
	}
}

public void Shavit_OnChatConfigLoaded()
{
	Shavit_GetChatStringsStruct(gS_ChatStrings);
}

public void OnClientDisconnect(int client)
{
	if (gB_Frozen[client])
		gB_Frozen[client] = false;
}

public Action Command_TeleportPress(int client, int args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "[shavit-telefrez] This command can only be used in-game.");
		return Plugin_Handled;
	}

	if (gB_Frozen[client])
		return Plugin_Handled;

	if (!IsPlayerAlive(client))
	{
		Shavit_PrintToChat(client, "%T", "CommandAlive",
			client, gS_ChatStrings.sVariable, gS_ChatStrings.sText);
		return Plugin_Handled;
	}

	if (Shavit_GetTimerStatus(client) != Timer_Running)
	{
		Shavit_PrintToChat(client, "%T", "CommandNoPause",
			client, gS_ChatStrings.sVariable, gS_ChatStrings.sText);
		return Plugin_Handled;
	}

	int cpIndex = Shavit_GetCurrentCheckpoint(client);
	if (cpIndex < 1)
	{
		Shavit_PrintToChat(client, "%T", "MiscCheckpointsEmpty",
			client, cpIndex, gS_ChatStrings.sWarning, gS_ChatStrings.sText);
		return Plugin_Handled;
	}

	Shavit_TeleportToCheckpoint(client, cpIndex, true, client);

	FreezePlayer(client);
	gB_Frozen[client] = true;

	return Plugin_Handled;
}

public Action Command_TeleportRelease(int client, int args)
{
	if (client == 0 || !gB_Frozen[client])
		return Plugin_Handled;

	// 延迟一帧恢复，避免与当前 tick 的移动处理冲突。
	// Defer one frame to avoid racing with current tick's movement processing.
	RequestFrame(Frame_Unfreeze, GetClientSerial(client));
	return Plugin_Handled;
}

void Frame_Unfreeze(int serial)
{
	int client = GetClientFromSerial(serial);
	if (client == 0 || !gB_Frozen[client])
		return;

	UnfreezePlayer(client);
	gB_Frozen[client] = false;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse,
	float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum,
	int &tickcount, int &seed, int mouse[2])
{
	if (!gB_Frozen[client] || !IsPlayerAlive(client))
		return Plugin_Continue;

	buttons = 0;
	impulse = 0;
	vel     = view_as<float>({0.0, 0.0, 0.0});
	angles[0] = 0.0;
	angles[1] = 0.0;

	return Plugin_Changed;
}

// 冻结：暂停计时器 + 移除碰撞 + 停止移动
// Freeze: pause timer + remove collision + halt movement
void FreezePlayer(int client)
{
	SetEntProp(client, Prop_Send, "m_nSolidType", SOLID_NONE);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
	Shavit_PauseTimer(client);
}

// 解冻：恢复碰撞 + 重建移动速度 + 恢复计时器
// Unfreeze: restore collision + rebuild movement speed + resume timer
void UnfreezePlayer(int client)
{
	SetEntProp(client, Prop_Send, "m_nSolidType", SOLID_BBOX);
	Shavit_UpdateLaggedMovement(client, true);

	if (Shavit_IsPaused(client))
		Shavit_ResumeTimer(client);
}

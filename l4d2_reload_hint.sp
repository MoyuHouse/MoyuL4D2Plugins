/*
 * @Author Rinsan
 */

#pragma semicolon 1
//強制1.7以後的新語法
#pragma newdecls required
#include <sourcemod>

#define CVAR_FLAGS	   FCVAR_NOTIFY
#define PLUGIN_VERSION "1.0.0"

int	   g_iEnabled, g_iHintThreshold, g_iGrenadeThreshold;
int	   g_playerHintStatues[64];
ConVar g_pluginEnabled, g_hintThreshold, g_grenadeThreshold;

public Plugin myinfo =
{
	name		= "l4d2_reload_hint",
	author		= "Rinsan",
	description = "换弹提示",
	version		= PLUGIN_VERSION,
	url			= "N/A"
};

public void OnPluginStart()
{
	HookEvent("weapon_reload", Event_WeaponReloaded);	 // 武器 Reload

	g_pluginEnabled = CreateConVar("l4d2_reload_hint_enabled", "1", "是否启用插件. 1=启用 0=禁用", FCVAR_NOTIFY);
	g_hintThreshold = CreateConVar("l4d2_reload_hint_threshold", "950", "当前备弹量提示阈值，当备弹量大于等于此值时进行提示", FCVAR_NOTIFY);
	g_grenadeThreshold = CreateConVar("l4d2_reload_hint_grenade_threshold", "24", "当前榴弹备弹量提示阈值，当备弹量小于等于此值时进行提示", FCVAR_NOTIFY);

	g_pluginEnabled.AddChangeHook(ConVarChangedReload);
	g_hintThreshold.AddChangeHook(ConVarChangedReload);
	g_grenadeThreshold.AddChangeHook(ConVarChangedReload);

	AutoExecConfig(true, "l4d2_reload_hint");	 //生成指定文件名的CFG.
}

//地图开始.
public void OnMapStart()
{
	GetConVarChange();
}

public void ConVarChangedReload(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetConVarChange();
}

void GetConVarChange()
{
	g_iEnabled		 = g_pluginEnabled.IntValue;
	g_iHintThreshold = g_hintThreshold.IntValue;
	g_iGrenadeThreshold = g_grenadeThreshold.IntValue;
	if (g_iHintThreshold < 0)
	{
		g_iHintThreshold = 0;
	}
	resetAllHintStatues();
}

void resetAllHintStatues()
{
	// 重置所有提示
	for (int i = 0; i < 64; i++)
	{
		g_playerHintStatues[i] = 0;
	}
}

public void Event_WeaponReloaded(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_iEnabled)
	{
		return;
	}
	int	 client = GetClientOfUserId(event.GetInt("userid"));
	int	 weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	char weaponName[32], weaponFullName[32];
	GetClientWeapon(client, weaponName, 32);
	if (IsValidClient(client) && GetClientTeam(client) == 2)
	{
		// 屏蔽手枪和马格南
		if (StrEqual(weaponName, "weapon_pistol") || StrEqual(weaponName, "weapon_pistol_magnum"))
		{
			return;
		}
		int currAmmo = GetAmmo(client, weapon);
		GetWeaponFullName(weaponName, weaponFullName);
		if (StrEqual(weaponName, "weapon_grenade_launcher"))
		{
			// 榴弹流程，不涉及修改低于阈值触发
			if (currAmmo <= g_iGrenadeThreshold)
			{
				PrintToChat(client, "\x04[提示]\x03所用武器: \x03%s\x04, \x05剩余备弹:\x03 %d\x05", weaponFullName, currAmmo);
			}
			return;
		}
		// 普通武器流程
		if (currAmmo >= g_iHintThreshold)
		{
			PrintToChat(client, "\x04[提示]\x03所用武器: \x03%s\x04, \x05剩余备弹:\x03 %d\x05", weaponFullName, currAmmo);
			g_playerHintStatues[client] = 1;
		}
		else {
			if (g_playerHintStatues[client] < 1)
			{
				return;
			}
			PrintToChat(client, "\x04[提示]\x03所用武器: \x03%s\x04, \x05剩余备弹:\x03 %d\x04, \x05已低于阈值: \x03%d\x04, \x05后续不再提示", weaponFullName, currAmmo, g_iHintThreshold);
			g_playerHintStatues[client] = 0;
		}
	}
}

void GetWeaponFullName(const char weaponClassName[32], char weaponName[32])
{
	weaponName = weaponClassName;
	if (StrEqual(weaponClassName, "weapon_smg"))
	{
		weaponName = "UZI";
	}
	else if (StrEqual(weaponClassName, "weapon_smg_silenced"))
	{
		weaponName = "MAC-10";
	}
	else if (StrEqual(weaponClassName, "weapon_smg_mp5"))
	{
		weaponName = "MP5";
	}
	else if (StrEqual(weaponClassName, "weapon_pumpshotgun"))
	{
		weaponName = "Pump Shotgun";
	}
	else if (StrEqual(weaponClassName, "weapon_shotgun_chrome"))
	{
		weaponName = "Chrome Shotgun";
	}
	else if (StrEqual(weaponClassName, "weapon_autoshotgun"))
	{
		weaponName = "Auto Shotgun";
	}
	else if (StrEqual(weaponClassName, "weapon_shotgun_spas"))
	{
		weaponName = "SPAS Shotgun";
	}
	else if (StrEqual(weaponClassName, "weapon_rifle"))
	{
		weaponName = "M4 Rifle";
	}
	else if (StrEqual(weaponClassName, "weapon_rifle_desert"))
	{
		weaponName = "Desert Rifle";
	}
	else if (StrEqual(weaponClassName, "weapon_rifle_ak47"))
	{
		weaponName = "AK47";
	}
	else if (StrEqual(weaponClassName, "weapon_hunting_rifle"))
	{
		weaponName = "Hunting Rifle";
	}
	else if (StrEqual(weaponClassName, "weapon_sniper_military"))
	{
		weaponName = "Sniper Military";
	}
	else if (StrEqual(weaponClassName, "weapon_rifle_sg552"))
	{
		weaponName = "SG552";
	}
	else if (StrEqual(weaponClassName, "weapon_sniper_awp"))
	{
		weaponName = "Sniper AWP";
	}
	else if (StrEqual(weaponClassName, "weapon_sniper_scout"))
	{
		weaponName = "Sniper Scout";
	}
	else if (StrEqual(weaponClassName, "weapon_rifle_m60"))
	{
		weaponName = "M60";
	}
	else if (StrEqual(weaponClassName, "weapon_grenade_launcher"))
	{
		weaponName = "Grenade Launcher";
	}
}

int GetAmmo(int client, int iWeapon)
{
	int iAmmoType = GetEntProp(iWeapon, Prop_Send, "m_iPrimaryAmmoType");
	if (iAmmoType != -1)
	{
		return GetEntProp(client, Prop_Send, "m_iAmmo", _, iAmmoType);
	}
	else
	{
		return -1;
	}
}

bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client));
}

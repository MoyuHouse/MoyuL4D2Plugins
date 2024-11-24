/*
 * @Author Rinsan
 */

#pragma semicolon 1
//強制1.7以後的新語法
#pragma newdecls required
#include <sourcemod>

#define CVAR_FLAGS	   FCVAR_NOTIFY
#define PLUGIN_VERSION "1.0.0"

int	   g_iEnabled;
ConVar g_pluginEnabled;

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

	g_pluginEnabled.AddChangeHook(ConVarChangedReload);

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
	g_iEnabled = g_pluginEnabled.IntValue;
}

public void Event_WeaponReloaded(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_iEnabled)
	{
		return;
	}
	int client = GetClientOfUserId(event.GetInt("userid"));
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	char weaponName[32];
	GetClientWeapon(client, weaponName, 32);
	if (IsValidClient(client) && GetClientTeam(client) == 2)
	{
		int currAmmo = GetAmmo(client, weapon);
		if (currAmmo > 0)
		{
			PrintToChat(client, "Current weapon: %s, Reversed Ammo: %d", weaponName,  currAmmo);
		}
	}
}

int GetAmmo(int client, int iWeapon)
{
	int iAmmoType = GetEntProp(iWeapon, Prop_Send, "m_iPrimaryAmmoType");
	if (iAmmoType != -1)
	{
		return GetEntProp(client, Prop_Send, "m_iAmmo", 4, iAmmoType);
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

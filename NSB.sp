#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>

static Handle RoundTimer = null;
int count;

Handle timer_handle[MAXPLAYERS + 1] = {INVALID_HANDLE, ...};
bool SpawnProtection = false;
bool AlreadyUnprotected[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "[NEKO] Surf Combat",
	author = "NEKO",
	description = "surfCombat plugin",
	version = "1.0"
};


public void OnPluginStart()
{
	HookEvent("player_team", Player_Notifications, EventHookMode_Pre);
	HookEvent("round_prestart", round_prestart);
	HookEvent("player_death", Event_Death);
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("weapon_fire", Event_WeaponFire);
}

public void OnMapStart()
{
	ServerCommand("sv_enablebunnyhopping 1");
	ServerCommand("sv_autobunnyhopping 1");
	ServerCommand("mp_buytime 90000");
	ServerCommand("sv_alltalk 1;mp_solid_teammates 2");
	ServerCommand("sv_allow_votes 0;sv_alltalk 1;sv_deadtalk 1;sv_pure 0;sv_gravity 800;sv_accelerate 5;sv_friction 4;sv_airaccelerate 2000;sv_ladder_scale_speed 1;sv_clamp_unsafe_velocities 0;sv_staminajumpcost 0;sv_staminalandcost 0;sv_maxvelocity 10000;")
}

public Action round_prestart(Event event, const char[] name, bool dontBroadcast)
{
	CloseEsp();
	SpawnProtection = true;
	int ent = -1;
	while((ent = FindEntityByClassname(ent, "trigger_teleport")) != -1)
	{
		HookSingleEntityOutput(ent, "OnStartTouch", Output_TeleStartTouch)
   	}
}

public Action Event_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	if(!SpawnProtection)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		if(timer_handle[client] != INVALID_HANDLE)
		{
			timer_handle[client] = INVALID_HANDLE;
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			AlreadyUnprotected[client] = true;
		}
	}
}

public Action Timer_GodMode(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	
	if(!client)
		return Plugin_Stop;
	
	if(IsClientInGame(client))
	{
		
		if(AlreadyUnprotected[client])
		{
			AlreadyUnprotected[client] = false;
		}
		else
		{
			// If the player is with god mode, it will disable it;
			if(timer != INVALID_HANDLE)
			{
				timer_handle[client] = INVALID_HANDLE;
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			}
		}
	}
	return Plugin_Stop;
}

public Output_TeleStartTouch(const char[] output, int caller, int activator, float delay)
{
	if(!SpawnProtection)
	{	
		if(timer_handle[activator] == INVALID_HANDLE && GetEntProp(activator, Prop_Data, "m_takedamage") == 2)
		{
			SetEntProp(activator, Prop_Data, "m_takedamage", 0, 1);
			timer_handle[activator] = CreateTimer(1.5, Timer_GodMode, GetClientUserId(activator));
		}
	}
}

public Action Player_Notifications(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	RemoveRagdoll(client);
	return Plugin_Continue;
}

public Action Event_Death(Event event, char[] name, bool dontBroadcast) 
{ 
	CheckAlive();
	int client = GetClientOfUserId(event.GetInt("userid"));
	RemoveRagdoll(client);
}

void RemoveRagdoll(int client)
{
	int iEntity = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");

	if(iEntity != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(iEntity, "Kill");
	}
}

void CheckAlive()
{
	if (GameRules_GetProp("m_bWarmupPeriod"))
		return;
	int g_iTeamCT, g_iTeamT;
	for (int i = 1; i <= MaxClients; i++) 
	{
		if(IsValidClient(i) && IsPlayerAlive(i)) 
		{
			if(GetClientTeam(i) == CS_TEAM_CT) 
				g_iTeamCT++; 
			else if(GetClientTeam(i) == CS_TEAM_T)
				g_iTeamT++; 
		} 
	}
	if( g_iTeamCT==1 && g_iTeamT == 1 )
		TriggerEsp();
}

void TriggerEsp()
{
	PrintToChatAll("Trigger");
	if (RoundTimer != null)
        KillTimer(RoundTimer);
	RoundTimer = CreateTimer(1.0, ESP, _, TIMER_REPEAT);
}

public Action ESP(Handle timer)
{
	if (count == 3)
	{
		for(int client = 1; client <= MaxClients; ++client)
		{
			if (IsValidClient(client) && IsPlayerAlive(client))
				SetEntPropFloat(client, Prop_Send, "m_flDetectedByEnemySensorTime", 9999999.0);
		}
	}
	if(count > 4)
		count = 1;
	else
		count++;

	if(count < 3)
	{
		for(int client = 1; client <= MaxClients; ++client)
		{
			if (IsValidClient(client) && IsPlayerAlive(client))
				SetEntPropFloat(client, Prop_Send, "m_flDetectedByEnemySensorTime", 0.0);
		}
	}
}

void CloseEsp()
{
	if (RoundTimer != null)
        KillTimer(RoundTimer);
	RoundTimer = null;
}

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flDetectedByEnemySensorTime", 0.0);
		float freezetime = float(GetConVarInt(FindConVar("mp_freezetime")));
		CreateTimer(freezetime, TIMER_GOD, client, TIMER_FLAG_NO_MAPCHANGE);
		RequestFrame(RemoveGuns,client);
	}
}

public void OnClientPutInServer(int client)
{
	if (!IsValidClient(client))
	{
		return;
	}
	AlreadyUnprotected[client] = false;
	//SDKHook(client, SDKHook_PreThink, PreThink);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SendConVar(client);
}

void SendConVar(int client)
{
	char Values[10];
	IntToString(0, Values, 10);
	SendConVarValue(client, FindConVar("weapon_recoil_scale")             ,Values);
	//thanks Franc1sco form SM Aimbot
}

public Action OnTakeDamage(victim, &attacker, &inflictor, float &damage, &damagetype)
{
	if(damagetype & DMG_FALL)
	{
		return Plugin_Handled;
	}
	if (IsValidClient(attacker)) {
		if (GetEntProp(victim, Prop_Send, "m_bInBuyZone")) {
			PrintToChat(attacker,"无法射击在购买的玩家");
			return Plugin_Handled;
		}
		if (GetEntProp(attacker, Prop_Send, "m_bInBuyZone")) {
			PrintToChat(attacker,"在购买时无法伤害别的玩家");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}  

public Action TIMER_GOD(Handle timer,int client)
{
	SetEntProp(client, Prop_Data, "m_takedamage", 0);
	SetEntityRenderColor(client, 0, 0, 255, 255);
	CreateTimer(2.5, TIMER_removeGod, client);
}

public Action TIMER_removeGod(Handle timer,int client)
{
	SetEntProp(client, Prop_Data, "m_takedamage", 2);
	SetEntityRenderColor(client, 255, 255,255, 255);
	SpawnProtection = false;
}

void RemoveGuns(int client)
{
	int WpnId = GetPlayerWeaponSlot(client,0);
	if (WpnId!=-1)
	{
		RemovePlayerItem(client, WpnId);
		AcceptEntityInput(WpnId, "Kill");
	}
	
	WpnId = GetPlayerWeaponSlot(client,1);
	if (WpnId!=-1)
	{
		RemovePlayerItem(client, WpnId);
		AcceptEntityInput(WpnId, "Kill");
	}
	
	WpnId = GetPlayerWeaponSlot(client,2);
	while (WpnId!=-1)
	{
		RemovePlayerItem(client, WpnId);
		AcceptEntityInput(WpnId, "Kill");
		WpnId = GetPlayerWeaponSlot(client,2);
	}
	
	WpnId = GetPlayerWeaponSlot(client,3);
	while (WpnId!=-1)
	{
		RemovePlayerItem(client, WpnId);
		AcceptEntityInput(WpnId, "Kill");
		WpnId = GetPlayerWeaponSlot(client,3);
	}
	
	GivePlayerItem(client,"weapon_knife");
	GivePlayerItem(client,"weapon_snowball");
}

stock bool IsValidClient( client )
{
	if ( client < 1 || client > MaxClients ) return false;
	if ( !IsClientConnected( client )) return false;
	if ( !IsClientInGame( client )) return false;
	if ( IsFakeClient(client)) return false;
	return true;
}
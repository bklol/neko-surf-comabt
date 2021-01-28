#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

public Plugin myinfo = {
    name = "surfcombat server plugin",
    author = "neko aka bklol",
    description = "surfcombat server plugin",
    version = "0.1",
    url = "https://github.com/bklol"
};

public void OnMapStart() 
{
	CreateTimer(6000.0, ChangeMap,_,TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(5000.0, voteMap,_,TIMER_FLAG_NO_MAPCHANGE);
}

public Action voteMap(Handle timer)
{
	ServerCommand("sm_mapvote");
}

public Action ChangeMap(Handle sb)
{
	ForceWinPanel();
}

void ForceWinPanel()
{
    StringMap smReset = new StringMap();
    
    ConVar cTimeLimit = FindConVar("mp_timelimit");
    smReset.SetValue("mp_timelimit", cTimeLimit.IntValue, true);
    cTimeLimit.IntValue = 1;
    
    ConVar cMaxOverTimeRounds = FindConVar("mp_overtime_maxrounds");
    smReset.SetValue("mp_overtime_maxrounds", cMaxOverTimeRounds.IntValue, true);
    cMaxOverTimeRounds.IntValue = 0;
    
    ConVar cOverTimeEnabled = FindConVar("mp_overtime_enable");
    smReset.SetValue("mp_overtime_enable", cOverTimeEnabled.BoolValue, true);
    cOverTimeEnabled.BoolValue = false;
    
    ConVar cIgnoreWinConditions = FindConVar("mp_ignore_round_win_conditions");
    smReset.SetValue("mp_ignore_round_win_conditions", cIgnoreWinConditions.BoolValue, true);
    cIgnoreWinConditions.BoolValue = false;
    
    SetTeamScoreProper(CS_TEAM_T, 15);
    SetTeamScoreProper(CS_TEAM_CT, 15);
    
    ConVar cMaxRounds = FindConVar("mp_maxrounds");
    smReset.SetValue("mp_maxrounds", cMaxRounds.IntValue, true);
    cMaxRounds.IntValue = GetRoundNumber();
    
    ConVar cRoundRestartDelay = FindConVar("mp_round_restart_delay");
    smReset.SetValue("mp_round_restart_delay", cRoundRestartDelay.IntValue, true);
    cRoundRestartDelay.IntValue = 0
    
    CS_TerminateRound(0.0, CSRoundEnd_Draw, true);
    RequestFrame(Frame_ResetConVars, smReset);
}

void Frame_ResetConVars(StringMap smReset)
{
	int iTimeLimit; smReset.GetValue("mp_timelimit", iTimeLimit);
	int iMaxOverTimeRounds; smReset.GetValue("mp_overtime_maxrounds", iMaxOverTimeRounds);
	bool bOverTimeEnabled; smReset.GetValue("mp_overtime_enable", bOverTimeEnabled);
	bool bIgnoreWinConditions; smReset.GetValue("mp_ignore_round_win_conditions", bIgnoreWinConditions);
	int iMaxRounds; smReset.GetValue("mp_maxrounds", iMaxRounds);
	int iRoundRestartDelay; smReset.GetValue("mp_round_restart_delay", iRoundRestartDelay);
		
	delete smReset;
	
	FindConVar("mp_timelimit").IntValue = iTimeLimit;
	FindConVar("mp_overtime_maxrounds").IntValue = iMaxOverTimeRounds;
	FindConVar("mp_overtime_enable").BoolValue = bOverTimeEnabled;
	FindConVar("mp_ignore_round_win_conditions").BoolValue = bIgnoreWinConditions;
	FindConVar("mp_maxrounds").IntValue = iMaxRounds;
	FindConVar("mp_round_restart_delay").IntValue = iRoundRestartDelay;
}


int GetRoundNumber() {
    return GetTeamScore(CS_TEAM_T) + GetTeamScore(CS_TEAM_CT);
}

bool SetTeamScoreProper(int iTeam, int iScore)
{
    if (iTeam < CS_TEAM_T || iTeam > CS_TEAM_CT) {
        return false;
    }
    
    SetTeamScore(iTeam, iScore);
    CS_SetTeamScore(iTeam, iScore);
    GameRules_SetProp("m_totalRoundsPlayed", GetRoundNumber());
    
    return GetTeamScore(iTeam) == iScore;
} 

public Action CS_OnTerminateRound(float& delay, CSRoundEndReason& reason)
{
    return Plugin_Handled;
}


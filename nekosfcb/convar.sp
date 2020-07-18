
#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <overlays>
#include <clientprefs>

#define Killone "overlays/kill/kill_1"
#define Killtwo "overlays/kill/kill_2"
#define Killthree "overlays/kill/kill_3"
#define Killfour "overlays/kill/kill_4"
#define Killfive "overlays/kill/kill_5"

char WpNameFst[24][]=
{
	"weapon_ak47","weapon_m4a1","weapon_m4a1_silencer","weapon_awp","weapon_ssg08","weapon_negev",
	"weapon_mac10","weapon_mp9","weapon_mp7","weapon_p90","weapon_ump45","weapon_bizon",
	"weapon_nova","weapon_xm1014","weapon_galilar","weapon_famas","weapon_sg556","weapon_aug",
	"weapon_sawedoff","weapon_m249","weapon_mag7","weapon_g3sg1","weapon_scar20","weapon_mp5sd"
}

char WpNameSec[10][]=
{
	"weapon_glock","weapon_hkp2000","weapon_deagle","weapon_p250","weapon_elite","weapon_cz75a",
	"weapon_tec9","weapon_fiveseven","weapon_usp_silencer","weapon_revolver"
}

char WpnCnNamePri[24][]=
{
	"AK-47","M4A4","M4A1 Silencer","AWP","SSG 08","Negev",
	"MAC-10","MP9","MP7","P90","UMP-45","PP-Bizon",
	"Nova","XM1014","Galil AR","FAMAS","SG 553","AUG",
	"Sawed-Off","M249","MAG-7","G3SG1","SCAR-20","MP5-SD"
}

char WpnCnNameSec[10][]=
{
	"Glock-18","P2000","Desert Eagle","P250","Dual Berettas","CZ75 Auto",
	"Tec-9","Five-SeveN","USP Silencer","R8 Revolver"
}

char g_szAuth[MAXPLAYERS + 1][32];
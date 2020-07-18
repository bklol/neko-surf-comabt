
#include "nekosfcb/convar.sp"
#include "nekosfcb/neko.sp"
#include "nekosfcb/sql.sp"
#include "nekosfcb/global.sp"
#include "nekosfcb/native.sp"
#include "nekosfcb/function.sp"

public void OnPluginStart()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
			OnClientPostAdminCheck(i);
	}
}
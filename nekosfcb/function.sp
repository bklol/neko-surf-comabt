public Event_WeaponDrop(client, weapon)
{
	if(IsValidEntity(weapon))
		CreateTimer(0.1, removeWeapon, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
}

public Action removeWeapon(Handle hTimer, any iWeaponRef)
{
    static weapon;
	weapon = EntRefToEntIndex(iWeaponRef);
    if(iWeaponRef == INVALID_ENT_REFERENCE || !IsValidEntity(weapon)|| weapon < 0)
		return;
    AcceptEntityInput(weapon, "kill");
}
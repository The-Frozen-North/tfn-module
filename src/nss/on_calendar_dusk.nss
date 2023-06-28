void SpawnWerewolfIfNonexistent(string sName)
{
	object oOld = GetObjectByTag("werewolf_" + sName);
	if (GetIsObjectValid(oOld) && !GetIsDead(oOld))
	{
		return;
	}
	if (GetIsObjectValid(oOld) && GetIsDead(oOld))
	{
		DestroyObject(oOld);
	}
	object oWP = GetWaypointByTag("wp_werewolf_" + sName);
    object oWW = CreateObject(OBJECT_TYPE_CREATURE, sName, GetLocation(oWP));	
}

void main()
{
	// Spawn werewolves!
	SpawnWerewolfIfNonexistent("geth");
	SpawnWerewolfIfNonexistent("bran");
    // hb_qwerewolf deals with despawning them again during the day
}
void KillTheSkeles()
{
    object oArea = GetArea(OBJECT_SELF);
    int i;
    for (i=1; i<=10; i++)
    {
        object oSkele = GetLocalObject(oArea, "hh_skeletons_" + IntToString(i));
        if (GetIsObjectValid(oSkele) && !GetIsDead(oSkele))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH_L), oSkele);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(9999), oSkele);
        }
    }
}

void main()
{
    KillTheSkeles();
    // Respawned liches are not cleared by the normal script
    object oLich = GetObjectByTag("hh_lich");
    int n = 0;
    while (GetIsObjectValid(oLich))
    {
        DestroyObject(oLich);
        n++;
        oLich = GetObjectByTag("hh_lich", n);
    }
    // But that also deletes the natural lich...
    CreateObject(OBJECT_TYPE_CREATURE, "lich_hh", GetLocation(GetWaypointByTag("HH_LichSpawn")));
    
	// Spawn targets for the beams to shoot at when making skeles, if they don't exist
    object oWP = GetWaypointByTag("HH_LichSpawn");
        
    if (!GetIsObjectValid(GetObjectByTag("HH_LichCentralPoint")))
    {
        CreateObject(OBJECT_TYPE_PLACEABLE, "invisibleobject", GetLocation(oWP), FALSE, "HH_LichCentralPoint");
        vector vCircle = GetPosition(oWP);
        object oCircle = CreateObject(OBJECT_TYPE_PLACEABLE, "x2_plc_scircle", Location(GetArea(OBJECT_SELF), vCircle, 180.0), FALSE, "HH_SummoningCircle");
        SetPlotFlag(oCircle, TRUE);
    }
    object oLoot = GetObjectByTag("HH_LichLoot");
    if (GetIsObjectValid(oLoot))
    {
        DestroyObject(oLoot);
    }
	int j;
	for (j=1; j<=5; j++)
	{
		oWP = GetWaypointByTag("HH_LichSkeleSpawn" + IntToString(j));
        DeleteLocalInt(oWP, "HH_WaypointUsed");
		object oTarget = GetLocalObject(oWP, "HH_LichBeamTarget");
		if (!GetIsObjectValid(oTarget))
		{
            //oTarget = CreateObject(OBJECT_TYPE_PLACEABLE, "x0_rodwonder", GetLocation(oWP));
            oTarget = CreateObject(OBJECT_TYPE_PLACEABLE, "invisibleobject", GetLocation(oWP));
            SetLocalObject(oWP, "HH_LichBeamTarget", oTarget);
		}
    }
	// Spawn phylactery
    object oOld = GetObjectByTag("HH_LichPhylactery");
    if (GetIsObjectValid(oOld))
    {
        DestroyObject(oOld);
    }
	oWP = GetWaypointByTag("HH_PhylacterySpawn");
    CreateObject(OBJECT_TYPE_PLACEABLE, "hh_phylactery", GetLocation(oWP));
}
void main()
{
    object oWP = GetWaypointByTag("maker4_exitportal");
    object oPortal = CreateObject(OBJECT_TYPE_PLACEABLE, "portalblue", GetLocation(oWP));
    SetPlotFlag(oPortal, 1);
    SetEventScript(oPortal, EVENT_SCRIPT_PLACEABLE_ON_USED, "maker_portal");
    SetLocalObject(GetArea(oPortal), "exit_portal", oPortal);
    object oArea = GetArea(oWP);
    json jGolems = GetLocalJson(oArea, "maker_golems");
    int i;
    int nLength = JsonGetLength(jGolems);
    object oKiller = GetLastKiller();
    if (!GetIsObjectValid(oKiller))
    {
        oKiller = OBJECT_SELF;
    }
    
    for (i=0; i<nLength; i++)
    {
        object oGolem = StringToObject(JsonGetString(JsonArrayGet(jGolems, i)));
        AssignCommand(oKiller, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetCurrentHitPoints(oGolem)+d6(5)), oGolem));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH_L), oGolem);
    }

    DeleteLocalJson(oArea, "maker_golems");
    
    json jLootChests = JsonArray();
    
    for (i=1;i<=4; i++)
    {
        object oLootWP = GetNearestObjectByTag("maker4_makerloot", oWP, i);
        object oChest = CreateObject(OBJECT_TYPE_PLACEABLE, "treas_chest", GetLocation(oLootWP));
        SetObjectVisualTransform(oChest, OBJECT_VISUAL_TRANSFORM_SCALE, 0.8);
        SetLocalInt(oChest, "boss", 1);
        DeleteLocalInt(oChest, "locked");
        DeleteLocalInt(oChest, "trapped");
        SetLocalInt(oChest, "area_cr", GetLocalInt(oArea, "cr")*2);
        ExecuteScript("treas_init", oChest);
        jLootChests = JsonArrayInsert(jLootChests, JsonString(ObjectToString(oChest)));
    }
    
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_DISPEL_DISJUNCTION), GetLocation(oWP));
    
    SetLocalJson(oArea, "maker_loot", jLootChests);
}

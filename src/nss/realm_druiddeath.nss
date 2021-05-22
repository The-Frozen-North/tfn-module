void main()
{
    object oDruid;
    int i, nDruids;

    object oSpirit = GetObjectByTag("realm_spirit");

    for (i = 0; i < 30; i++)
    {
        object oDruid = GetObjectByTag("realm_druid", i);
        if (GetIsObjectValid(oDruid) && !GetIsDead(GetObjectByTag("realm_druid", i)))
        {
            nDruids++;
        }
    }

    if (nDruids == 0)
    {
        FloatingTextStringOnCreature("All of the shadow druids are dead and peace has returned to the Spirit of the Wood.", GetLastKiller());

        object oArea = GetArea(oSpirit);

        SetFogColor(FOG_TYPE_ALL, FOG_COLOR_WHITE, GetArea(oSpirit));

        ChangeToStandardFaction(oSpirit, STANDARD_FACTION_DEFENDER);

        object oObject = GetFirstObjectInArea(oArea);
        {
             if (GetObjectType(oObject) == OBJECT_TYPE_AREA_OF_EFFECT)
                DestroyObject(oObject);

             oObject = GetNextObjectInArea(oArea);
        }

        ExecuteScript("hb_friendify", oSpirit);
        SetLocalString(OBJECT_SELF, "heartbeat_script", "hb_friendify");


        SetPlotFlag(oSpirit, TRUE);
        AssignCommand(oSpirit, ClearAllActions(TRUE));
    }
    else
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneParalyze(), oSpirit, 6.0);
        FloatingTextStringOnCreature("The death of the shadow druid seems to have a pacifying effect on the Spirit of the Wood.", GetLastKiller());
    }

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_NATURES_BALANCE), GetLocation(oSpirit));
}

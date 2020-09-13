void main()
{
    object oDruid;
    int i, nDruids;
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

        SetFogColor(FOG_TYPE_ALL, FOG_COLOR_WHITE, GetArea(OBJECT_SELF));
        object oSpirit = GetObjectByTag("realm_spirit");

        ChangeToStandardFaction(oSpirit, STANDARD_FACTION_DEFENDER);

        object oPC = GetFirstPC();

        while (GetIsObjectValid(oPC))
        {
            ClearPersonalReputation(oPC, oSpirit);
            SetIsTemporaryFriend(oPC, oSpirit);
            oPC = GetNextPC();
        }



        SetPlotFlag(oSpirit, TRUE);
        AssignCommand(oSpirit, ClearAllActions(TRUE));
    }
    else
    {
        FloatingTextStringOnCreature("The death of the shadow druid seems to have a pacifying effect on the Spirit of the Wood.", GetLastKiller());
    }
}

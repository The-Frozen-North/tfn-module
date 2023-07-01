int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nDexterityRequired = GetLocalInt(OBJECT_SELF, "dexterity_required");

    if (nDexterityRequired <= GetAbilityScore(oPC, ABILITY_DEXTERITY))
    {
        object oWaypoint = GetObjectByTag(GetLocalString(OBJECT_SELF, "waypoint"));
        AssignCommand(oPC, ActionJumpToLocation(GetLocation(oWaypoint)));

        return TRUE;
    }

    return FALSE;
}

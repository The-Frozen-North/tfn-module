int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC) > 0 || GetLevelByClass(CLASS_TYPE_FIGHTER, oPC) > 0) return TRUE;

    return FALSE;
}

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    if (GetLevelByClass(CLASS_TYPE_DRUID, oPC) >= 1 || GetLevelByClass(CLASS_TYPE_RANGER, oPC) >= 6) return TRUE;

    return FALSE;
}

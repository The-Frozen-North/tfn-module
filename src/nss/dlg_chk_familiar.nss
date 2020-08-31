int StartingConditional()
{
    object oPC = GetPCSpeaker();
    if (GetLevelByClass(CLASS_TYPE_WIZARD, oPC) >= 1 || GetLevelByClass(CLASS_TYPE_SORCERER, oPC) >= 1) return TRUE;

    return FALSE;
}

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetLevelByClass(CLASS_TYPE_WIZARD, oPC) > 0 || GetLevelByClass(CLASS_TYPE_SORCERER, oPC) > 0) return TRUE;

    return FALSE;
}

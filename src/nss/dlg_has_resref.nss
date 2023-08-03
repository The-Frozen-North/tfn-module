int StartingConditional()
{
    object oPC = GetPCSpeaker();

    object oItem = GetFirstItemInInventory(oPC);

    string sResRef = GetScriptParam("resref");

    while (GetIsObjectValid(oItem))
    {
        if (GetResRef(oItem) == sResRef) return TRUE;

        oItem = GetNextItemInInventory(oPC);
    }

    return FALSE;
}

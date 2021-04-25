int StartingConditional()
{
    object oItem = GetItemInSlot(StringToInt(GetScriptParam("item_slot")), GetPCSpeaker());

    if (!GetIsObjectValid(oItem))
        return FALSE;

    if (GetHiddenWhenEquipped(oItem) == StringToInt(GetScriptParam("hidden")))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

void main()
{
    object oItem = GetItemInSlot(StringToInt(GetScriptParam("item_slot")), GetPCSpeaker());

    if (!GetIsObjectValid(oItem))
        return;

    SetHiddenWhenEquipped(oItem, StringToInt(GetScriptParam("hidden")));
}

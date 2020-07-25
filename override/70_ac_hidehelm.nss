void main()
{
    object oHelmet = GetItemInSlot(INVENTORY_SLOT_HEAD,GetPCSpeaker());
    if(GetIsObjectValid(oHelmet))
    {
        SetHiddenWhenEquipped(oHelmet,!GetHiddenWhenEquipped(oHelmet));
    }
}

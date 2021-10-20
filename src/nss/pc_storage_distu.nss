void main()
{
    object oPC = GetLastDisturbed();

    if (GetIsPC(oPC) && GetResRef(OBJECT_SELF) == "_pc_storage")
    {
        StoreCampaignObject(GetPCPublicCDKey(oPC), GetTag(OBJECT_SELF), OBJECT_SELF);
    }
}

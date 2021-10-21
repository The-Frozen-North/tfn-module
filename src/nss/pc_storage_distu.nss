void main()
{
    object oPC = GetLastDisturbed();

    if (GetIsPC(oPC) && GetObjectType(OBJECT_SELF) == OBJECT_TYPE_PLACEABLE && GetResRef(OBJECT_SELF) == "_pc_storage")
    {
        StoreCampaignObject(GetPCPublicCDKey(oPC), GetTag(OBJECT_SELF), OBJECT_SELF);
        ExportSingleCharacter(oPC);
    }
}

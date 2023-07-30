#include "inc_itemupdate"

void main()
{
    object oPC = GetLastDisturbed();
    object oItem = GetInventoryDisturbItem();

    if (GetIsPC(oPC) && GetObjectType(OBJECT_SELF) == OBJECT_TYPE_PLACEABLE && GetResRef(OBJECT_SELF) == "_pc_storage")
    {
        StoreCampaignObject(GetPCPublicCDKey(oPC), GetTag(OBJECT_SELF), OBJECT_SELF);

        // deprecate any old crafted ammo, fabricator, etc
        DeprecateItem(oItem, oPC);

        ExportSingleCharacter(oPC);
    }
}

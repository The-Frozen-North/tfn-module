#include "nwnx_creature"

void main()
{
    object oPC = GetPCSpeaker();
    if (GetLevelByClass(CLASS_TYPE_WIZARD, oPC) >= 1 || GetLevelByClass(CLASS_TYPE_SORCERER, oPC) >= 1)
    {
        DestroyObject(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC, 1));
        DestroyObject(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC, 2));
        DestroyObject(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC, 3));

        NWNX_Creature_SetFamiliarCreatureType(oPC, FAMILIAR_CREATURE_TYPE_PSEUDO_DRAGON);
    }
}

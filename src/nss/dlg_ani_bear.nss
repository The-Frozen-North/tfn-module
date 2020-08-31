#include "nwnx_creature"

void main()
{
    object oPC = GetPCSpeaker();
    if (GetLevelByClass(CLASS_TYPE_DRUID, oPC) >= 1 || GetLevelByClass(CLASS_TYPE_RANGER, oPC) >= 6)
    {
        DestroyObject(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC, 1));
        DestroyObject(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC, 2));
        DestroyObject(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC, 3));

        NWNX_Creature_SetAnimalCompanionCreatureType(oPC, ANIMAL_COMPANION_CREATURE_TYPE_BEAR);
    }
}

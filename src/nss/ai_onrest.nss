#include "inc_ai_event"

void main()
{
    object oFamiliar = GetAssociate(ASSOCIATE_TYPE_FAMILIAR);
    if (GetIsObjectValid(oFamiliar))
    {
        ForceRest(oFamiliar);
        DecrementRemainingFeatUses(OBJECT_SELF, FEAT_SUMMON_FAMILIAR);
    }

    object oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION);
    if (GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION)))
    {
        ForceRest(oCompanion);
        DecrementRemainingFeatUses(OBJECT_SELF, FEAT_ANIMAL_COMPANION);
    }


    //DeleteLocalInt(OBJECT_SELF, "invis");
    DeleteLocalInt(OBJECT_SELF, "gsanc");
    DeleteLocalInt(OBJECT_SELF, "combat");
    DeleteLocalInt(OBJECT_SELF, "healers_kit_cd");
    DeleteLocalInt(OBJECT_SELF, "fast_buffed");
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_RESTED));
}


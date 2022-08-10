#include "inc_quest"

const string ORB_RESREF = "q_cock_fcap";

void DealWithFerdDeath(object oPC)
{
    if (GetQuestEntry(oPC, "q_cockatrice") == 3 || GetQuestEntry(oPC, "q_cockatrice") == 2)
    {
        if (GetQuestEntry(oPC, "q_cockatrice_fbasilisk") <= 1)
        {
            GiveQuestXPToPC(OBJECT_SELF, 2, 8, 0);
        }
        if (GetQuestEntry(oPC, "q_cockatrice_fgorgon") <= 1)
        {
            GiveQuestXPToPC(OBJECT_SELF, 2, 8, 0);
        }
        FloatingTextStringOnCreature("With Ferdinand dead, you take some feathers from the cockatrice.", oPC, FALSE);
        SetQuestEntry(oPC, "q_cockatrice_fbasilisk", 4);
        SetQuestEntry(oPC, "q_cockatrice_fgorgon", 4);
        SetQuestEntry(oPC, "q_cockatrice", 4);
        // Remove orbs from inventory
        object oTest = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oTest))
        {
            if (GetResRef(oTest) == ORB_RESREF)
            {
                FloatingTextStringOnCreature("With Ferdinand dead and the feathers in hand, you discard the capturing orb as it is now useless.", oPC, FALSE);
                DestroyObject(oTest);
            }
            oTest = GetNextItemInInventory(oPC);
        }
        GiveQuestXPToPC(oPC, 3, 8, 0);
    }
}

void main()
{
    object oPC = GetLastKiller();
    if (!GetIsPC(oPC))
    {
       oPC = GetMaster(oPC);
    }
    if (!GetIsPC(oPC))
    {
        return;
    }

    location lLocation = GetLocation(OBJECT_SELF);

    oPC = GetFirstObjectInShape(SHAPE_SPHERE, 30.0, lLocation, FALSE, OBJECT_TYPE_CREATURE);

    while (GetIsObjectValid(oPC))
    {
        if (GetIsPC(oPC))
        {
            DealWithFerdDeath(oPC);
        }

        oPC = GetNextObjectInShape(SHAPE_SPHERE, 30.0, lLocation, FALSE, OBJECT_TYPE_CREATURE);
    }
}

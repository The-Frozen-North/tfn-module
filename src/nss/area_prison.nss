#include "nwnx_creature"

void main()
{
    int i, nRandom;

    object oZombie = GetObjectByTag("EscapedPrisonerz");
    for (i = 0; i < 12; i++)
    {
        if (!GetIsDead(oZombie))
        {
            return; // do not continue if there is a zombie still alive
            break;
        }

        oZombie = GetObjectByTag("EscapedPrisonerz", i);
    }

    object oBoss = GetObjectByTag("kurdan");
    if (!GetIsObjectValid(oBoss) || GetIsDead(oBoss))
    {
        return; // do not proceed if jared (graveyard boss) is dead or non-existant
    }

    object oPC = GetFirstPC();
    string sAreaResRef;

    while (GetIsObjectValid(oPC))
    {
        sAreaResRef = GetResRef(GetArea(oPC));

        if (sAreaResRef == "core_prison2" || sAreaResRef == "core_prison3" || sAreaResRef == "core_prison4")
        {
            return;
            break;
        }

        oPC = GetNextPC();
    }

    int nCounter = GetLocalInt(OBJECT_SELF, "counter");

    if (nCounter < 30)
    {
        SetLocalInt(OBJECT_SELF, "counter", nCounter+1);
        return;
    }

    DeleteLocalInt(OBJECT_SELF, "counter");

    object oDoor = GetObjectByTag("PrisonMainFloorToContainment");

    AssignCommand(oDoor, ActionOpenDoor(oDoor));

    int nMaxZombies = d2(3);
    string sResRef;
    location lSpawn = GetLocation(GetObjectByTag("WP_PRISONERS"));

    for (i = 0; i <= nMaxZombies; i++)
    {
        nRandom = d6();

        switch (nRandom)
        {
            case 1:
                sResRef = "prisonerrang";
            break;
            case 2:
            case 3:
                sResRef = "prisonermele";
            break;
            case 4:
            case 5:
                sResRef = "prisonerbrut";
            break;
            case 6:
                sResRef = "prisonermage";
            break;
        }

        object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lSpawn, FALSE, "EscapedPrisonerz");

        // do this on a delay because the spawn script might set a decay time
        DelayCommand(3.0, NWNX_Creature_SetCorpseDecayTime(oCreature, 180000));
    }
}

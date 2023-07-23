#include "nwnx_creature"

void main()
{
    int i, nRandom;

    object oZombie = GetObjectByTag("BeggarsZombie");
    for (i = 0; i < 12; i++)
    {
        if (!GetIsDead(oZombie))
        {
            return; // do not continue if there is a zombie still alive
            break;
        }

        oZombie = GetObjectByTag("BeggarsZombie", i);
    }

    object oJared = GetObjectByTag("jared");
    if (!GetIsObjectValid(oJared) || GetIsDead(oJared))
    {
        return; // do not proceed if jared (graveyard boss) is dead or non-existant
    }

    object oPC = GetFirstPC();
    string sAreaResRef;

    while (GetIsObjectValid(oPC))
    {
        sAreaResRef = GetResRef(GetArea(oPC));

        if (sAreaResRef == "beg_grave" || sAreaResRef == "beg_tomb" || sAreaResRef == "beg_crypts" || sAreaResRef == "beg_warrens")
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

    object oDoor = GetObjectByTag("BeggarsToGraveyard");

    AssignCommand(oDoor, ActionOpenDoor(oDoor));

    int nMaxZombies = d3(3);
    string sResRef;
    location lSpawn = GetLocation(GetObjectByTag("WP_ZOMBIES"));

    for (i = 0; i <= nMaxZombies; i++)
    {
        nRandom = d6();

        switch (nRandom)
        {
            case 1:
                sResRef = "skeleton";
            break;
            case 2:
            case 3:
                sResRef = "weakzombie";
            break;
            case 4:
            case 5:
                sResRef = "zombie";
            break;
            case 6:
                sResRef = "zombiew";
            break;
        }

        object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lSpawn, FALSE, "BeggarsZombie");

// do this on a delay because the spawn script might set a decay time
        DelayCommand(3.0, NWNX_Creature_SetCorpseDecayTime(oCreature, 180000));
    }
}

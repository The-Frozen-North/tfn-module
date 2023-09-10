#include "inc_general"
#include "inc_loot"

void CreateTreasure()
{
    object oItem = GenerateLoot(OBJECT_SELF);
    SetStolenFlag(oItem, TRUE);
    SetLocalInt(oItem, "stolen", 1);        
}

void main()
{
    object oPC = GetLastOpenedBy();

    if (!GetIsPC(oPC)) return;
    
    SendColorMessageToPC(oPC, "Taking items from this container will be considered stealing.", MESSAGE_COLOR_DANGER);
    SendColorMessageToPC(oPC, "You must make a pick pocket check against all nearby creatures to take an item without being caught.", MESSAGE_COLOR_INFO);

    // treasure should only be generated once
    if (GetLocalInt(OBJECT_SELF, "treasure_generated") == 1) return;

    SetLocalInt(OBJECT_SELF, "treasure_generated", 1);

    int nCR = GetLocalInt(GetArea(OBJECT_SELF), "cr");
    SetLocalInt(OBJECT_SELF, "area_cr", nCR);
    SetLocalInt(OBJECT_SELF, "cr", nCR);

    int bChanceTwo = 75;
    int bChanceThree = 50;
    int bChanceFour = 25;

    CreateTreasure();

    int bRandom = d100();
    if (bChanceFour <= bRandom)
    {
        CreateTreasure();
        CreateTreasure();
        CreateTreasure();
    }
    else if (bChanceThree <= bRandom)
    {
        CreateTreasure();
        CreateTreasure();
    }
    else if (bChanceTwo <= bRandom)
    {
        CreateTreasure();
    }

    int bChanceGold = 50;


}

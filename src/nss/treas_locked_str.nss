#include "inc_loot"
#include "inc_respawn"

// this script is called when a treasure object is used but locked
// since it's not really a container, just emulate the lock UX
void DestroyPlot()
{
    SetPlotFlag(OBJECT_SELF, FALSE);
    DestroyObject(OBJECT_SELF);
}

void OpenTreasure(object oPC)
{
     SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "");
     SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "treas_open");
     SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "");
     StartRespawn();
     DelayCommand(LOOT_DESTRUCTION_TIME, DestroyPlot());

     ExecuteScript("party_credit", OBJECT_SELF);
     OpenPersonalLoot(OBJECT_SELF, oPC);
}

void main()
{
    object oPC = GetLastUsedBy();

    if (!GetIsPC(oPC)) return;

    ExecuteScript("remove_invis", oPC);

    int nStrength = GetAbilityScore(oPC, ABILITY_STRENGTH);
    int nStrengthRequired = GetLocalInt(OBJECT_SELF, "strength_required");

// if enough strength, open the treasure and return
    if (nStrength >= nStrengthRequired)
    {
        OpenTreasure(oPC);
        return;
    }

    object oParty = GetFirstFactionMember(oPC, FALSE);
    while (GetIsObjectValid(oParty))
    {
        float fDistance = GetDistanceToObject(oParty);
        int nRacialType = GetRacialType(oParty);

// check if it's the same master and not dead
// also, simple check to see if it can even open it (sorry, you need opposable thumbs for this, also probably don't really care about checking PC druids/shifters just their pets)
        if (GetMaster(oParty) == oPC && !GetIsDead(oParty) &&
            nRacialType != RACIAL_TYPE_ANIMAL && nRacialType != RACIAL_TYPE_VERMIN && nRacialType != RACIAL_TYPE_BEAST && nRacialType != RACIAL_TYPE_OOZE && nRacialType != RACIAL_TYPE_MAGICAL_BEAST)
        {
            float fDistance = GetDistanceToObject(oParty);
            int nPartyStrength = GetAbilityScore(oParty, ABILITY_STRENGTH);

// if enough strength, valid distance, AND within distance, open and return
            if (nPartyStrength >= nStrengthRequired && fDistance >= 0.0 && fDistance <= 10.0)
            {
                OpenTreasure(oPC);
                return;
            }
        }

       oParty = GetNextFactionMember(oPC, FALSE);
    }

    PlaySound("as_sw_stonelk1");
    FloatingTextStringOnCreature("*You need more strength to open this container*", oPC, FALSE);
}

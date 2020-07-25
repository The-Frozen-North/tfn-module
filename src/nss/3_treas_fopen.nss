#include "1_inc_loot"
#include "1_inc_respawn"

void DestroyPlot()
{
    SetPlotFlag(OBJECT_SELF, FALSE);
    DestroyObject(OBJECT_SELF);
}

void main()
{
     object oPC = GetLastUsedBy();

// don't do anything if not a PC
     if (!GetIsPC(oPC)) return;

     if (GetLocalInt(OBJECT_SELF, "no_credit") == 1) return;

// there is no death script if it is opened
// just in case they can loot it AND bash it for more loot
     SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "");
     SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "3_treas_open");
     SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "");
     StartRespawn();
     DelayCommand(LOOT_DESTRUCTION_TIME, DestroyPlot());

     ExecuteScript("3_party_credit", OBJECT_SELF);
     OpenPersonalLoot(OBJECT_SELF, oPC);
}

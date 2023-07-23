// this script is called when a treasure container is unlocked
#include "inc_general"

void main()
{
    object oUnlocker = GetLastUnlocked();

    if (GetObjectType(oUnlocker) == OBJECT_TYPE_CREATURE) PlaySound("gui_picklockopen");

// if it unlocked, then we can use the treasure opening script
    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "treas_fopen");
    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "");
    SetPlotFlag(OBJECT_SELF, TRUE);

    // check if unlocked by a possessed pixie
    if (!GetIsPC(oUnlocker)) oUnlocker = GetMaster(oUnlocker);

    // do nothing if not a PC still
    if (!GetIsPC(oUnlocker)) return;

    IncrementStat(oUnlocker, "locks_unlocked");
}

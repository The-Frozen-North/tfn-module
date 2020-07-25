#include "1_inc_trap"
#include "1_inc_lock"
#include "1_inc_loot"
#include "1_inc_respawn"

void main()
{
    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "");


    SetLocalInt(OBJECT_SELF, "cr", GetLocalInt(GetArea(OBJECT_SELF), "cr")+GetLocalInt(OBJECT_SELF, "cr_bonus"));
    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "3_treas_death");
    GenerateTrapOnObject();
    GenerateLockOnObject();
    SetSpawn();

    if (GetLocked(OBJECT_SELF))
    {
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "3_bash_lock");
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK, "3_treas_unlock");
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "3_treas_locked");
        SetPlotFlag(OBJECT_SELF, FALSE);
    }
    else
    {
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "3_treas_fopen");
        SetPlotFlag(OBJECT_SELF, TRUE);
    }
}

#include "inc_trap"
#include "inc_lock"
#include "inc_loot"
#include "inc_respawn"

void main()
{
    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "");


    SetLocalInt(OBJECT_SELF, "cr", GetLocalInt(GetArea(OBJECT_SELF), "cr")+GetLocalInt(OBJECT_SELF, "cr_bonus"));
    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "treas_death");
    GenerateTrapOnObject();
    GenerateLockOnObject();
    SetSpawn();

    if (GetLocked(OBJECT_SELF))
    {
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED, "bash_lock");
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK, "treas_unlock");
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "treas_locked");
        SetPlotFlag(OBJECT_SELF, FALSE);
    }
    else
    {
        SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_USED, "treas_fopen");
        SetPlotFlag(OBJECT_SELF, TRUE);
    }
}

#include "inc_trap"
#include "inc_lock"
#include "inc_loot"
#include "inc_respawn"

void main()
{
    int nAreaCR = GetLocalInt(GetArea(OBJECT_SELF), "cr");

    SetLocalInt(OBJECT_SELF, "cr", nAreaCR+GetLocalInt(OBJECT_SELF, "cr_bonus"));
    SetLocalInt(OBJECT_SELF, "area_cr", nAreaCR);

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

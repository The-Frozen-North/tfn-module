#include "x2_inc_switches"

int StartingConditional()
{
    return !GetModuleSwitchValue("70_AOE_HEARTBEAT_WORKAROUND");
}

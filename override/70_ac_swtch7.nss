#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("70_AOE_HEARTBEAT_WORKAROUND",!GetModuleSwitchValue("70_AOE_HEARTBEAT_WORKAROUND"));
}

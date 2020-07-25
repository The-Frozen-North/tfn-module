#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("72_ENABLE_FLYING_TRAP_IMMUNITY",!GetModuleSwitchValue("72_ENABLE_FLYING_TRAP_IMMUNITY"));
}

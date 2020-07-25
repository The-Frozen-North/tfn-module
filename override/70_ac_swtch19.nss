#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("72_DISABLE_SNEAK_CRITICAL_IMMUNITY",!GetModuleSwitchValue("72_DISABLE_SNEAK_CRITICAL_IMMUNITY"));
}

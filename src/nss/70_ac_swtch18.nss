#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("72_DISABLE_MONK_IN_POLYMORPH",!GetModuleSwitchValue("72_DISABLE_MONK_IN_POLYMORPH"));
}

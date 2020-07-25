#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("72_HARDCORE_EVASION_RULES",!GetModuleSwitchValue("72_HARDCORE_EVASION_RULES"));
}

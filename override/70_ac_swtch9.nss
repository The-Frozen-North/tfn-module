#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("70_AOE_IGNORE_SPELL_RESISTANCE",!GetModuleSwitchValue("70_AOE_IGNORE_SPELL_RESISTANCE"));
}

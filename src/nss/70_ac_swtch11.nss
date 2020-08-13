#include "70_inc_switches"

void main()
{
    SetGlobalSwitch(MODULE_SWITCH_ENABLE_CRAFT_WAND_50_CHARGES,!GetModuleSwitchValue(MODULE_SWITCH_ENABLE_CRAFT_WAND_50_CHARGES));
}

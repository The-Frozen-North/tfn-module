#include "70_inc_switches"

void main()
{
    SetGlobalSwitch(MODULE_SWITCH_ENABLE_UMD_SCROLLS,!GetModuleSwitchValue(MODULE_SWITCH_ENABLE_UMD_SCROLLS));
}

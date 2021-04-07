#include "70_inc_switches"

void main()
{
    SetGlobalSwitch(MODULE_VAR_AI_STOP_EXPERTISE_ABUSE,!GetModuleSwitchValue(MODULE_VAR_AI_STOP_EXPERTISE_ABUSE));
}

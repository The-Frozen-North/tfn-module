#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("71_ALLOW_POISON_STACKING",!GetModuleSwitchValue("71_ALLOW_POISON_STACKING"));
}

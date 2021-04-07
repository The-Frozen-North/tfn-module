#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("72_SHIFTER_ADDS_CASTER_LEVEL",!GetModuleSwitchValue("72_SHIFTER_ADDS_CASTER_LEVEL"));
}

#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("71_RESTRICT_MUSICAL_INSTRUMENTS",!GetModuleSwitchValue("71_RESTRICT_MUSICAL_INSTRUMENTS"));
}

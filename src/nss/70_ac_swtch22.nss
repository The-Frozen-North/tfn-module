#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("72_DEVAST_ONCE_PER_TARGET",!GetModuleSwitchValue("72_DEVAST_ONCE_PER_TARGET"));
}

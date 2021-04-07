#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("72_DISABLE_TUMBLE_AC",!GetModuleSwitchValue("72_DISABLE_TUMBLE_AC"));
}

#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("72_ALLOW_BOOST_THROWING",!GetModuleSwitchValue("72_ALLOW_BOOST_THROWING"));
}

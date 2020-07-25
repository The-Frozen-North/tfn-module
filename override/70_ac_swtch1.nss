#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("71_ALLOW_BOOST_GLOVES",!GetModuleSwitchValue("71_ALLOW_BOOST_GLOVES"));
}

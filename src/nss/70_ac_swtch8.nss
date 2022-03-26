#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("70_RESISTSPELL_SPELLMANTLE_GOES_FIRST",!GetModuleSwitchValue("70_RESISTSPELL_SPELLMANTLE_GOES_FIRST"));
}

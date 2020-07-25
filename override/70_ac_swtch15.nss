#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("72_POLYMORPH_MERGE_EVERYTHING",!GetModuleSwitchValue("72_POLYMORPH_MERGE_EVERYTHING"));
}

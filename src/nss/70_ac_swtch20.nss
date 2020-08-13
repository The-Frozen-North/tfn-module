#include "70_inc_switches"

void main()
{
    SetGlobalSwitch("72_DISABLE_PARALYZE_MIND_SPELL_IMMUNITY",!GetModuleSwitchValue("72_DISABLE_PARALYZE_MIND_SPELL_IMMUNITY"));
}

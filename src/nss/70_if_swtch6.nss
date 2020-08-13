#include "x2_inc_switches"

int StartingConditional()
{
    return !GetModuleSwitchValue("71_ALLOW_POISON_STACKING");
}

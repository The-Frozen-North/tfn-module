#include "nw_i0_generic"

void main()
{
    if (GetHasEffect(EFFECT_TYPE_SLEEP, OBJECT_SELF)) return;
    
    // 1 in 20 chance of falling asleep at night for a few hours
    if (GetIsNight() && d20() == 1)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSleep(), OBJECT_SELF, TurnsToSeconds(20 + d20()));
        return;
    }
    
    switch (d20())
    {
        case 1: PlaySound("as_an_dogbark1"); break;
        case 2: PlaySound("as_an_dogbark2"); break;
        case 3: PlaySound("as_an_dogbark3"); break;
        case 4: PlaySound("as_an_dogbark6"); break;
        case 5: PlaySound("as_an_dogbark7"); break;
    }
}

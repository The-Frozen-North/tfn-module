#include "nw_i0_generic"

void main()
{
    if (!GetHasEffect(EFFECT_TYPE_CUTSCENEGHOST, OBJECT_SELF))
    {
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectCutsceneGhost()), OBJECT_SELF);
    }

    if (GetHasEffect(EFFECT_TYPE_SLEEP, OBJECT_SELF)) return;

    // 1 in 100 chance of falling asleep for an hour or two at any time of the day
    if (d100() == 1)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSleep(), OBJECT_SELF, TurnsToSeconds(5 + d6()));
        return;
    }
    
    switch (d20())
    {
        case 1: PlaySound("as_an_catmeow1"); break;
        case 2: PlaySound("as_an_catmeow2"); break;
        case 3: PlaySound("as_an_catmeow3"); break;
        case 4: PlaySound("as_an_catmeow4"); break;
        case 5: PlaySound("as_an_catscrech1"); break;
        case 6:
            ActionPlayAnimation(ANIMATION_FIREFORGET_TAUNT); 
            PlaySound("as_an_catscrech1"); 
        break;
    }
}

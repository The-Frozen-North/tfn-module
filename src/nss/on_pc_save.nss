#include "nwnx_events"
#include "nwnx_creature"
#include "inc_debug"

void main()
{

    if (NWNX_Creature_GetIsBartering(OBJECT_SELF))
    {
        SendDebugMessage("Skipping save for "+GetName(OBJECT_SELF)+" because bartering");
        NWNX_Events_SkipEvent();
        return;
    }

    int bPolymorph = FALSE;

    effect e = GetFirstEffect(OBJECT_SELF);
    while(GetIsEffectValid(e))
    {
        if(GetEffectType(e) == EFFECT_TYPE_POLYMORPH)
        {
            bPolymorph = TRUE;
            break;
        }
        e = GetNextEffect(OBJECT_SELF);
    }

    if (bPolymorph)
    {
        SendDebugMessage("Skipping save for "+GetName(OBJECT_SELF)+" because polymorphed");
        NWNX_Events_SkipEvent();
    }
}

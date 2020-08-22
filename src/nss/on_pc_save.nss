#include "nwnx_events"
#include "inc_debug"

void main()
{
    int bPolymorph = FALSE;
    int bNearPC = FALSE;

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

    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF);

    if (GetIsObjectValid(oPC) && !GetIsDead(oPC) && !GetIsDead(OBJECT_SELF) && !GetIsInCombat(oPC) && !GetIsInCombat(OBJECT_SELF) && GetDistanceBetween(OBJECT_SELF, oPC) <= 3.0) bNearPC = TRUE;

    if (bPolymorph)
    {
        SendDebugMessage("Skipping save for "+GetName(OBJECT_SELF)+" because polymorphed");
        NWNX_Events_SkipEvent();
    }
    else if (bNearPC)
    {
        SendDebugMessage("Skipping save for "+GetName(OBJECT_SELF)+" because near "+GetName(oPC));
        NWNX_Events_SkipEvent();
    }
}

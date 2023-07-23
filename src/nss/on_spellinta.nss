#include "x0_i0_match"
#include "inc_general"

void main()
{
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF)) { return; }
    if (d3() == 1)
        PlayVoiceChat(VOICE_CHAT_SPELLFAILED);
    object oHitter = GetLastDamager();
    if (GetIsPC(OBJECT_SELF))
    {
        IncrementPlayerStatistic(OBJECT_SELF, "own_spells_interrupted");
    }
    if (GetIsPC(oHitter))
    {
        IncrementPlayerStatistic(oHitter, "other_spells_interrupted");
    }
}

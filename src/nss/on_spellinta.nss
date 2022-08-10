#include "x0_i0_match"

void main()
{
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF)) { return; }
    if (d3() == 1)
        PlayVoiceChat(VOICE_CHAT_SPELLFAILED);
}

#include "nw_i0_generic"

void main()
{
    if (GetHasEffect(EFFECT_TYPE_SLEEP, OBJECT_SELF))
        return;

    switch (d8())
    {
        case 1: PlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK, 1.0, IntToFloat(d3(3))); break;
        case 2: PlayAnimation(ANIMATION_LOOPING_PAUSE_TIRED, 1.0, IntToFloat(d3(3))); break;
        case 3: PlayAnimation(ANIMATION_FIREFORGET_DRINK); break;
        case 4: PlayVoiceChat(VOICE_CHAT_LAUGH); PlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING); break;
    }

}

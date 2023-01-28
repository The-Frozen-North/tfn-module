#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        // For completeness, maybe
        SendDiscordLogMessage(GetName(oPC) + " used the developer menu to kill themselves.");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC);
    }
}

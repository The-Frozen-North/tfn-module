#include "inc_debug"
void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC);
    }
}

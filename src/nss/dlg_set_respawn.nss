#include "inc_sql"

void main()
{
    object oPC = GetPCSpeaker();

    SQLocalsPlayer_SetString(GetPCSpeaker(), "respawn", GetScriptParam("respawn"));
    ActionCastFakeSpellAtObject(SPELL_DEATH_WARD, oPC);

    DelayCommand(2.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH_WARD), oPC));

}

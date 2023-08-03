#include "x2_i0_spells"

void main()
{
    object oBaram = GetObjectByTag("baram");
    if(GetIsObjectValid(oBaram) && !GetIsDead(oBaram))
    {
        if(GetHasSpellEffect(SPELL_HASTE, oBaram))
        {
            GZRemoveSpellEffects(SPELL_HASTE, oBaram);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DISPEL), oBaram);
            AssignCommand(oBaram, PlayVoiceChat(VOICE_CHAT_CUSS));
        }
    }
}
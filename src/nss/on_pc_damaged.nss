#include "inc_horse"
#include "inc_general"
#include "inc_hai_constant"

void main()
{
    PlayNonMeleePainSound(GetLastDamager());

    if (GetIsMounted(OBJECT_SELF))
    {
        int nSkill = SKILL_RIDE;

        int nDamage = GetTotalDamageDealt();

        if (nDamage > 0) nDamage = nDamage/3;

        if (!GetIsSkillSuccessful(OBJECT_SELF, SKILL_RIDE, 10 + nDamage))
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), OBJECT_SELF, 6.0);
    }

    if (GetIsEnemy(GetLastDamager()))
        AISpeakString(AI_SHOUT_I_WAS_ATTACKED);
}

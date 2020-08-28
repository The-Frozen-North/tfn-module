#include "inc_horse"
#include "inc_general"

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
}

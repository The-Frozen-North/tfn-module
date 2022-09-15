// Dagger of stars
// 10% chance to turn attacker invisible for 2 rounds
// (1 round is not enough to make any sneak attacks sometimes and the AI might ignore it)
void main()
{
    object oTarget = GetSpellTargetObject();
    if (GetIsObjectValid(oTarget))
    {
        if (Random(100) < 10)
        {
            effect eInvis = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
            ApplyEffectToObject(
                DURATION_TYPE_TEMPORARY,
                eInvis,
                OBJECT_SELF,
                RoundsToSeconds(2)
            );
        }
    }
}

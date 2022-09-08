// Soul Reaver (greatsword)
// On hit apply AC-1 on target for 1 round (stacking)
void main()
{
    object oTarget = GetSpellTargetObject();
    if (GetIsObjectValid(oTarget))
    {
        //use AC_DODGE so it stacks
        effect eACDecrease = EffectACDecrease(1, AC_DODGE_BONUS);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eACDecrease, oTarget, RoundsToSeconds(1));
    }
}

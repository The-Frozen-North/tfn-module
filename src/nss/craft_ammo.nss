#include "inc_craft"

void main()
{
    object oPC = GetPCSpeaker();
    object oAmmo = GetObjectByTag("fabricator_"+GetLocalString(oPC, "ammo_tag"));

    if (!GetIsObjectValid(oAmmo))
        return;

    int nValue = DetermineAmmoCraftingCost(oAmmo);

    if (GetGold(oPC) < nValue)
        return;

    AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 1.0, 60.0));

    TakeGoldFromCreature(nValue, oPC, TRUE);

    int nVFX;
    if (GetIsSkillSuccessful(oPC, SKILL_CRAFT_WEAPON, DetermineAmmoCraftingDC(oAmmo)))
    {
        object oItem = CopyItem(oAmmo, oPC, TRUE);
        SetTag(oItem, "crafted_ammo");
        SetPlotFlag(oItem, TRUE);
        nVFX = VFX_COM_HIT_ELECTRICAL;
    }
    else
    {
        nVFX = VFX_COM_HIT_NEGATIVE;
        AssignCommand(oPC, PlaySound("as_cv_glasbreak1"));
    }

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(nVFX), GetLocation(oPC));
}

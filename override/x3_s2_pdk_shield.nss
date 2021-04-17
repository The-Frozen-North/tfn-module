//::///////////////////////////////////////////////
//:: Purple Dragon Knight - Heroic Shield
//:: x3_s2_pdk_shield.nss
//:://////////////////////////////////////////////
//:: Applies a temporary AC bonus to one ally
//:://////////////////////////////////////////////
//:: Created By: Stratovarius
//:://////////////////////////////////////////////
/*
    Modified By : gaoneng erick
    Modified On : may 6, 2006
    added custom vfx

Patch 1.71

- fixed improper usage of this ability when character is in any disabled state or dying
- fixed an exploit allowing to use this ability to target outside of the current area,
however the possibility to use it via portrait in the same area without line of sight
on target was kept intentionally
- fixed a relog issue that prevented further use of this ability
- feedback messages externalized with a workaround that they returns message from server
(in order to avoid problems with 1.70 server and 1.69 player)
- added usual expire visual effect for easier determination when the spell expired
- effects made undispellable (Ex) as per DnD
*/

void main()
{
    if(!GetCommandable() || GetIsDead(OBJECT_SELF))
    {
        return;
    }
    //Declare main variables.
    object oPC = OBJECT_SELF;
    object oMod = GetModule();
    string sVarName = "PDKHeroicTracking_"+ObjectToString(oPC);
    object oTarget = GetSpellTargetObject();
    int nBonus = 4;

    if(GetLocalInt(oMod, sVarName))
    {
        FloatingTextStringOnCreature(GetStringByStrRef(112042), oPC, FALSE);
        return;
    }
    else if(oPC == oTarget)
    {
        FloatingTextStringOnCreature(GetStringByStrRef(112043), oPC, FALSE);
        return;
    }
    else if(!GetIsFriend(oTarget))
    {
        FloatingTextStringOnCreature(GetStringByStrRef(112044), oPC, FALSE);
        return;
    }
    else if(GetArea(oPC) != GetArea(oTarget))
    {
        FloatingTextStringOnCreature(GetStringByStrRef(112045), oPC, FALSE);
        return;
    }

    effect eAC = EffectACIncrease(nBonus);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    eAC = EffectLinkEffects(eAC,eDur);
    eAC = ExtraordinaryEffect(eAC);//this effect shouldn't be dispellable
    effect eVFX = EffectVisualEffect(VFX_IMP_PDK_HEROIC_SHIELD);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAC, oTarget, RoundsToSeconds(1));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFX, oTarget);
    SetLocalInt(oMod, sVarName, TRUE);
    AssignCommand(oMod, DelayCommand(5.0, SetLocalInt(oMod, sVarName, 0)));
}

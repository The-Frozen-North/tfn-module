//::///////////////////////////////////////////////
//:: Ioun stone Multi-spell script
//:: 70_s3_iounstone
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Reason for this spellscript is to allow builder change all ioun stone scripts easily.
You can now modify all these spells in a single script instead of modifying seven scripts
individually.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: Jan 12, 2015
//:://////////////////////////////////////////////

void main()
{
    object oActivator = OBJECT_SELF;
    int nID;
    effect eEffect = GetFirstEffect(oActivator);

    while(GetIsEffectValid(eEffect))//this loop will remove any other ioun stone effect
    {
        nID = GetEffectSpellId(eEffect);
        if(nID > 553 && nID < 561)
        {
            RemoveEffect(oActivator,eEffect);
        }
        eEffect = GetNextEffect(oActivator);
    }

    //Declare major variables
    int nVFX;
    effect eBonus;
    switch(GetSpellId())
    {
        case SPELL_IOUN_STONE_DUSTY_ROSE:
        nVFX = VFX_DUR_IOUNSTONE_YELLOW;
        eBonus = EffectACIncrease(1,AC_DODGE_BONUS);
        break;
        case SPELL_IOUN_STONE_PALE_BLUE:
        nVFX = VFX_DUR_IOUNSTONE_BLUE;
        eBonus = EffectAbilityIncrease(ABILITY_STRENGTH,2);
        break;
        case SPELL_IOUN_STONE_SCARLET_BLUE:
        nVFX = VFX_DUR_IOUNSTONE_BLUE;
        eBonus = EffectAbilityIncrease(ABILITY_INTELLIGENCE,2);
        break;
        case SPELL_IOUN_STONE_BLUE:
        nVFX =VFX_DUR_IOUNSTONE_BLUE;
        eBonus = EffectAbilityIncrease(ABILITY_WISDOM,2);
        break;
        case SPELL_IOUN_STONE_DEEP_RED:
        nVFX = VFX_DUR_IOUNSTONE_RED;
        eBonus = EffectAbilityIncrease(ABILITY_DEXTERITY,2);
        break;
        case SPELL_IOUN_STONE_PINK:
        nVFX = VFX_DUR_IOUNSTONE_RED;
        eBonus = EffectAbilityIncrease(ABILITY_CONSTITUTION,2);
        break;
        case SPELL_IOUN_STONE_PINK_GREEN:
        nVFX = VFX_DUR_IOUNSTONE_GREEN;
        eBonus = EffectAbilityIncrease(ABILITY_CHARISMA,2);
        break;
    }

    //Apply new ioun stone effect
    effect eVFX = EffectVisualEffect(nVFX);
    effect eLink = EffectLinkEffects(eVFX,eBonus);
    //made this effect extraordinary so it won't be dispellable
    eLink = ExtraordinaryEffect(eLink);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eLink,oActivator,3600.0);
}

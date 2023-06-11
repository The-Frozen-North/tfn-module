//::///////////////////////////////////////////////
//:: Purple Dragon Knight - Oath of Wrath
//:: x3_s2_pdk_wrath.nss
//:://////////////////////////////////////////////
//:: Applies a temporary Attack, Save, Damage, Skill bonus vs
//:: monsters of the targets racial type
//:://////////////////////////////////////////////
//:: Created By: Stratovarius
//:: Created On: Sept 22, 2005
//:://////////////////////////////////////////////
/*
    Modified By : gaoneng erick
    Modified On : may 6, 2006
    added custom vfx

Patch 1.71

- fixed improper usage of this ability when character is in any disabled state or dying
- feedback messages externalized with a workaround that they returns message from server
(in order to avoid problems with 1.70 server and 1.69 player)
- effects made undispellable (Su) as per DnD
*/

void main()
{
    if(!GetCommandable() || GetIsDead(OBJECT_SELF))
    {
        return;
    }
    //Declare main variables.
    object oPC = OBJECT_SELF;
    object oTarget = GetSpellTargetObject();// Target
    string sError;

    if (oPC == oTarget)
    {
        switch(GetPlayerLanguage(oPC))
        {
            case PLAYER_LANGUAGE_FRENCH: sError = "Vous ne pouvez pas vous choisir comme cible avec cette capacité."; break;
            case PLAYER_LANGUAGE_GERMAN: sError = "Du kannst dich nicht selbst als Ziel dieses Talentes angeben."; break;
            case PLAYER_LANGUAGE_ITALIAN: sError = "Non puoi essere bersaglio di questa abilità."; break;
            case PLAYER_LANGUAGE_SPANISH: sError = "No puedes apuntarte a ti mismo usando esta habilidad."; break;
            case PLAYER_LANGUAGE_POLISH: sError = "Nie mo¿esz obraæ na cel siebie u¿ywaj¹c tej zdolnoœci."; break;
            default: sError = "You cannot target yourself using this ability."; break;
        }
        FloatingTextStringOnCreature(sError, oPC, FALSE);
        return;
    }
    if (GetIsFriend(oTarget))
    {
        switch(GetPlayerLanguage(oPC))
        {
            case PLAYER_LANGUAGE_FRENCH: sError = "Vous ne pouvez pas choisir un allié comme cible avec cette capacité."; break;
            case PLAYER_LANGUAGE_GERMAN: sError = "Du kannst dieses Talent nicht auf einen Verbündeten anwenden."; break;
            case PLAYER_LANGUAGE_ITALIAN: sError = "Non puoi usare questa abilità su di un alleato."; break;
            case PLAYER_LANGUAGE_SPANISH: sError = "No puedes apuntar a un aliado usando esta habilidad."; break;
            case PLAYER_LANGUAGE_POLISH: sError = "Nie mo¿esz obraæ na cel sojusznika u¿ywaj¹c tej zdolnoœci."; break;
            default: sError = "You cannot target an ally using this ability."; break;
        }
        FloatingTextStringOnCreature(sError, oPC, FALSE);
        return;
    }

    int nRace = GetRacialType(oTarget);// Get race of target
    int nClass = GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT, oPC);
    int nDur = nClass * 2;// Duration
    int nBonus = 2;// Bonus value

    effect eAttack = EffectAttackIncrease(nBonus);// Increase attack
    effect eDamage = EffectDamageIncrease(DAMAGE_BONUS_2, DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_SLASHING|DAMAGE_TYPE_PIERCING);// Increase damage
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, nBonus);// Increase saving throws
    effect eSkill = EffectSkillIncrease(SKILL_ALL_SKILLS, nBonus);    // Increase skills

    // Create 'versis racial type' effects
    eAttack = VersusRacialTypeEffect(eAttack, nRace);
    eDamage = VersusRacialTypeEffect(eDamage, nRace);
    eSave = VersusRacialTypeEffect(eSave, nRace);
    eSkill = VersusRacialTypeEffect(eSkill, nRace);

    effect eLink = EffectLinkEffects(eAttack,eDamage);
    eLink = EffectLinkEffects(eLink,eSave);
    eLink = EffectLinkEffects(eLink,eSkill);
    eLink = SupernaturalEffect(eLink);//this effect shouldn't be dispellable

    // Apply effects to caster
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oPC, RoundsToSeconds(nDur));

    // apply fx
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PDK_OATH), oPC);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PDK_WRATH), oTarget);
}

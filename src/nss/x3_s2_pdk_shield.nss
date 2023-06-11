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
    string sError, sVarName = "PDKHeroicTracking_"+ObjectToString(oPC);
    object oTarget = GetSpellTargetObject();
    int nBonus = 4;

    if(GetLocalInt(oMod, sVarName))
    {
        switch(GetPlayerLanguage(oPC))
        {
            case PLAYER_LANGUAGE_FRENCH: sError = "Vous ne pouvez utiliser cette capacité qu'une seule fois par round."; break;
            case PLAYER_LANGUAGE_GERMAN: sError = "Du kannst diese Fähigkeit nur einmal pro Runde anwenden."; break;
            case PLAYER_LANGUAGE_ITALIAN: sError = "Puoi usare questa abilità solo una volta per round."; break;
            case PLAYER_LANGUAGE_SPANISH: sError = "Solo puedes usar esta habilidad una vez por ronda."; break;
            case PLAYER_LANGUAGE_POLISH: sError = "Mo¿esz u¿yæ tej zdolnoœci tylko raz na rundê."; break;
            default: sError = "You can only use this ability once a round."; break;
        }
        FloatingTextStringOnCreature(sError, oPC, FALSE);
        return;
    }
    else if(oPC == oTarget)
    {
        switch(GetPlayerLanguage(oPC))
        {
            case PLAYER_LANGUAGE_FRENCH: sError = "Vous ne pouvez pas vous aider avec cette capacité."; break;
            case PLAYER_LANGUAGE_GERMAN: sError = "Du kannst mit dieser Fähigkeit nicht dir selbst helfen."; break;
            case PLAYER_LANGUAGE_ITALIAN: sError = "Non puoi aiutare te stesso usando questa abilità."; break;
            case PLAYER_LANGUAGE_SPANISH: sError = "No puedes ayudarte a ti mismo usando esta habilidad."; break;
            case PLAYER_LANGUAGE_POLISH: sError = "Nie mo¿esz wspomóc siebie u¿ywaj¹c tej zdolnoœci."; break;
            default: sError = "You cannot aid yourself using this ability."; break;
        }
        FloatingTextStringOnCreature(sError, oPC, FALSE);
        return;
    }
    else if(!GetIsFriend(oTarget))
    {
        switch(GetPlayerLanguage(oPC))
        {
            case PLAYER_LANGUAGE_FRENCH: sError = "Vous ne pouvez pas aider un ennemi avec cette capacité."; break;
            case PLAYER_LANGUAGE_GERMAN: sError = "Du kannst mit dieser Fähigkeit keinem Feind helfen."; break;
            case PLAYER_LANGUAGE_ITALIAN: sError = "Non puoi aiutare un nemico usando questa abilità."; break;
            case PLAYER_LANGUAGE_SPANISH: sError = "No puedes ayudar a un enemigo usando esta habilidad."; break;
            case PLAYER_LANGUAGE_POLISH: sError = "Nie mo¿esz wspomóc przeciwnika u¿ywaj¹c tej zdolnoœci."; break;
            default: sError = "You cannot aid an enemy using this ability."; break;
        }
        FloatingTextStringOnCreature(sError, oPC, FALSE);
        return;
    }
    else if(GetArea(oPC) != GetArea(oTarget))
    {
        switch(GetPlayerLanguage(oPC))
        {
            case PLAYER_LANGUAGE_FRENCH: sError = "Vous ne pouvez pas utiliser cette capacité sur une cible se trouvant dans une zone différente de la vôtre."; break;
            case PLAYER_LANGUAGE_GERMAN: sError = "Du kannst diese Fähigkeit nicht auf ein Ziel in einer anderen Gegend anwenden."; break;
            case PLAYER_LANGUAGE_ITALIAN: sError = "Non puoi usare questa abilità su bersagli in aree differenti."; break;
            case PLAYER_LANGUAGE_SPANISH: sError = "No puedes usar esta habilidad en un objetivo en un área diferente."; break;
            case PLAYER_LANGUAGE_POLISH: sError = "Nie mo¿esz u¿yæ tej zdolnoœci na celu, który znajduje siê na innym obszarze."; break;
            default: sError = "You cannot use this ability on target in different area."; break;
        }
        FloatingTextStringOnCreature(sError, oPC, FALSE);
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

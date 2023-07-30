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

// Canned Shadooow's Polish localisations because they got absolutely destroyed by workflow encoding switches
// kept the other text, otherwise rewrote to be EffectRunScript and keep applying to the picked target until...


// 1) They are in a different area for >30s
// 2) They die or become invalid
// 3) The user dies or become invalid
// 4) The target is no longer a friend of the user

// Also, pause usage while the user is disabled (GetCommandable == FALSE)

#include "nwnx_player"
#include "nwnx_effect"

void RemoveShieldEffects(object oTarget)
{
    effect eTest = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eTest))
    {
        if (GetEffectTag(eTest) == "pdk_heroic_shield")
        {
            if (GetEffectCreator(eTest) == OBJECT_SELF)
            {
                RemoveEffect(oTarget, eTest);
            }
        }
        eTest = GetNextEffect(oTarget);
    }
}

void main()
{
    int nScriptType = GetLastRunScriptEffectScriptType();
    if (nScriptType == 0)
    {
        if(!GetCommandable() || GetIsDead(OBJECT_SELF))
        {
            return;
        }
        
        object oPC = OBJECT_SELF;
        object oMod = GetModule();
        string sError, sVarName = "PDKHeroicTracking_"+ObjectToString(oPC);
        object oTarget = GetSpellTargetObject();
        
        // Keep the usage limit. You still can't switch target more often than once a ronud

        if(GetLocalInt(oMod, sVarName))
        {
            switch(GetPlayerLanguage(oPC))
            {
                case PLAYER_LANGUAGE_FRENCH: sError = "Vous ne pouvez utiliser cette capacité qu'une seule fois par round."; break;
                case PLAYER_LANGUAGE_GERMAN: sError = "Du kannst diese Fähigkeit nur einmal pro Runde anwenden."; break;
                case PLAYER_LANGUAGE_ITALIAN: sError = "Puoi usare questa abilità solo una volta per round."; break;
                case PLAYER_LANGUAGE_SPANISH: sError = "Solo puedes usar esta habilidad una vez por ronda."; break;
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
                default: sError = "You cannot use this ability on a target in a different area."; break;
            }
            FloatingTextStringOnCreature(sError, oPC, FALSE);
            return;
        }
        
        // Slight paranoia: if you put a shield on someone and somehow log out and back in
        // before its script checks, you clear your local variable
        // and could try to put a second one on the same person, and both would coexist happily
        // No taking chances on that.
        RemoveShieldEffects(oTarget);
        object oLast = GetLocalObject(OBJECT_SELF, "pdk_shield_target");
        if (GetIsObjectValid(oLast))
        {
            RemoveShieldEffects(oLast);
        }
        
        effect eScript = EffectRunScript("x3_s2_pdk_shield", "x3_s2_pdk_shield", "x3_s2_pdk_shield", 6.0);
        eScript = TagEffect(eScript, "pdk_heroic_shield");
        eScript = SupernaturalEffect(eScript);
        SetLocalObject(OBJECT_SELF, "pdk_shield_target", oTarget);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eScript, oTarget);
        SetLocalInt(oMod, sVarName, TRUE);
        AssignCommand(oMod, DelayCommand(5.0, SetLocalInt(oMod, sVarName, 0)));
        DeleteLocalInt(OBJECT_SELF, "pdk_shield_diffarea");
    }
    else if (nScriptType == RUNSCRIPT_EFFECT_SCRIPT_TYPE_ON_APPLIED || nScriptType == RUNSCRIPT_EFFECT_SCRIPT_TYPE_ON_INTERVAL)
    {
        // Reasons to pause:
        // 1) Different area, but it hasn't been 30s yet
        // 2) The creator is incapacitated
        object oCreator = GetEffectCreator(GetLastRunScriptEffect());
        
        int bRemove = 0;
        string sReason;
        
        if (!GetIsObjectValid(oCreator) || GetIsDead(oCreator))
        {
            bRemove = 1;
        }
        if (!(GetIsFriend(oCreator, OBJECT_SELF) && GetIsFriend(OBJECT_SELF, oCreator)))
        {
            sReason = "Your Heroic Shield on " + GetName(OBJECT_SELF) + " ended because they are no longer your ally.";
            bRemove = 1;
        }
        if (OBJECT_SELF != GetLocalObject(oCreator, "pdk_shield_target"))
        {
            // They have since given a shield to someone else
            bRemove = 1;
        }
        if (GetArea(oCreator) != GetArea(OBJECT_SELF) && !bRemove)
        {
            if (GetLocalInt(oCreator, "pdk_shield_diffarea") >= 30)
            {
                sReason = "Your Heroic Shield on " + GetName(OBJECT_SELF) + " ended because they have been in another area for too long.";
                DeleteLocalInt(oCreator, "pdk_shield_diffarea");
                bRemove = 1;
            }
            else
            {
                SetLocalInt(oCreator, "pdk_shield_diffarea", GetLocalInt(oCreator, "pdk_shield_diffarea") + 6);
                return;
            }
        }
        else
        {
            DeleteLocalInt(oCreator, "pdk_shield_diffarea");
        }
        
        if (bRemove)
        {
            FloatingTextStringOnCreature(sReason, oCreator, FALSE);
            effect eTest = GetFirstEffect(OBJECT_SELF);
            while (GetIsEffectValid(eTest))
            {
                if (GetEffectTag(eTest) == "pdk_heroic_shield" && GetEffectCreator(eTest) == oCreator)
                {
                    RemoveEffect(OBJECT_SELF, eTest);
                }
                eTest = GetNextEffect(OBJECT_SELF);
            }
        }
        else if (GetCommandable(oCreator))
        {
            effect eAC = EffectACIncrease(4);
            effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
            eAC = EffectLinkEffects(eAC,eDur);
            eAC = ExtraordinaryEffect(eAC);//this effect shouldn't be dispellable
            eAC = TagEffect(eAC, "pdk_heroic_shield");
            // It would be really nice if this also belonged to the actual effect creator
            // and not OBJECT_SELF (the shield recipient)
            eAC = NWNX_Effect_SetEffectCreator(eAC, oCreator);
            effect eVFX = EffectVisualEffect(VFX_IMP_PDK_HEROIC_SHIELD);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAC, OBJECT_SELF, RoundsToSeconds(1));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVFX, OBJECT_SELF);
        }
        
        
    }
    else if (nScriptType == RUNSCRIPT_EFFECT_SCRIPT_TYPE_ON_REMOVED)
    {
        object oCreator = GetEffectCreator(GetLastRunScriptEffect());
        if (GetIsDead(OBJECT_SELF))
        {
            FloatingTextStringOnCreature(GetName(OBJECT_SELF) + " has died. You may now shield another ally.", oCreator, FALSE);
        }
    }
    
    
}

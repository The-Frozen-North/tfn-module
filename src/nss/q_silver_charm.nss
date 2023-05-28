#include "nwnx_creature"
#include "inc_quest"

void CureWerewolf(object oPC, object oTarget, int nCuredAppearance, int nCuredSoundset, string sCuredPortrait)
{
// if not a werewolf, consider them already cured
    if (GetAppearanceType(oTarget) != APPEARANCE_TYPE_WEREWOLF)
    {
        return;
    }

// more than 25% hp, return
// well not exactly. I'm not sure if toughness or constitution is counted
    if (GetCurrentHitPoints(oTarget) > (GetMaxHitPoints(oTarget) / 2))
    {
        FloatingTextStringOnCreature("The silver charm failed in the cure attempt. The target must be injured until it is at least badly wounded.", oPC);
        return;
    }

// simulate unpolymorph visual effect
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_POLYMORPH), oTarget);

// no credit at this point in case players kill them
    SetLocalInt(oTarget, "no_credit", 1);

// heal them as the constitution loss from skin removal can kill them
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(100), oTarget);

    SetCreatureAppearanceType(oTarget, nCuredAppearance);
    SetPortraitResRef(oTarget, sCuredPortrait);

    SetEventScript(oTarget, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "hb_flee_exit");

    AssignCommand(oTarget, ClearAllActions(TRUE));

    SetDescription(oTarget, "This man appears quite happy to be cured of his lycanthropy.");

    NWNX_Creature_SetClassByPosition(oTarget, 1, CLASS_TYPE_COMMONER);
    SetSoundset(oTarget, nCuredSoundset);

    ChangeToStandardFaction(oTarget, STANDARD_FACTION_DEFENDER);

    object oObject = GetFirstObjectInArea(oTarget);

// make everyone friendly and make them stop attacking as well
    while (GetIsObjectValid(oObject))
    {
        if (GetAttackTarget(oObject) == oTarget)
        {
            AssignCommand(oObject, ClearAllActions());
        }

        ClearPersonalReputation(oTarget, oObject);
        ClearPersonalReputation(oObject, oTarget);

        oObject = GetNextObjectInArea(oTarget);
    }

    DeleteLocalObject(oTarget, "GS_CB_ATTACK_TARGET");

    AdvanceQuestSphere(oTarget, 1);

// destroy all creature items, this is where most of their properties are
    DestroyObject(GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oTarget));
    DestroyObject(GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oTarget));
    DestroyObject(GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oTarget));
    DestroyObject(GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTarget));

    DelayCommand(2.0, PlayVoiceChat(VOICE_CHAT_CHEER, oTarget));
}

void main()
{
    object oPC = GetItemActivator();
    object oTarget = GetItemActivatedTarget();

    string sResRef = GetResRef(oTarget);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_REMOVE_CONDITION), oTarget);

    if (GetIsDead(oTarget))
    {
        return;
    }

    if (sResRef == "bran")
    {
        CureWerewolf(oPC, oTarget, APPEARANCE_TYPE_HUMAN_NPC_MALE_11, 177, "po_hu_m_11_");
    }
    else if (sResRef == "geth")
    {
        CureWerewolf(oPC, oTarget, APPEARANCE_TYPE_HUMAN_NPC_MALE_15, 172, "po_hu_m_08_");
    }
    else if (sResRef == "urth")
    {
        CureWerewolf(oPC, oTarget, APPEARANCE_TYPE_HUMAN_NPC_MALE_18, 184, "po_hu_m_13_");
    }
    else
    {
        FloatingTextStringOnCreature("The silver charm appears to have no effect on the creature.", oPC);
    }
}

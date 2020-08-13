//::///////////////////////////////////////////////
//:: Actuvate Item Script
//:: NW_S3_ActItem01
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This fires the event on the module that allows
    for items to have special powers.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 19, 2001
//:://////////////////////////////////////////////

// Jump PC and associates.
void AllJumpToLocation(object oObject, location lLoc);

void main()
{
    object oPC = OBJECT_SELF;
    object oItem = GetSpellCastItem();
    object oTarget = GetSpellTargetObject();
    location lLocal = GetSpellTargetLocation();
    string sTag = GetStringLowerCase(GetTag(oItem));

    if(sTag == "alldemonbottle")
    {
        //Djinn won't come out if PC is in combat
        if (!GetIsInCombat(oPC))
        {
            //Create Djinn in front of player
            object oDjinn = CreateObject(OBJECT_TYPE_CREATURE, "x2_djinn", GetLocation(oPC));
            location lDjinn = GetLocation(oDjinn);
            DelayCommand(0.1, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), lDjinn));
            AssignCommand(oDjinn, SetFacingPoint(GetPosition(oPC)));
            DelayCommand(1.0, AssignCommand(oDjinn, ActionStartConversation(oPC, "x2_djinn", TRUE, FALSE)));
        }
        else
        {
            object oDialog2 = CreateObject(OBJECT_TYPE_PLACEABLE, "x2djinndialog", GetLocation(oPC));
            AssignCommand(oDialog2, SpeakOneLinerConversation());
            DestroyObject(oDialog2, 5.0);
        }
    }
    else if(sTag == "q1barbitem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_TAUNT, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "q1barditem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_PERFORM, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "q1druiditem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_ANIMAL_EMPATHY, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "q1clericitem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_HEAL, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "q1fightertem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_DISCIPLINE, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "q1mageitem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_CONCENTRATION, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "q1paladinitem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_PERSUADE, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "q1rangeritem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_SPOT, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "q1monkitem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_TUMBLE, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "q1rogueitem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_LISTEN, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "q1sorcereritem")
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSkillIncrease(SKILL_SPELLCRAFT, 1), oPC, 120.0);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oPC);
    }
    else if(sTag == "hx_worg_cloak")// Worg cloak. Summons companions.
    {
        location lLoc = GetLocation(oPC);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_WORD), lLoc);
        DelayCommand(0.5, AllJumpToLocation(oPC, lLoc));
    }
    else if(sTag == "70_pcwidget")//Community Patch PC Widget tool
    {
        AssignCommand(oPC,ActionStartConversation(oPC,"70_pcwidget",TRUE,FALSE));
    }
    else
    {
        SignalEvent(GetModule(), EventActivateItem(oItem, lLocal, oTarget));
    }
}

void AllJumpToLocation(object oPC, location lLoc)
{
    AssignCommand(oPC, ClearAllActions(TRUE));
    AssignCommand(oPC, ActionJumpToLocation(lLoc));

    object oPartyMember = GetFirstFactionMember(oPC, FALSE);
    while(GetIsObjectValid(oPartyMember))
    {
        if(oPartyMember != oPC)
        {
            AssignCommand(oPartyMember, ClearAllActions(TRUE));
            AssignCommand(oPartyMember, ActionJumpToLocation(lLoc));
        }
        oPartyMember = GetNextFactionMember(oPC, FALSE);
    }
}
#include "inc_quest"
#include "inc_itemevent"

// Ferdinand's Orb of Capturing

void CaptureCreature(object oTarget)
{
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneParalyze(), oTarget, 2.0);
    SetObjectVisualTransform(oTarget, OBJECT_VISUAL_TRANSFORM_SCALE, 0.01, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR, 2.0);
    DelayCommand(2.0, DestroyObject(oTarget));
}

void UpdateQuestSphere(string sQuest, location lTarget)
{
    object oPC = GetFirstObjectInShape(SHAPE_SPHERE, 30.0, lTarget, FALSE, OBJECT_TYPE_CREATURE);

    while (GetIsObjectValid(oPC))
    {
        if (GetIsPC(oPC))
        {
            if (GetQuestEntry(oPC, sQuest) == 1)
            {
                SetQuestEntry(oPC, sQuest, 2);
                GiveQuestXPToPC(oPC, 2, 8, 0);
            }
        }
        oPC = GetNextObjectInShape(SHAPE_SPHERE, 30.0, lTarget, FALSE, OBJECT_TYPE_CREATURE);
    }
}

void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        object oTarget = GetSpellTargetObject();
        if (GetResRef(oTarget) == "basilisk")
        {
            
            if (GetQuestEntry(OBJECT_SELF, "q_cockatrice_fbasilisk") == 1)
            {
                SetQuestEntry(OBJECT_SELF, "q_cockatrice_fbasilisk", 2);
                CaptureCreature(oTarget);
                FloatingTextStringOnCreature("The orb captures the basilisk.", OBJECT_SELF);
                GiveQuestXPToPC(OBJECT_SELF, 2, 8, 0);
                UpdateQuestSphere("q_cockatrice_fbasilisk", GetLocation(oTarget));
            }
            else
            {
                FloatingTextStringOnCreature("The orb already contains a basilisk.", OBJECT_SELF, FALSE);
            }
        }
        else if (GetResRef(oTarget) == "gorgon")
        {
            if (GetQuestEntry(OBJECT_SELF, "q_cockatrice_fgorgon") == 1)
            {
                SetQuestEntry(OBJECT_SELF, "q_cockatrice_fgorgon", 2);
                CaptureCreature(oTarget);
                FloatingTextStringOnCreature("The orb captures the gorgon.", OBJECT_SELF);
                GiveQuestXPToPC(OBJECT_SELF, 2, 8, 0);
                UpdateQuestSphere("q_cockatrice_fgorgon", GetLocation(oTarget));
            }
            else
            {
                FloatingTextStringOnCreature("The orb already contains a gorgon.", OBJECT_SELF, FALSE);
            }
        }
        else
        {
            FloatingTextStringOnCreature("The orb cannot capture this creature.", OBJECT_SELF, FALSE);
        }
    }
}

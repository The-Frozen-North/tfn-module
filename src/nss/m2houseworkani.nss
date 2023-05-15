//::///////////////////////////////////////////////
//:: Default On Heartbeat
//:: NW_C2_DEFAULT1
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This script will have people perform default
    animations.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 23, 2001
//:://////////////////////////////////////////////
#include "NW_I0_GENERIC"

void main()
{
    int nWorking = GetLocalInt(OBJECT_SELF,"NW_L_Working");
    int nRand = Random(4);
    object oWorkObject1 = GetNearestObjectByTag("M2_WORK_OBJECT1");
    object oWorkObject2 = GetNearestObjectByTag("M2_WORK_OBJECT2");
    object oWorkObject3 = GetNearestObjectByTag("M2_WORK_OBJECT3");
    object oWorkObject4 = GetNearestObjectByTag("M2_WORK_OBJECT4");

    if (GetLocalInt(OBJECT_SELF,"NW_L_HEARTBEAT") == 0)
    {
        switch (nWorking)
        {
            case 0:
                ClearAllActions();
                SetLocalInt(OBJECT_SELF,"NW_L_Working",2);
                switch (nRand)
                {
                    case 0:
                        ActionMoveToObject(oWorkObject1);
                        ActionWait(1.0);
                        ActionDoCommand(SetFacing(GetFacing(oWorkObject1)));
                        ActionDoCommand(SetLocalInt(OBJECT_SELF,"NW_L_Working",1));
                    break;
                    case 1:
                        ActionMoveToObject(oWorkObject2);
                        ActionWait(1.0);
                        ActionDoCommand(SetFacing(GetFacing(oWorkObject2)));
                        ActionDoCommand(SetLocalInt(OBJECT_SELF,"NW_L_Working",1));
                    break;
                    case 2:
                        ActionMoveToObject(oWorkObject3);
                        ActionWait(1.0);
                        ActionDoCommand(SetFacing(GetFacing(oWorkObject3)));
                        ActionDoCommand(SetLocalInt(OBJECT_SELF,"NW_L_Working",1));
                    break;
                    case 3:
                        ActionMoveToObject(oWorkObject4);
                        ActionWait(1.0);
                        ActionDoCommand(SetFacing(GetFacing(oWorkObject4)));
                        ActionDoCommand(SetLocalInt(OBJECT_SELF,"NW_L_Working",1));
                    break;
                }
            break;
            case 1:
                nRand = Random(4);
                SetLocalInt(OBJECT_SELF,"NW_L_Working",0);
                switch (nRand)
                {
                    case 0:
                        PlayAnimation(ANIMATION_LOOPING_GET_MID);
                    break;
                    case 1:
                        PlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD);
                    break;
                    case 2:
                        PlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT);
                    break;
                    case 3:
                        PlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT);
                    break;
                }
            break;
            case 2:
                SetLocalInt(OBJECT_SELF,"NW_L_Working",1);
            break;
        }
        if(GetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING))
        {
            int nDay = FALSE;
            if(GetIsDay() || GetIsDawn())
            {
                nDay = TRUE;
            }
            if(GetLocalInt(OBJECT_SELF, "NW_GENERIC_DAY_NIGHT") != nDay)
            {
                if(nDay == TRUE)
                {
                    SetLocalInt(OBJECT_SELF, "NW_GENERIC_DAY_NIGHT", TRUE);
                }
                else
                {
                    SetLocalInt(OBJECT_SELF, "NW_GENERIC_DAY_NIGHT", FALSE);
                }
                WalkWayPoints();
            }
        }

        if(!GetHasEffect(EFFECT_TYPE_SLEEP))
    {
            if(!GetIsObjectValid(GetAttemptedAttackTarget()) && !GetIsObjectValid(GetAttemptedSpellTarget()))
            {
                if(!GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL) && !IsInConversation(OBJECT_SELF))
                {
                    if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS) || GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN))
                    {
                        if(!GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)))
                        {
                            PlayMobileAmbientAnimations();
                        }
                    }
                    else if(GetIsEncounterCreature() &&
                    !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)))
                    {
                        PlayMobileAmbientAnimations();
                    }
                    else if(GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS) &&
                       !GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN)))
                    {
                        PlayImmobileAmbientAnimations();
                    }
                }
                else
                {
                    DetermineSpecialBehavior();
                }
                if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
                {
                    SignalEvent(OBJECT_SELF, EventUserDefined(1001));
                }
            }
        }
        else
        {
            effect eVis = EffectVisualEffect(VFX_IMP_SLEEP);
            if(d10() > 6)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
            }
        }
    }
}

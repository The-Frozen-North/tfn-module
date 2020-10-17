#include "inc_ai"
//#include "gs_inc_area"
#include "inc_ai_combat"
//#include "gs_inc_flag"
//#include "gs_inc_task"

void main()
{
    //SPECIAL TAGS
    //interact object: GS_AI_IA_{creature tag}

    //ai setting
    int nMatrix = gsAIGetActionMatrix();

    if (nMatrix & GS_AI_ACTION_TYPE_FOLLOW &&
        gsCBTalentFollow())
    {
//        SetAILevel(OBJECT_SELF, AI_LEVEL_LOW);
        return;
    }

    //determine combat state
    if (gsCBGetIsInCombat() &&
        gsCBGetHasAttackTarget())
    {
        //start of combat
        SetLocalInt(OBJECT_SELF, "GS_AI_COMBAT", TRUE);

//        SetAILevel(OBJECT_SELF, AI_LEVEL_NORMAL);
        return;
    }

    //end of combat
    else if (GetLocalInt(OBJECT_SELF, "GS_AI_COMBAT"))
    {
        DeleteLocalInt(OBJECT_SELF, "GS_AI_COMBAT");

        //clear combat data
        gsCBClearAttackTarget();
        gsC2ClearDamage();
    }

    if (nMatrix & GS_AI_ACTION_TYPE_HEAL &&
        gsCBTalentCureCondition() ||
        gsCBTalentHealSelf() ||
        gsCBTalentHealOthers())
    {
 //       SetAILevel(OBJECT_SELF, AI_LEVEL_LOW);
        return;
    }

    if (nMatrix & GS_AI_ACTION_TYPE_REST &&
        GetCurrentHitPoints() < GetMaxHitPoints())
    {
        SetAILevel(OBJECT_SELF, AI_LEVEL_LOW);
        gsAIActionRest();
        return;
    }

//    if (! gsARGetIsAreaActive(GetArea(OBJECT_SELF)))
//    {
//        SetAILevel(OBJECT_SELF, AI_LEVEL_VERY_LOW);
//        ClearAllActions(TRUE);
//        return;
//    }

//    SetAILevel(OBJECT_SELF, AI_LEVEL_LOW);

//    if (gsFLGetFlag(GS_FL_DISABLE_AI)) return;
    if (GetIsDead(OBJECT_SELF))        return;
    if (IsInConversation(OBJECT_SELF)) return;
//    if (gsTADetermineTaskTarget())     return;
//    if (gsAIBehaviorInteract())        return;
//    if (gsAIBehaviorWalkWaypoint())    return;
//    if (gsAIBehaviorAnchor())          return;
    if (Random(100) >= 25)             return;

    ClearAllActions();

    //action matrix
    if (! nMatrix)
    {
        gsAIActionNone();
        return;
    }
    else if (nMatrix == GS_AI_ACTION_TYPE_WALK || GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) < 6)
    {
        if (Random(100) >= 65) gsAIActionNone();
        else                   gsAIActionWalk();
        return;
    }

    int nType;
    if (nMatrix & GS_AI_ACTION_TYPE_CREATURE)  nType |= OBJECT_TYPE_CREATURE;
    if (nMatrix & GS_AI_ACTION_TYPE_DOOR)      nType |= OBJECT_TYPE_DOOR;
    if (nMatrix & GS_AI_ACTION_TYPE_ITEM)      nType |= OBJECT_TYPE_ITEM;
    if (nMatrix & GS_AI_ACTION_TYPE_PLACEABLE) nType |= OBJECT_TYPE_PLACEABLE;

    object oTargetPrevious = GetLocalObject(OBJECT_SELF, "GS_AI_ACTION_TARGET");
    DeleteLocalObject(OBJECT_SELF, "GS_AI_ACTION_TARGET");

    int nFlag              = 0;
    int nNth               = Random(8) + 1;
    object oTarget         = GetNearestObject(nType, OBJECT_SELF, nNth);
    object oObject         = OBJECT_INVALID;

    while (GetIsObjectValid(oTarget) && nNth > 1)
    {
        if (Random(100) >= 80)
        {
            if (nMatrix & GS_AI_ACTION_TYPE_WALK && Random(100) < 65) gsAIActionWalk();
            else                                                      gsAIActionNone();
            return;
        }

        if (oTarget != oTargetPrevious)
        {
            switch (GetObjectType(oTarget))
            {
            case OBJECT_TYPE_CREATURE:
//                if (! gsFLGetFlag(GS_FL_DISABLE_AI, oTarget) &&
//              Only those friendly to commoners will group up.
                if (GetStandardFactionReputation(STANDARD_FACTION_COMMONER) >= 50 &&
                    gsAIGetActionMatrix(oTarget) & GS_AI_ACTION_TYPE_CREATURE &&
//                    ! GetIsObjectValid(gsTAGetLastTaskTrigger(oTarget)) &&
                    ! GetIsPC(oTarget) &&
                    ! GetIsDead(oTarget) &&
                    GetAbilityScore(oTarget, ABILITY_INTELLIGENCE) >= 6)
                {
                    ActionMoveToLocation(GetLocation(oTarget));
                    ActionDoCommand(gsAIActionCreature(oTarget, TRUE));
                    nFlag = TRUE;
                }
                break;

            case OBJECT_TYPE_DOOR:
                if (! GetIsTrapped(oTarget) &&
                    ! GetLocked(oTarget) &&
                    GetIsDoorActionPossible(oTarget, DOOR_ACTION_OPEN))
                {
                    oObject = GetTransitionTarget(oTarget);

                    if (GetIsObjectValid(oObject))
                    {
                        ActionMoveToLocation(GetLocation(oTarget));
                        ActionDoCommand(gsAIActionDoor(oTarget, oObject));
                        nFlag = TRUE;
                    }
                }
                break;

            case OBJECT_TYPE_ITEM:
                if (! GetPlotFlag(oTarget))
                {
                    ActionMoveToLocation(GetLocation(oTarget));
                    ActionDoCommand(gsAIActionItem(oTarget));
                    nFlag = TRUE;
                }
                break;

            case OBJECT_TYPE_PLACEABLE:
                if (! GetIsTrapped(oTarget) &&
                    ! GetLocked(oTarget) &&
                    ! GetIsObjectValid(GetSittingCreature(oTarget)) &&
                    GetUseableFlag(oTarget))
                {
                    ActionMoveToLocation(GetLocation(oTarget));
                    ActionDoCommand(gsAIActionPlaceable(oTarget));
                    nFlag = TRUE;
                }
                break;
            }
        }

        if (nFlag)
        {
            SetLocalObject(OBJECT_SELF, "GS_AI_ACTION_TARGET", oTarget);
            return;
        }

        oTarget = GetNearestObject(nType, OBJECT_SELF, --nNth);
    }

    if (nMatrix & GS_AI_ACTION_TYPE_WALK && Random(100) < 65) gsAIActionWalk();
    else                                                      gsAIActionNone();
}


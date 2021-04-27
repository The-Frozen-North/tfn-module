#include "inc_ai"
//#include "inc_area"
#include "inc_ai_combat"
//#include "inc_flag"
//#include "inc_task"

void main()
{
    //SPECIAL TAGS
    //interact object: GS_AI_IA_{creature tag}

    object oSelf = OBJECT_SELF;

    int bNoWander = GetLocalInt(oSelf, "no_wander");

    // If this is a possessed creature, make sure AI level is set to default,
    // otherwise DMs will experience very poor performance.
    if (GetIsDMPossessed(oSelf))
    {
      SetAILevel(oSelf, AI_LEVEL_DEFAULT);
      return;
    }

    // If our master is in combat, and we're not, get into combat ourselves.
    if (!gsCBGetIsInCombat() && GetIsObjectValid(GetMaster()) &&
           GetIsInCombat(GetMaster()))
    {
      gsCBDetermineCombatRound();
    }

    // Wandering quest NPCs.
    // Skip this, because it's already being handled
    /*
    object oHomeWP = GetLocalObject(OBJECT_SELF, "HOME_WP");
    if (GetIsObjectValid(oHomeWP) && GetArea(OBJECT_SELF) != GetArea(oHomeWP))
    {
      // Go home!
      ClearAllActions();
      ActionMoveToObject(oHomeWP);
      return;
    }
    */

    //ai setting
    int nMatrix = gsAIGetActionMatrix();

    // Stop NPCs crossing areas for now.
    //if (nMatrix & GS_AI_ACTION_TYPE_FOLLOW &&
    //    gsCBTalentFollow())
    //{
    //    SetAILevel(oSelf, AI_LEVEL_LOW);
    //    return;
    //}

    // Do special behaviors <<++ Added By Space Pirate March 2011
    if (spAIDetermineSpecialBehavior() ||
        GetCurrentAction() == ACTION_MOVETOPOINT)
    {
        // We're active, so set our AI level to combat level (normal).
        SetAILevel(oSelf, AI_LEVEL_NORMAL);
        return;
    }

    //determine combat state
    if (gsCBGetIsInCombat() ||
        gsCBGetHasAttackTarget())
    {
        //start of combat
        SetLocalInt(oSelf, "GS_AI_COMBAT", TRUE);

        SetAILevel(oSelf, AI_LEVEL_NORMAL);
        return;
    }

    //end of combat
    else if (GetLocalInt(oSelf, "GS_AI_COMBAT"))
    {
        DeleteLocalInt(oSelf, "GS_AI_COMBAT");

        //clear combat data
        gsCBClearAttackTarget();
        gsC2ClearDamage();

        // Set a timeout so that creatures don't rest within two RL minutes of combat.
        SetLocalInt(oSelf, "GS_AI_RECENT_COMBAT", gsTIGetActualTimestamp() + 120);
    }

    if (nMatrix & GS_AI_ACTION_TYPE_HEAL &&
        gsCBTalentCureCondition() ||
        gsCBTalentHealSelf() ||
        gsCBTalentHealOthers())
    {
        SetAILevel(oSelf, AI_LEVEL_LOW);
        return;
    }

    if (nMatrix & GS_AI_ACTION_TYPE_REST &&
        GetCurrentHitPoints() < GetMaxHitPoints() &&
        GetLocalInt(oSelf, "GS_AI_RECENT_COMBAT") < gsTIGetActualTimestamp())
    {
        SetAILevel(oSelf, AI_LEVEL_LOW);
        gsAIActionRest();
        return;
    }
/*
    if (nMatrix & GS_AI_ACTION_TYPE_TRAP &&
        gsAIActionTrap())
    {
        SetAILevel(oSelf, AI_LEVEL_LOW);
        return;
    }
*/
/*
    if (! gsARGetIsAreaActive(GetArea(oSelf)))
    {
        SetAILevel(oSelf, AI_LEVEL_VERY_LOW);
                if (GetLocalString(oSelf, "DAY_TAG") != "" || GetLocalString(oSelf, "NIGHT_TAG") != "")
                {
                    return;
                }
        ClearAllActions(TRUE);
        return;
    }
*/
    if (IsInConversation(oSelf))
    {
        SetAILevel(oSelf, GU_AI_LEVEL_DIALOGUE);
        return;
    }

    SetAILevel(oSelf, AI_LEVEL_LOW);

//    if (gsFLGetFlag(GS_FL_DISABLE_AI)) return;
    if (GetIsDead(oSelf))              return;
//    if (gsTADetermineTaskTarget())     return;
    if (gsAIBehaviorInteract())        return;
    if (gsAIBehaviorWalkWaypoint())    return;
    if (gsAIBehaviorAnchor())          return;
    if (Random(100) >= 25)             return;

    ClearAllActions();

    //action matrix
    if (! nMatrix)
    {
        gsAIActionNone();
        return;
    }
    else if (nMatrix == GS_AI_ACTION_TYPE_WALK ||
             GetAbilityScore(oSelf, ABILITY_INTELLIGENCE) < 6)
    {
        if (Random(100) >= 65) gsAIActionNone();
        else                   gsAIActionWalk();
        return;
    }

    int nType;
    if (nMatrix & GS_AI_ACTION_TYPE_CREATURE)  nType |= OBJECT_TYPE_CREATURE;
    //if (nMatrix & GS_AI_ACTION_TYPE_DOOR)      nType |= OBJECT_TYPE_DOOR;
    // Disabled - stop NPCs picking things up.
    //if (nMatrix & GS_AI_ACTION_TYPE_ITEM)      nType |= OBJECT_TYPE_ITEM;
    if (nMatrix & GS_AI_ACTION_TYPE_PLACEABLE) nType |= OBJECT_TYPE_PLACEABLE;

    object oTargetPrevious = GetLocalObject(oSelf, "GS_AI_ACTION_TARGET");
    DeleteLocalObject(oSelf, "GS_AI_ACTION_TARGET");

    int nFlag              = 0;
    int nNth               = Random(8) + 1;
    object oTarget         = GetNearestObject(nType, oSelf, nNth);
    object oObject         = oSelf;

    while (GetIsObjectValid(oTarget) && nNth > 1)
    {
        if (Random(100) >= 50)
        {
            if (nMatrix & GS_AI_ACTION_TYPE_WALK && Random(100) < 65 && bNoWander == 0) gsAIActionWalk();
            else                                                      gsAIActionNone();
            return;
        }

        if (oTarget != oTargetPrevious)
        {
            switch (GetObjectType(oTarget))
            {
            case OBJECT_TYPE_CREATURE:
//                if (! gsFLGetFlag(GS_FL_DISABLE_AI, oTarget) &&
                  if (  gsAIGetActionMatrix(oTarget) & GS_AI_ACTION_TYPE_CREATURE &&
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
/*
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
*/
/*
            case OBJECT_TYPE_ITEM:
                if (! GetPlotFlag(oTarget))
                {
                    ActionMoveToLocation(GetLocation(oTarget));
                    ActionDoCommand(gsAIActionItem(oTarget));
                    nFlag = TRUE;
                }
                break;
*/
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
            SetLocalObject(oSelf, "GS_AI_ACTION_TARGET", oTarget);
            return;
        }

        oTarget = GetNearestObject(nType, oSelf, --nNth);
    }

    if (nMatrix & GS_AI_ACTION_TYPE_WALK && Random(100) < 65 && bNoWander == 0) gsAIActionWalk();
    else                                                      gsAIActionNone();
}


/* ARTIFICIAL INTELLIGENCE Library by Gigaschatten */

#include "inc_ai_waypoint"

//void main() {}

const int GS_AI_ACTION_TYPE_NONE      =   0;
const int GS_AI_ACTION_TYPE_WALK      =   1;
const int GS_AI_ACTION_TYPE_CREATURE  =   2;
const int GS_AI_ACTION_TYPE_DOOR      =   4;
const int GS_AI_ACTION_TYPE_ITEM      =   8;
const int GS_AI_ACTION_TYPE_PLACEABLE =  16;
const int GS_AI_ACTION_TYPE_REST      =  32;
const int GS_AI_ACTION_TYPE_FOLLOW    =  64;
const int GS_AI_ACTION_TYPE_HEAL      = 128;
const int GS_AI_ACTION_TYPE_ALL       = 255;

//return default behavior of oCreature conditioned by creature properties
int gsAIGetDefaultActionMatrix(object oCreature = OBJECT_SELF);
//return behavior of oCreature
int gsAIGetActionMatrix(object oCreature = OBJECT_SELF);
//enable/disable nAction for oCreature
void gsAISetActionMatrix(int nAction, int nValid = TRUE, object oCreature = OBJECT_SELF);
//disable all actions for oCreature
void gsAIClearActionMatrix(object oCreature = OBJECT_SELF);
//return TRUE if caller is assigned to anchor
int gsAIBehaviorAnchor();
//return TRUE if caller is assigned to placeable
int gsAIBehaviorInteract();
//return TRUE if caller is assigned to waypoint
int gsAIBehaviorWalkWaypoint();
//caller plays ambient animations
void gsAIActionNone();
//internally used
void _gsAIActionNone();
//caller walks randomly
void gsAIActionWalk();
//caller starts conversation with creature oTarget
void gsAIActionCreature(object oTarget, int nInitialize = FALSE);
//internally used
void _gsAIActionCreature(object oTarget);
//caller uses door oTarget
void gsAIActionDoor(object oTarget, object oTransition);
//caller picks up item oTarget
void gsAIActionItem(object oTarget);
//caller interacts with placeable oTarget
void gsAIActionPlaceable(object oTarget);

int gsAIGetDefaultActionMatrix(object oCreature = OBJECT_SELF)
{
    int nMatrix = GS_AI_ACTION_TYPE_ALL;

    if (GetAbilityScore(oCreature, ABILITY_INTELLIGENCE) < 6)
    {
        nMatrix &= ~(GS_AI_ACTION_TYPE_CREATURE |
                     GS_AI_ACTION_TYPE_DOOR |
                     GS_AI_ACTION_TYPE_ITEM |
                     GS_AI_ACTION_TYPE_PLACEABLE |
                     GS_AI_ACTION_TYPE_HEAL);
    }

    switch (GetRacialType(OBJECT_SELF))
    {
    case RACIAL_TYPE_ABERRATION:
        nMatrix &= ~(GS_AI_ACTION_TYPE_CREATURE |
                     GS_AI_ACTION_TYPE_DOOR |
                     GS_AI_ACTION_TYPE_ITEM |
                     GS_AI_ACTION_TYPE_PLACEABLE);
        break;

    case RACIAL_TYPE_ANIMAL:
        nMatrix &= ~(GS_AI_ACTION_TYPE_CREATURE |
                     GS_AI_ACTION_TYPE_DOOR |
                     GS_AI_ACTION_TYPE_ITEM |
                     GS_AI_ACTION_TYPE_PLACEABLE |
                     GS_AI_ACTION_TYPE_HEAL);
        break;

    case RACIAL_TYPE_BEAST:
        nMatrix &= ~(GS_AI_ACTION_TYPE_CREATURE |
                     GS_AI_ACTION_TYPE_DOOR |
                     GS_AI_ACTION_TYPE_ITEM |
                     GS_AI_ACTION_TYPE_PLACEABLE |
                     GS_AI_ACTION_TYPE_HEAL);
        break;

    case RACIAL_TYPE_CONSTRUCT:
        nMatrix &= ~(GS_AI_ACTION_TYPE_CREATURE |
                     GS_AI_ACTION_TYPE_DOOR |
                     GS_AI_ACTION_TYPE_ITEM |
                     GS_AI_ACTION_TYPE_PLACEABLE |
                     GS_AI_ACTION_TYPE_REST |
                     GS_AI_ACTION_TYPE_HEAL);
        break;

    case RACIAL_TYPE_DRAGON:
        break;

    case RACIAL_TYPE_DWARF:
        break;

    case RACIAL_TYPE_ELEMENTAL:
        nMatrix &= ~(GS_AI_ACTION_TYPE_CREATURE |
                     GS_AI_ACTION_TYPE_DOOR |
                     GS_AI_ACTION_TYPE_ITEM |
                     GS_AI_ACTION_TYPE_PLACEABLE);
        break;

    case RACIAL_TYPE_ELF:
        break;

    case RACIAL_TYPE_FEY:
        break;

    case RACIAL_TYPE_GIANT:
        break;

    case RACIAL_TYPE_GNOME:
        break;

    case RACIAL_TYPE_HALFELF:
        break;

    case RACIAL_TYPE_HALFLING:
        break;

    case RACIAL_TYPE_HALFORC:
        break;

    case RACIAL_TYPE_HUMAN:
        break;

    case RACIAL_TYPE_HUMANOID_GOBLINOID:
        break;

    case RACIAL_TYPE_HUMANOID_MONSTROUS:
        break;

    case RACIAL_TYPE_HUMANOID_ORC:
        break;

    case RACIAL_TYPE_HUMANOID_REPTILIAN:
        break;

    case RACIAL_TYPE_MAGICAL_BEAST:
        nMatrix &= ~(GS_AI_ACTION_TYPE_CREATURE |
                     GS_AI_ACTION_TYPE_DOOR |
                     GS_AI_ACTION_TYPE_ITEM |
                     GS_AI_ACTION_TYPE_PLACEABLE |
                     GS_AI_ACTION_TYPE_HEAL);
        break;

    case RACIAL_TYPE_OOZE:
        nMatrix &= ~(GS_AI_ACTION_TYPE_CREATURE |
                     GS_AI_ACTION_TYPE_DOOR |
                     GS_AI_ACTION_TYPE_ITEM |
                     GS_AI_ACTION_TYPE_PLACEABLE |
                     GS_AI_ACTION_TYPE_HEAL);
        break;

    case RACIAL_TYPE_OUTSIDER:
        break;

    case RACIAL_TYPE_SHAPECHANGER:
        break;

    case RACIAL_TYPE_UNDEAD:
        nMatrix &= ~(GS_AI_ACTION_TYPE_CREATURE |
                     GS_AI_ACTION_TYPE_DOOR |
                     GS_AI_ACTION_TYPE_ITEM |
                     GS_AI_ACTION_TYPE_PLACEABLE |
                     GS_AI_ACTION_TYPE_REST |
                     GS_AI_ACTION_TYPE_HEAL);
        break;

    case RACIAL_TYPE_VERMIN:
        nMatrix &= ~(GS_AI_ACTION_TYPE_CREATURE |
                     GS_AI_ACTION_TYPE_DOOR |
                     GS_AI_ACTION_TYPE_ITEM |
                     GS_AI_ACTION_TYPE_PLACEABLE |
                     GS_AI_ACTION_TYPE_HEAL);
        break;
    }

    return nMatrix;
}
//----------------------------------------------------------------
int gsAIGetActionMatrix(object oCreature = OBJECT_SELF)
{
    return GetLocalInt(oCreature, "GS_AI_ACTION_MATRIX");
}
//----------------------------------------------------------------
void gsAISetActionMatrix(int nAction, int nValid = TRUE, object oCreature = OBJECT_SELF)
{
    int nMatrix = gsAIGetActionMatrix(oCreature);

    if (nValid) nMatrix |= nAction;
    else        nMatrix &= ~nAction;

    SetLocalInt(oCreature, "GS_AI_ACTION_MATRIX", nMatrix);
}
//----------------------------------------------------------------
void gsAIClearActionMatrix(object oCreature = OBJECT_SELF)
{
    DeleteLocalInt(oCreature, "GS_AI_ACTION_MATRIX");
}
//----------------------------------------------------------------
int gsAIBehaviorAnchor()
{
    string sTag     = "GS_AI_ANCHOR_" + GetTag(OBJECT_SELF);
    object oTarget  = GetObjectByTag(sTag);
    float fDistance = GetDistanceToObject(oTarget);

    if (GetIsObjectValid(oTarget) &&
        (fDistance < 0.0 ||
         fDistance > 10.0))
    {
        ClearAllActions(TRUE);
        ActionForceMoveToLocation(GetLocation(oTarget), FALSE, 4.0);

        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsAIBehaviorInteract()
{
    object oTarget = GetObjectByTag("GS_AI_IA_" + GetTag(OBJECT_SELF));

    if (GetIsObjectValid(oTarget))
    {
        //if (! GetIsObjectValid(GetSittingCreature(oTarget)))       ActionInteractObject(oTarget);
        //if (Random(100) >= 50 && GetCurrentAction() == ACTION_SIT) SpeakOneLinerConversation();

        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsAIBehaviorWalkWaypoint()
{
    if (gsWPGetHasWaypoint())
    {
        location lActual   = GetLocation(OBJECT_SELF);
        location lPrevious = GetLocalLocation(OBJECT_SELF, "GS_AI_LOCATION");
        vector vActual     = GetPositionFromLocation(lActual);
        vector vPrevious   = GetPositionFromLocation(lPrevious);

        if (vActual == vPrevious) gsWPWalkWaypoint();
        SetLocalLocation(OBJECT_SELF, "GS_AI_LOCATION", lActual);

        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
void gsAIActionNone()
{
    _gsAIActionNone();
    ActionWait(IntToFloat(Random(21)) / 10.0 + 2.0);
    ActionDoCommand(gsAIActionNone());
}
//----------------------------------------------------------------
void _gsAIActionNone()
{
    switch (Random(7))
    {
    case 0:
        ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT);
        break;

    case 1:
        ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT);
        break;

    case 2:
        ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_BORED);
        break;

    case 3:
        ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD);
        break;

    case 4:
        ActionPlayAnimation(ANIMATION_LOOPING_PAUSE, 1.0, IntToFloat(Random(21)) / 10.0 + 2.0);
        break;

    case 5:
        ActionPlayAnimation(ANIMATION_LOOPING_PAUSE2, 1.0, IntToFloat(Random(21)) / 10.0 + 2.0);
        break;

    case 6:
        //SpeakOneLinerConversation();
        break;
    }
}
//----------------------------------------------------------------
void gsAIActionWalk()
{
    ActionRandomWalk();
}
//----------------------------------------------------------------
void gsAIActionCreature(object oTarget, int nInitialize = FALSE)
{
    _gsAIActionCreature(oTarget);

    if (nInitialize)
    {
        object oSelf = OBJECT_SELF;

        AssignCommand(oTarget, ClearAllActions());
        AssignCommand(oTarget, gsAIActionCreature(oSelf));
    }

    ActionWait(IntToFloat(Random(21)) / 10.0 + 2.0);
    ActionDoCommand(gsAIActionCreature(oTarget));
}
//----------------------------------------------------------------
void _gsAIActionCreature(object oTarget)
{
    float fDistance = GetDistanceToObject(oTarget);
    if (fDistance < 0.0 || fDistance > 1.5) return;
    int nInferior   = GetChallengeRating(OBJECT_SELF) < GetChallengeRating(oTarget);

    ActionDoCommand(SetFacingPoint(GetPosition(oTarget)));

    switch (Random(6))
    {
    case 0: //SpeakOneLinerConversation();
            ActionPlayAnimation(ANIMATION_LOOPING_TALK_NORMAL, 1.0, IntToFloat(Random(21)) / 10.0 + 2.0);
            break;

    case 1: //SpeakOneLinerConversation();
            if (nInferior) ActionPlayAnimation(ANIMATION_LOOPING_TALK_PLEADING,  1.0, IntToFloat(Random(21)) / 10.0 + 2.0);
            else           ActionPlayAnimation(ANIMATION_LOOPING_TALK_FORCEFUL,  1.0, IntToFloat(Random(21)) / 10.0 + 2.0);
            break;

    case 2: if (nInferior) ActionPlayAnimation(ANIMATION_LOOPING_TALK_NORMAL,    1.0, IntToFloat(Random(21)) / 10.0 + 2.0);
            else           {PlayVoiceChat(VOICE_CHAT_LAUGH);
                            ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING, 1.0, IntToFloat(Random(11)) / 10.0 + 1.0);}
            break;

    case 3: ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT);
            break;

    case 4: ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT);
            break;

    case 5: ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD);
            break;
    }
}
//----------------------------------------------------------------
void gsAIActionDoor(object oTarget, object oTransition)
{
    float fDistance = GetDistanceToObject(oTarget);
    if (fDistance < 0.0 || fDistance > 1.5) return;

    ActionOpenDoor(oTarget);
    ActionJumpToObject(oTransition);
    ActionDoCommand(gsAIActionWalk());
}
//----------------------------------------------------------------
void gsAIActionItem(object oTarget)
{
    float fDistance = GetDistanceToObject(oTarget);
    if (fDistance < 0.0 || fDistance > 1.5) return;

    ActionPickUpItem(oTarget);
    ActionDoCommand(gsAIActionWalk());
}
//----------------------------------------------------------------
void gsAIActionPlaceable(object oTarget)
{
    float fDistance = GetDistanceToObject(oTarget);
    if (fDistance < 0.0 || fDistance > 1.5) return;

    ActionDoCommand(SetFacingPoint(GetPosition(oTarget)));

    if (GetHasInventory(oTarget))
    {
        ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 2.5);
        DelayCommand(1.0, AssignCommand(oTarget, ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN)));
        DelayCommand(5.0, AssignCommand(oTarget, ActionPlayAnimation(ANIMATION_PLACEABLE_CLOSE)));
    }
    //else
    //{
    //    ActionInteractObject(oTarget);
    //}
}
//----------------------------------------------------------------
void gsAIActionRest()
{
    ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 1.0, 7.0);

    if (GetCurrentHitPoints() >= GetMaxHitPoints() - 6)
        ForceRest(OBJECT_SELF);
    else
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(6), OBJECT_SELF);
}


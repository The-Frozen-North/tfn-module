#include "inc_debug"
#include "nw_i0_generic"

// assigns normal creature scripts to this follower and deletes some local master related variables
void AssignNormalScripts(object oCreature);
void AssignNormalScripts(object oCreature)
{
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "ai_onblocked");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "ai_ondamaged");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "ai_onconverse");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "ai_ondisturb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "ai_oncombrnd");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "ai_onheartb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "ai_onattacked");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "ai_onpercep");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "ai_onrest");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "ai_onspellcast");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "ai_onuserdef");

    DeleteLocalInt(oCreature,"NW_COM_MODE_COMBAT");
    DeleteLocalInt(oCreature,"NW_COM_MODE_MOVEMENT");
    DeleteLocalObject(oCreature, "NW_L_FORMERMASTER");
}

// assigns the henchman scripts to this follower. kinda hacky
void AssignHenchmanScripts(object oCreature);
void AssignHenchmanScripts(object oCreature)
{
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "hen_onblocked");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "hen_ondamaged");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "hen_onconvers");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "hen_ondisturb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "hen_oncombrnd");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "hen_onheartb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "hen_onattacked");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "hen_onpercep");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "hen_onrest");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "hen_onspellcas");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "hen_onuserdef");

    ExecuteScript("hen_onspawn", oCreature);
}

// get how many followers this player has (not henchman or any other associates)
int GetFollowerCount(object oPlayer);
int GetFollowerCount(object oPlayer)
{
    int nCount = 0;

    if (GetIsPC(oPlayer))
    {
        object oParty = GetFirstFactionMember(oPlayer, FALSE);

        while (GetIsObjectValid(oParty))
        {
            if ((GetLocalInt(oParty, "follower") == 1) && GetMaster(oParty) == oPlayer) nCount = nCount + 1;
            oParty = GetNextFactionMember(oPlayer, FALSE);
        }
    }
    return nCount;
}

object GetFollowerByIndex(object oPlayer, int nIndex=0)
{
    if (GetIsPC(oPlayer))
    {
        object oParty = GetFirstFactionMember(oPlayer, FALSE);

        while (GetIsObjectValid(oParty))
        {
            if ((GetLocalInt(oParty, "follower") == 1) && GetMaster(oParty) == oPlayer)
            {
                if (nIndex <= 0) { return oParty; }
                nIndex--;
            }
            oParty = GetNextFactionMember(oPlayer, FALSE);
        }
    }
    return OBJECT_INVALID;
}

// determines if this follower has a stored master
int CheckFollowerMaster(object oFollower, object oPlayer);
int CheckFollowerMaster(object oFollower, object oPlayer)
{
    string sUUID = GetLocalString(oFollower, "master");

    if (sUUID == "") return FALSE;

    object oUUID = GetObjectByUUID(sUUID);

    if (oUUID == oPlayer)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

// recruits this follower to a PC
void SetFollowerMaster(object oFollower, object oPlayer);
void SetFollowerMaster(object oFollower, object oPlayer)
{
    if (GetLocalInt(oFollower, "follower") != 1) return;

    SetTag(oFollower, "follower");

    SetAssociateState(NW_ASC_DISTANCE_2_METERS, TRUE, oFollower);

// Make sure oPlayer is actually a player
    if (!GetIsPC(oPlayer)) return;

    SetLocalString(oFollower, "master", GetObjectUUID(oPlayer));

    AddHenchman(oPlayer, oFollower);
    AssignHenchmanScripts(oFollower);
}

// dismisse the follower. the follower will move towards their spawn location and destroy itself on the way
void DismissFollower(object oFollower);
void DismissFollower(object oFollower)
{
    DeleteLocalInt(oFollower, "no_master_count");
    DeleteLocalString(oFollower, "master");

    SetCombatCondition(X0_COMBAT_FLAG_RANGED, FALSE, oFollower);
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE, oFollower);
    SetAssociateState(NW_ASC_DISTANCE_2_METERS, FALSE, oFollower);

    RemoveHenchman(GetMaster(oFollower), oFollower);

    PlayVoiceChat(VOICE_CHAT_GOODBYE, oFollower);
    AssignNormalScripts(oFollower);
    AssignCommand(oFollower, ActionMoveToLocation(GetLocalLocation(oFollower, "spawn")));
    DestroyObject(oFollower, 10.0);
}


// gets the master based on the uuid stored on this object
object GetMasterByStoredUUID(object oFollower);
object GetMasterByStoredUUID(object oFollower)
{
    string sUUID = GetLocalString(oFollower, "master");

    if (sUUID == "") return OBJECT_INVALID;

    return GetObjectByUUID(sUUID);
}

// helper function to add the follower back to a party when a PC disconnects and logs back in
// also fires them after a set amount of time
void CheckOrRehireFollowerMasterAssignment(object oFollower);
void CheckOrRehireFollowerMasterAssignment(object oFollower)
{
    string sUUID = GetLocalString(oFollower, "master");

    if (sUUID == "") return;

    object oMaster = GetMaster(oFollower);
    object oUUID = GetMasterByStoredUUID(oFollower);

    if (GetIsObjectValid(oMaster))
    {
        DeleteLocalInt(oFollower, "no_master_count");
    }
    else if (!GetIsObjectValid(oMaster) && GetIsObjectValid(oUUID))
    {
        SetFollowerMaster(oFollower, oUUID);
    }
    else
    {
        int nCount = GetLocalInt(oFollower, "no_master_count");

        if (nCount >= 25)
        {
            DismissFollower(oFollower);
        }
        else
        {
            SetLocalInt(oFollower, "no_master_count", nCount + 1);
        }
     }
}

//void main() {}

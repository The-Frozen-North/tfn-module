#include "1_inc_debug"
#include "nw_i0_generic"

void AssignNormalScripts(object oCreature)
{
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "3_ai_onblocked");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "3_ai_ondamaged");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "3_ai_onconverse");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "3_ai_ondisturb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "3_ai_oncombrnd");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "3_ai_onheartb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "3_ai_onattacked");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "3_ai_onpercep");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "3_ai_onrest");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "3_ai_onspellcast");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "3_ai_onuserdef");
}

void AssignHenchmanScripts(object oCreature)
{
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "3_hen_onblocked");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "3_hen_ondamaged");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "3_hen_onconvers");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "3_ai_ondisturb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "3_hen_oncombrnd");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "3_hen_onheartb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "3_hen_onattacked");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "3_hen_onpercep");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "3_hen_onrest");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "3_hen_onspellcas");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "3_hen_onuserdef");
}

int GetFollowerCount(object oPlayer)
{
    int nCount = 0;

    if (GetIsPC(oPlayer))
    {
        object oParty = GetFirstFactionMember(oPlayer, FALSE);

        while (GetIsObjectValid(oParty))
        {
            if (GetResRef(oParty) == "militia" && GetMaster(oParty) == oPlayer) nCount = nCount + 1;
            oParty = GetNextFactionMember(oPlayer, FALSE);
        }
    }
    return nCount;
}

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

void SetFollowerMaster(object oFollower, object oPlayer)
{
// Only miltia for now
    if (GetResRef(oFollower)!= "militia") return;

    SetAssociateState(NW_ASC_DISTANCE_2_METERS, TRUE, oFollower);

// Make sure oPlayer is actually a player
    if (!GetIsPC(oPlayer)) return;

    SetLocalString(oFollower, "master", GetObjectUUID(oPlayer));

    AddHenchman(oPlayer, oFollower);
    AssignHenchmanScripts(oFollower);
}

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
}

void CheckOrRehireFollowerMasterAssignment(object oFollower)
{
    string sUUID = GetLocalString(oFollower, "master");

    if (sUUID == "") return;

    object oMaster = GetMaster(oFollower);
    object oUUID = GetObjectByUUID(sUUID);

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

#include "util_i_csvlists"
#include "nwnx_creature"
#include "nwnx_visibility"
#include "inc_quest"

void PortalCheckHB(object oPortal)
{
    if (!GetIsObjectValid(oPortal)) { return; }
    object oTest = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oPortal);
    if (GetIsObjectValid(oTest) && GetArea(oTest) == GetArea(oPortal))
    {
        DelayCommand(10.0, PortalCheckHB(oPortal));
        return;
    }
    DestroyObject(oPortal);
}

void main()
{
    object oPC = GetEnteringObject();
    
    if (GetIsPC(oPC))
    {
        string sList = GetLocalString(OBJECT_SELF, "pcs_entered");
        string sPC = GetPCPublicCDKey(oPC) + GetName(oPC);
        int nQuestState = GetQuestEntry(oPC, "q_golems");
        // Hide the power source if PC has taken it
        if (nQuestState == 21 || nQuestState == 27 || nQuestState == 51)
        {
            NWNX_Visibility_SetVisibilityOverride(oPC, GetObjectByTag("maker3_powersource"), NWNX_VISIBILITY_HIDDEN);
        }
        
        if (SQLocalsPlayer_GetInt(oPC, "maker_password"))
        {
            object oGhost = GetObjectByTag("maker3_ghost");
            NWNX_Visibility_SetVisibilityOverride(oPC, oGhost, NWNX_VISIBILITY_HIDDEN);
        }
        
        // If guardian golem from level 2 is alive and not bound, we don't
        // add PCs to the ambush list and spawn a portal so they can get out
        // Otherwise if you log out down here it is basically a death sentence
        object oGuardianGolem = GetObjectByTag("maker2_guardian");
        int bGuardianGolemIsActive = 0;
        if (!GetIsDead(oGuardianGolem) && GetIsObjectValid(oGuardianGolem))
        {
            object oControl = GetObjectByTag("q4b_action_lever");
            object oBound = GetLocalObject(oControl, "golem_bound");
            if (!GetIsObjectValid(oBound) || oBound != oGuardianGolem)
            {
                bGuardianGolemIsActive = 1;
            }
        }
        
        if (bGuardianGolemIsActive)
        {
            // Make a portal
            object oPortal = CreateObject(OBJECT_TYPE_PLACEABLE, "portalblue", GetLocation(GetWaypointByTag("maker3_battleground_mid")));
            SetPlotFlag(oPortal, 1);
            DelayCommand(30.0, PortalCheckHB(oPortal));
            SetEventScript(oPortal, EVENT_SCRIPT_PLACEABLE_ON_USED, "maker_portal");
        }
        
        if (!HasListItem(sList, sPC))
        {
            sList = AddListItem(sList, sPC, TRUE);
            if (!bGuardianGolemIsActive)
            {
                SetLocalString(OBJECT_SELF, "pcs_entered", sList);
            }
            
            
            // Update initial faction reps
            
            int i;
            for (i=0; i<4; i++)
            {
                int nFactionID;
                int bFriendly = i>1 ? 1 : 0;
                if (i == 0)
                {
                    nFactionID = GetLocalInt(OBJECT_SELF, "aghaaz_faction");
                    if ((nQuestState >= 10 && nQuestState < 20) || nQuestState == 50 || nQuestState == 3 || nQuestState == 4)
                    {
                        bFriendly = 1;
                    }
                }
                else if (i == 1)
                {
                    nFactionID = GetLocalInt(OBJECT_SELF, "ferron_faction");
                    if ((nQuestState >= 20 && nQuestState < 30) || nQuestState == 51 || nQuestState == 2 || nQuestState == 4)
                    {
                        bFriendly = 1;
                    }
                }
                else if (i == 2)
                {
                    nFactionID = GetLocalInt(OBJECT_SELF, "ferronboss_faction");
                }
                else
                {
                    nFactionID = GetLocalInt(OBJECT_SELF, "aghaazboss_faction");
                }
                
                if (nFactionID > 0)
                {
                    // Find a member of the faction ID to make angry
                    int n=1;
                    object oWP = GetWaypointByTag("maker3_battleground_mid");
                    while (1)
                    {
                        object oTest = GetNearestObject(OBJECT_TYPE_CREATURE, oWP, n);
                        if (NWNX_Creature_GetFaction(oTest) == nFactionID)
                        {
                            ClearPersonalReputation(oPC, oTest);
                            if (bFriendly)
                            {
                                AdjustReputation(oPC, oTest, 50);
                            }
                            break;
                        }
                        n++;
                        if (!GetIsObjectValid(oTest))
                        {
                            break;
                        }
                    }
                }
            }
        }
    }
}

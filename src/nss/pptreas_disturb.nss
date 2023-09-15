#include "nw_i0_spells"
#include "inc_ctoken"
#include "nwnx_player"

int ValidThiefChecker(object oTarget, object oThief)
{
    if (GetIsPC(oTarget)) return FALSE;
    if (GetIsDead(oTarget)) return FALSE;
    if (GetLocalInt(oTarget, "unconscious") == 1) return FALSE;
    if (GetAssociateType(oTarget) > 0 ) return FALSE;
    //if (GetStandardFactionReputation(STANDARD_FACTION_COMMONER, OBJECT_SELF) <= 50 && GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, OBJECT_SELF) <= 50) return FALSE;
    if (!GetObjectSeen(oThief, oTarget) && !LineOfSightObject(oThief, oTarget)) return FALSE;

    return AmIAHumanoid(oTarget);
}

void VoidBeginConversation(string sResRef, object oConversationTarget)
{
    BeginConversation(sResRef, oConversationTarget);
}

void ConfrontThief(object oTarget, object oThief, object oItem)
{
    int nCrimeGold = GetGoldPieceValue(oItem);
    
    if (!GetIdentified(oItem))
    {
        SetIdentified(oItem, TRUE);
        nCrimeGold = GetGoldPieceValue(oItem);
        SetIdentified(oItem, FALSE);
    }
    //nCrimeGold *= 2;
    nCrimeGold += nCrimeGold / 2;
    
    SetLocalInt(oThief, "crime_gold", nCrimeGold);
    NWNX_Player_SetCustomToken(oThief, CTOKEN_CRIME_GOLD, IntToString(nCrimeGold));
    
    AssignCommand(oTarget, ClearAllActions());
    //AssignCommand(oThief, ClearAllActions());
    AssignCommand(oTarget, VoidBeginConversation("confront_thief", oThief));
}

void main()
{
    object oPC = GetLastDisturbed();

    if (!GetIsPC(oPC)) return;

    object oItem = GetInventoryDisturbItem();

// do not care about items that are not stolen. though we may need to handle gold case
    if (!GetStolenFlag(oItem)) return;

    if (GetInventoryDisturbType() == INVENTORY_DISTURB_TYPE_ADDED) return;

    ExecuteScript("remove_invis", oPC);
    SetActionMode(oPC, ACTION_MODE_STEALTH, FALSE);

    float fRadius = 15.0;

    location lLocation = GetLocation(OBJECT_SELF);

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation);
    while(GetIsObjectValid(oTarget))
    {   
        if(ValidThiefChecker(oTarget, oPC))
        {
            int nDC = GetSkillRank(SKILL_SPOT, oTarget) + d20();

            if (nDC < 1) nDC = 1;
            
            if (!GetIsSkillSuccessful(oPC, SKILL_PICK_POCKET, nDC))
            {
                ConfrontThief(oTarget, oPC, oItem);
                break;
            }
        }
        //Get next target in area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation);
    }
}

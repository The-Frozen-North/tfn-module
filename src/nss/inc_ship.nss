#include "inc_gold"
#include "nwnx_object"

// Get the cost of the ship, modified by charisma.
// Requires ship#_cost, where # is the nTarget variable.
// To retrieve the variable, it's 4500+nTarget.
int GetShipCost(object oSpeaker, object oPlayer, int nTarget);

// Get the cost of the ship for a persuade check
// To retrieve the variable, it's 4600+nTarget.
int GetShipCostPersuade(object oSpeaker, object oPlayer, int nTarget);

// Pays the ship and travels.
// Requires ship#_cost, ship#_destination, where # is the nTarget variable.
//
void PayShipAndTravel(object oSpeaker, object oPlayer, int nTarget, int bPersuade = FALSE);

int GetShipCost(object oSpeaker, object oPlayer, int nTarget)
{
    int nCost = CharismaDiscountedGold(oPlayer, GetLocalInt(oSpeaker, "ship"+IntToString(nTarget)+"_cost"));
    SetCustomToken(4501, IntToString(nCost));

    return nCost;
}

int GetShipCostPersuade(object oSpeaker, object oPlayer, int nTarget)
{
    int nCost = CharismaModifiedPersuadeGold(oPlayer, GetShipCost(oSpeaker, oPlayer, nTarget));
    SetCustomToken(4502, IntToString(nCost));

    return nCost;
}

void PayShipAndTravel(object oSpeaker, object oPlayer, int nTarget, int bPersuade = FALSE)
{
    object oDestination = GetObjectByTag(GetLocalString(oSpeaker, "ship"+IntToString(nTarget)+"_wp"));

// let's not proceed further if the object wp is invalid
    if (!GetIsObjectValid(oDestination)) return;

    int nCost;
    if (bPersuade)
    {
        nCost = GetShipCostPersuade(oSpeaker, oPlayer, nTarget);
    }
    else
    {
        nCost = GetShipCost(oSpeaker, oPlayer, nTarget);
    }

// do not proceed if the player does not have enough gold
    if (GetGold(oPlayer) < nCost) return;

    object oArea = GetArea(oDestination);

    int nTravelTime = GetLocalInt(oArea, "travel_time");

// reset travel time to start to simulate new players boarding ship, or initialize it from the start
// don't do it under 20 otherwise new players may make the ship ride very, very long
    if (nTravelTime >= 20 || nTravelTime < 0) SetLocalInt(oArea, "travel_time", 24+d6());

    TakeGoldFromCreature(nCost, oPlayer, TRUE);
    AssignCommand(oPlayer, ActionJumpToLocation(GetLocation(oDestination)));
}

//void main() {}

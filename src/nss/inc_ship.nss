#include "inc_gold"
#include "inc_horse"
#include "nwnx_object"
#include "inc_general"

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

// Make nTries to jump OBJECT_SELF to lTarget. If it doesn't work the first time, tries again every second.
// DON'T USE if the lTarget is in the same area, use ReallyJumpToLocationInSameArea instead
void ReallyJumpToLocation(location lTarget, int nTries);
// As ReallyJumpToLocation, for use when OBJECT_SELf and lTarget were always in the same area.
void ReallyJumpToLocationInSameArea(location lTarget, float fDist=-1.0, int nTries=20);

void JumpAllAssociatesByType(int nAssociateType, location lLocation)
{
    int nCount = 1;
    object oAssociate = GetAssociate(nAssociateType, OBJECT_SELF, nCount);

    while (GetIsObjectValid(oAssociate))
    {
        JumpToLocation(lLocation);
        nCount++;
        oAssociate = GetAssociate(nAssociateType, OBJECT_SELF, nCount);
    }
}

void JumpAllAssociates(location lLocation)
{
    JumpAllAssociatesByType(ASSOCIATE_TYPE_ANIMALCOMPANION, lLocation);
    JumpAllAssociatesByType(ASSOCIATE_TYPE_DOMINATED, lLocation);
    JumpAllAssociatesByType(ASSOCIATE_TYPE_FAMILIAR, lLocation);
    JumpAllAssociatesByType(ASSOCIATE_TYPE_HENCHMAN, lLocation);
    JumpAllAssociatesByType(ASSOCIATE_TYPE_SUMMONED, lLocation);
}

void ReallyJumpToLocation(location lTarget, int nTries)
{
    object oTargetArea = GetAreaFromLocation(lTarget);
    object oMyArea = GetArea(OBJECT_SELF);
    if (!GetIsObjectValid(oMyArea))
    {
        return;
    }
    if (oMyArea == oTargetArea)
    {
        return;
    }

    // See if there's something alive near the target area to use compute safe location for
    object oNearby = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, lTarget);
    while (GetIsObjectValid(oNearby))
    {
        if (GetObjectType(oNearby) == OBJECT_TYPE_CREATURE && !GetIsDead(oNearby))
        {
            break;
        }
        oNearby = GetNextObjectInShape(SHAPE_SPHERE, 5.0, lTarget);
    }

    location lJumpTarget = lTarget;

    if (GetIsObjectValid(oNearby))
    {
        vector vSafe = NWNX_Creature_ComputeSafeLocation(oNearby, GetPosition(oNearby));
        lJumpTarget = Location(GetArea(oNearby), vSafe, 0.0);
    }

    nTries--;
    JumpToLocation(lJumpTarget);
    JumpAllAssociates(lJumpTarget);
    if (nTries > 0)
    {
        DelayCommand(1.0, ReallyJumpToLocation(lTarget, nTries));
    }
    else
    {
        WriteTimestampedLogEntry("ReallyJumpToLocation probably failed on " + GetName(OBJECT_SELF));
    }
}

void ReallyJumpToLocationInSameArea(location lTarget, float fDist=-1.0, int nTries=20)
{
    location lMe = GetLocation(OBJECT_SELF);
    if (fDist < 0.0)
    {
        fDist = GetDistanceBetweenLocations(lMe, lTarget);
    }
    // See if there's something alive near the target area to use compute safe location for
    object oNearby = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, lTarget);
    while (GetIsObjectValid(oNearby))
    {
        if (GetObjectType(oNearby) == OBJECT_TYPE_CREATURE && !GetIsDead(oNearby))
        {
            break;
        }
        oNearby = GetNextObjectInShape(SHAPE_SPHERE, 5.0, lTarget);
    }

    location lJumpTarget = lTarget;

    if (GetIsObjectValid(oNearby))
    {
        vector vSafe = NWNX_Creature_ComputeSafeLocation(oNearby, GetPosition(oNearby));
        lJumpTarget = Location(GetArea(oNearby), vSafe, 0.0);
    }


    float fThisDist = GetDistanceBetweenLocations(lMe, lTarget);
    if (fThisDist * 2.0 < fDist || fThisDist < 8.0)
    {
        return;
    }
    JumpToLocation(lJumpTarget);
    JumpAllAssociates(lJumpTarget);
    nTries--;
    if (nTries > 0)
    {
        DelayCommand(1.0, ReallyJumpToLocationInSameArea(lTarget));
    }
    else
    {
        WriteTimestampedLogEntry("ReallyJumpToLocationInSameArea probably failed on " + GetName(OBJECT_SELF));
    }
}

int GetShipCost(object oSpeaker, object oPlayer, int nTarget)
{
    int nCost = CharismaDiscountedGold(oPlayer, GetLocalInt(oSpeaker, "ship"+IntToString(nTarget)+"_cost"));
    SetCustomToken(CTOKEN_SHIP_COST, IntToString(nCost));

    return nCost;
}

int GetShipCostPersuade(object oSpeaker, object oPlayer, int nTarget)
{
    int nCost = CharismaModifiedPersuadeGold(oPlayer, GetShipCost(oSpeaker, oPlayer, nTarget));
    SetCustomToken(CTOKEN_SHIP_PERSUADE_COST, IntToString(nCost));

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

    IncrementStat(oPlayer, "gold_spent_on_long_travel", nCost);
    IncrementStat(oPlayer, "long_travel_used");

    object oArea = GetArea(oDestination);

    int nTravelTime = GetLocalInt(oArea, "travel_time");

// reset travel time to start to simulate new players boarding ship, or initialize it from the start
// don't do it under X otherwise new players may make the ship ride very, very long
    if (nTravelTime >= 15 || nTravelTime < 0) SetLocalInt(oArea, "travel_time", 20+d4());

    TakeGoldFromCreature(nCost, oPlayer, TRUE);

    RemoveMount(oPlayer);

    FadeToBlack(oPlayer);
    location lPlayer = GetLocation(oPlayer);
    location lTarget = GetLocation(oDestination);
    if (GetAreaFromLocation(lPlayer) == GetAreaFromLocation(lTarget))
    {
        DelayCommand(2.5, AssignCommand(oPlayer, ReallyJumpToLocationInSameArea(lTarget, 5.0, 20)));
    }
    else
    {
        DelayCommand(2.5, AssignCommand(oPlayer, ReallyJumpToLocation(lTarget, 20)));
    }

    DelayCommand(5.0, FadeFromBlack(oPlayer));
}

//void main() {}

#include "inc_ai_event"
#include "x0_i0_position"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_HEART_BEAT));

    if (GetHasFeat(FEAT_SUMMON_FAMILIAR) && !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_FAMILIAR)))
    {
        DecrementRemainingFeatUses(OBJECT_SELF, FEAT_SUMMON_FAMILIAR);
        SummonFamiliar();
    }

    if (GetHasFeat(FEAT_ANIMAL_COMPANION) && !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION)))
    {
        DecrementRemainingFeatUses(OBJECT_SELF, FEAT_ANIMAL_COMPANION);
        SummonAnimalCompanion();
    }

    int nCombatInt = GetLocalInt(OBJECT_SELF, "combat");

    if (nCombatInt > 0)
        SetLocalInt(OBJECT_SELF, "combat", nCombatInt+1);

    int nCombat = GetIsInCombat(OBJECT_SELF);

    if (GetLocalInt(OBJECT_SELF, "no_stealth") == 0 && GetSkillRank(SKILL_HIDE, OBJECT_SELF, TRUE) > 0 && (!nCombat || GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT)))
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);

// return to the original spawn point if it is too far
    location lSpawn = GetLocalLocation(OBJECT_SELF, "spawn");
    float fDistanceFromSpawn = GetDistanceBetweenLocations(GetLocation(OBJECT_SELF), lSpawn);
    float fMaxDistance = 5.0;

    if (GetLocalString(OBJECT_SELF, "merchant") != "") fMaxDistance = fMaxDistance * 0.5;

// enemies have a much farther distance before they need to reset
    if (GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, OBJECT_SELF) <= 10) fMaxDistance = fMaxDistance*10.0;

    if (GetLocalInt(OBJECT_SELF, "no_wander") == 1) fMaxDistance = 0.0;
// Not in combat? Different/Invalid area? Too far from spawn?
    if (GetLocalInt(OBJECT_SELF, "ambient") != 1 && !nCombat && ((fDistanceFromSpawn == -1.0) || (fDistanceFromSpawn > fMaxDistance)))
    {
        AssignCommand(OBJECT_SELF, ClearAllActions());
        MoveToNewLocation(lSpawn, OBJECT_SELF);
        return;
    }

    string sScript = GetLocalString(OBJECT_SELF, "heartbeat_script");
    if (sScript != "") ExecuteScript(sScript);
}



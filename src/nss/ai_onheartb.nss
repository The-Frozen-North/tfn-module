#include "inc_ai_event"
#include "x0_i0_position"
#include "inc_ai_combat"
#include "x0_i0_walkway"

void ClearPersonalReputationsWithAllPCs()
{
    object oPC = GetFirstPC();

    while (GetIsObjectValid(oPC))
    {
        ClearPersonalReputation(oPC, OBJECT_SELF);
        oPC = GetNextPC();
    }
}

void main()
{
    if (GetIsDead(OBJECT_SELF)) return;

    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_HEART_BEAT));

    if (GetLocalInt(OBJECT_SELF, "no_pet") == 0)
    {
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
    }

    int nCurrentAction = GetCurrentAction(OBJECT_SELF);
    int bBusy = nCurrentAction == ACTION_ATTACKOBJECT || nCurrentAction == ACTION_CASTSPELL;

    int nCombatInt = GetLocalInt(OBJECT_SELF, "combat");

    if (nCombatInt > 0)
        SetLocalInt(OBJECT_SELF, "combat", nCombatInt+1);

    int nSelected = GetLocalInt(OBJECT_SELF, "selected");
    int nSelectedRemove = GetLocalInt(OBJECT_SELF, "selected_remove");
    if (nSelectedRemove > 2)
    {
        DeleteLocalInt(OBJECT_SELF, "selected");
        DeleteLocalInt(OBJECT_SELF, "selected_remove");
    }
    else if (nSelected > 1)
    {
        SetLocalInt(OBJECT_SELF, "selected_remove", nSelectedRemove + 1);
    }

    int nCombat = GetIsInCombat(OBJECT_SELF);

    object oPC = GetFirstPC();

    int bEnemyPCSeen = FALSE;

    while (GetIsObjectValid(oPC))
    {
        if (GetIsEnemy(oPC) && (GetObjectSeen(oPC) || GetObjectHeard(oPC)))
        {
            bEnemyPCSeen = TRUE;
            break;
        }

        oPC = GetNextPC();
    }

    int nCountBeforeClearReputation = GetLocalInt(OBJECT_SELF, "count_before_clearing_pc_reputation");

    // clear reputation with all PCs if no enemy PCs have been seen for a while
    // don't check for combat, what could happen is that the creature is in combat with a non-PC
    // like a combat dummy and never clears reputation
    if (bEnemyPCSeen)
    {
        SetLocalInt(OBJECT_SELF, "count_before_clearing_pc_reputation", 5);
    }
    else if (nCountBeforeClearReputation <= 0)
    {
        DeleteLocalInt(OBJECT_SELF, "count_before_clearing_pc_reputation");
        ClearPersonalReputationsWithAllPCs();
    }
    else
    {
        SetLocalInt(OBJECT_SELF, "count_before_clearing_pc_reputation", nCountBeforeClearReputation - 1);
    } 

    // torch stuff
    object oArea = GetArea(OBJECT_SELF);
    object oTorch = GetItemPossessedBy(OBJECT_SELF, "NW_IT_TORCH001");

    if (GetIsObjectValid(oTorch))
    {
        // outside and night time? or underground?
        int bTorchUsable = (!GetIsAreaInterior(oArea) && GetIsNight()) || GetIsAreaAboveGround(oArea) == AREA_UNDERGROUND;
        int bTorchEquipped = GetTag(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, OBJECT_SELF)) == "NW_IT_TORCH001";

        if (!nCombat && bTorchUsable && !bBusy)
        {
            if (!bTorchEquipped) ActionEquipItem(oTorch, INVENTORY_SLOT_LEFTHAND);
        }
        else
        {
            if (bTorchEquipped)
            {
                ActionUnequipItem(oTorch);

                object oOffhand = GetLocalObject(OBJECT_SELF, "offhand");
                if (GetIsObjectValid(oOffhand))
                {
                    NWNX_Creature_RunEquip(OBJECT_SELF, oOffhand, INVENTORY_SLOT_LEFTHAND);
                }
            }

            if (GetLocalInt(OBJECT_SELF, "range") == 1)
            {
                EquipRange();
            }
            else
            {
                EquipMelee();
            }
        }
    }

    if (GetLocalInt(OBJECT_SELF, "no_stealth") == 0 && GetSkillRank(SKILL_HIDE, OBJECT_SELF, TRUE) > 0 && (!nCombat || GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT)))
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);

// if this creature is from an ambush, make it attack their visible target or move to their location
    if (GetLocalInt(OBJECT_SELF, "ambush") == 1)
    {
// only attack or move to the ambush location when not in combat, otherwise combat can be interrupted
        if (!nCombat)
        {
            object oTarget = GetLocalObject(OBJECT_SELF, "ambush_target");

// attack ambush target if seen or target is alive
            if (!GetIsDead(oTarget) && (GetObjectSeen(oTarget) || GetObjectHeard(oTarget)))
            {
                gsCBDetermineCombatRound(oTarget);
            }
            else
            {
                ActionMoveToLocation(GetLocalLocation(OBJECT_SELF, "ambush_location"), TRUE);
            }
        }

    }
    else if (GetLocalInt(OBJECT_SELF, "patrol") == 1)
    {
        WalkWayPoints();
    }
    else
    {
// return to the original spawn point if it is too far
        location lSpawn = GetLocalLocation(OBJECT_SELF, "spawn");
        object oSpawnArea = GetAreaFromLocation(lSpawn);
        
// if not in the same area, force the NPC to jump back to the spawn location after a while
        if (GetIsObjectValid(oSpawnArea) && oSpawnArea != GetArea(OBJECT_SELF))
        {
            int nNotInSameAreaCount = GetLocalInt(OBJECT_SELF, "not_in_same_area_count");
            if (!nCombat && nNotInSameAreaCount >= 25)
            {
                ClearAllActions();
                ActionJumpToLocation(lSpawn);
                DeleteLocalInt(OBJECT_SELF, "not_in_same_area_count");
            }
            else
            {
                SetLocalInt(OBJECT_SELF, "not_in_same_area_count", nNotInSameAreaCount + 1);
            }
        }
        else
        {
            DeleteLocalInt(OBJECT_SELF, "not_in_same_area_count");
            
            float fDistanceFromSpawn = GetDistanceBetweenLocations(GetLocation(OBJECT_SELF), lSpawn);
            float fMaxDistance = 5.0;

            if (GetLocalString(OBJECT_SELF, "merchant") != "") fMaxDistance = fMaxDistance * 0.5;

    // enemies and herbivores have a much farther distance before they need to reset
            if ((GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, OBJECT_SELF) <= 10) || GetLocalInt(OBJECT_SELF, "herbivore") == 1) fMaxDistance = fMaxDistance*10.0;

            if (GetLocalInt(OBJECT_SELF, "no_wander") == 1) fMaxDistance = 0.0;
    // Not in combat? Different/Invalid area? Too far from spawn?
            if (GetLocalInt(OBJECT_SELF, "ambient") != 1 && !nCombat && !bBusy && ((fDistanceFromSpawn == -1.0) || (fDistanceFromSpawn > fMaxDistance)))
            {
                ClearAllActions();
                MoveToNewLocation(lSpawn, OBJECT_SELF);
                return;
            }
        }
    }

    string sAreaScript = GetLocalString(oArea, "creature_heartbeat_script");
    if (sAreaScript != "") ExecuteScript(sAreaScript);

    string sScript = GetLocalString(OBJECT_SELF, "heartbeat_script");
    if (sScript != "") ExecuteScript(sScript);
}



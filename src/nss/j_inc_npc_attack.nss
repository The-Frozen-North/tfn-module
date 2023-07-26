/************************ [Combat Attack] **************************************
    Filename: j_inc_npc_attack
************************* [Combat Attack] **************************************
    What does this do?

    It is a wrapper/include for getting a creature to attack target X, or do
    Y. I use this for conversations, triggers, the lot, as a simple wrapper
    that will execute my AI.

    There are several functions here to do things, that may be useful wrappers.

    And it also keeps Combat files SMALL! I uses Execute Script to fire the
    combat file, not include it here.
************************* [History] ********************************************
    1.3 - Added
************************* [Workings] *******************************************
    Include this in any conversation file or whatever, and mearly read the
    descriptions of the different functions, and it will do what it says :-)
************************* [Arguments] ******************************************
    Arguments:
************************* [Combat Attack] *************************************/

// Include the constants for the combat, spawn integers ETC.
#include "j_inc_constants"

// Hostile amount
const int HOSTILE                       = -100;// Reputation to change to
const int TYPE_ALL_PCS  = 1;// is all PC's in the world.
const int TYPE_ALL_AREA = 2;// is all PC's in the specific area.
const int TYPE_IN_RANGE = 3;// is all PC's within fRange.

// A slightly modified way to determine a combat round.
// * oTarget - The target to attack
// * sShout - The string to silently speak to get allies to come and help
void DetermineSpeakCombatRound(object oTarget = OBJECT_INVALID, string sShout = "");

// A slightly modified way to determine a combat round.
// * oTarget - The target to attack
// * oAttacker - The NPC who you want to determine a combat round, on oTarget
void DetermineSpeakCombatRoundNotMe(object oTarget, object oAttacker);

// This is the main wrapper to get an NPC to attack in conversation.
// * fDelay - The delay AFTER adjusting reputation, that we attack and shout
// * iPlot - The plot flag to set to (Usually FALSE).
// * iImmortal - The immortal flag to set to (Usually FALSE).
// Example, how to keep flags already set:
//      HostileAttackPCSpeaker(0.0, GetPlotFlag(), GetImmortal());
// * iAllAllies - This will determine combat rounds against the target, that are in 50.0M. False = Don't
void HostileAttackPCSpeaker(float fDelay = 0.0, int iPlot = FALSE, int iImmortal = FALSE, int iAllAllies = TRUE);

// This will make our faction hostile to the target, and attack them.
// * oTarget - The target object to attack
// * fDelay - The delay AFTER adjusting reputation, that we attack and shout
// * iPlot - The plot flag to set to (Usually FALSE).
// * iImmortal - The immortal flag to set to (Usually FALSE).
// Example, how to keep flags already set:
//      HostileAttackObject(oPC, 0.0, GetPlotFlag(), GetImmortal());
// * iAllAllies - This will determine combat rounds against the target, that are in 50.0M. False = Don't
void HostileAttackObject(object oTarget, float fDelay = 0.0, int iPlot = FALSE, int iImmortal = FALSE, int iAllAllies = TRUE);

// This will make our faction hostile to the target, and shout.
// * oTarget - The target object to shout about.
// Use: Placeables, disturbers and so on.
// Note: Placeables are normally defaulted hostile faction! Must change it to work
void ShoutAbout(object oTarget);

// This will make our faction hostile to ALL(!) PC's...in the area or game or range
// * iType - TYPE_ALL_PCS (1) is all PC's in the world.
//         - TYPE_ALL_AREA (2) is all PC's in the specific area.
//         - TYPE_IN_RANGE (3) is all PC's within fRange.
// * iPlot - The plot flag to set to (Usually FALSE).
// * iImmortal - The immortal flag to set to (Usually FALSE).
// * iAllAllies - This will determine combat rounds against the target, that are in 50.0M. False = Don't
void HostileAttackAllPCs(int iType = 1, float fRange = 40.0, int iPlot = FALSE, int iImmortal = FALSE, int iAllAllies = TRUE);

// This will thier most damaging weapon, and wait to disarm it.
// * fDuration - Delay until the weapon is withdrawn.
// * iRanged - if TRUE, it will equip a ranged weapon as a prioritory (EquipRanged call)
void EquipWeaponsDuration(float fDuration, int iRanged = FALSE);
// Disarms the persons right-hand-weapon
void RemoveWeapons();

// Plays talks like "ATTACK!" and "Group Near Me" etc.
// * iLowest, iHighest - the High/Lowest value to use.
// 0 = ATTACK, 1 = TAUNT, 2-4 = BATTLE(1-3), 5 = ENEMIES, 6 = GROUP, 7 = HELP.
void PlaySomeTaunt(int iLowest = 0, int iHighest = 7);

// Gets all allies of ourselves to attack oTarget
// * oTarget - The target to attack.
void AlliesAttack(object oTarget);

// Returns the nearest PC object
object GetNearestPCCreature();
// Returns the nearest enemy (but doesn't determine if it can see/hear it)
object GetNearestEnemyCreature();
// Returns the nearest friend
object GetNearestFriendCreature();


// A slightly modified way to determine a combat round.
// * oTarget - The target to attack
// * sShout - The string to silently speak to get allies to come and help
void DetermineSpeakCombatRound(object oTarget, string sShout)
{
    // Shout
    if(sShout != "") AISpeakString(sShout);

    // Check for custom AI script, else fire default.
    string sAI = GetCustomAIFileName();
    // Fire default AI script
    if(sAI == "")
    {
        // Sanity check - to not fire this off multiple times, we make sure temp
        //      object is not the same as oTarget (and valid)
        if(!GetIsObjectValid(oTarget) || (GetIsObjectValid(oTarget) &&
           !GetLocalTimer(AI_DEFAULT_AI_COOLDOWN)))
        {
            SetLocalObject(OBJECT_SELF, AI_TEMP_SET_TARGET, oTarget);
            ExecuteScript(COMBAT_FILE, OBJECT_SELF);
            SetLocalTimer(AI_DEFAULT_AI_COOLDOWN, 0.1);
        }
    }
    // Fire custom AI script
    else
    {
        SetLocalObject(OBJECT_SELF, AI_TEMP_SET_TARGET, oTarget);
        ExecuteScript(sAI, OBJECT_SELF);
    }
}

// A slightly modified way to determine a combat round.
// * oTarget - The target to attack
// * oAttacker - The NPC who you want to determine a combat round, on oTarget
void DetermineSpeakCombatRoundNotMe(object oTarget, object oAttacker)
{
    // Check for custom AI script, else fire default.
    string sAI = GetLocalString(oAttacker, AI_CUSTOM_AI_SCRIPT);
    // Fire default AI script
    if(sAI == "")
    {
        // Sanity check - to not fire this off multiple times, we make sure temp
        //      object is not the same as oTarget (and valid)
        if(!GetIsObjectValid(oTarget) || (GetIsObjectValid(oTarget) &&
           !GetLocalTimer(AI_DEFAULT_AI_COOLDOWN)))
        {
            SetLocalObject(oAttacker, AI_TEMP_SET_TARGET, oTarget);
            ExecuteScript(COMBAT_FILE, oAttacker);
            SetLocalTimer(AI_DEFAULT_AI_COOLDOWN, 0.1);
        }
    }
    // Fire custom AI script
    else
    {
        SetLocalObject(oAttacker, AI_TEMP_SET_TARGET, oTarget);
        ExecuteScript(sAI, oAttacker);
    }
}
// This is the main wrapper to get an NPC to attack in conversation.
// * iPlot - The plot flag to set to (Usually FALSE).
// * iImmortal - The immortal flag to set to (Usually FALSE).
// Example, how to keep flags already set:
//      AttackPCSpeaker(GetPlotFlag(), GetImmortal());
// * iAllAllies - This will determine combat rounds against the target, that are in 50.0M. False = Don't
void HostileAttackPCSpeaker(float fDelay = 0.0, int iPlot = FALSE, int iImmortal = FALSE, int iAllAllies = TRUE)
{
    // Get the PC
    object oPC = GetPCSpeaker();
    // Error checking
    if(!GetIsObjectValid(oPC) || GetIsDM(oPC)) return;
    // Change the flags
    if(GetPlotFlag() != iPlot)
        SetPlotFlag(OBJECT_SELF, iPlot);
    if(GetImmortal() != iImmortal)
        SetImmortal(OBJECT_SELF, iPlot);

    // We make them hostile to our faction
    AdjustReputation(oPC, OBJECT_SELF, HOSTILE);
    // Attack them
    SetLocalObject(OBJECT_SELF, AI_TO_ATTACK, oPC);
    if(fDelay > 0.0)
    {
        // Round start...
        DelayCommand(fDelay, DetermineSpeakCombatRound(oPC, I_WAS_ATTACKED));
        if(iAllAllies)
            DelayCommand(fDelay, AlliesAttack(oPC));
    }
    else
    {
        // Round start...
        DetermineSpeakCombatRound(oPC, I_WAS_ATTACKED);
        if(iAllAllies) AlliesAttack(oPC);
    }
}

// This will make our faction hostile to the target, and attack them.
// * oTarget - The target object to attack
// * iPlot - The plot flag to set to (Usually FALSE).
// * iImmortal - The immortal flag to set to (Usually FALSE).
// Example, how to keep flags already set:
//      AttackObject(oPC, GetPlotFlag(), GetImmortal());
// * iAllAllies - This will determine combat rounds against the target, that are in 50.0M. False = Don't
void HostileAttackObject(object oTarget, float fDelay = 0.0, int iPlot = FALSE, int iImmortal = FALSE, int iAllAllies = TRUE)
{
    // Error checking
    if(!GetIsObjectValid(oTarget) || GetIsDM(oTarget)) return;
    // Change the flags
    if(GetPlotFlag() != iPlot)
        SetPlotFlag(OBJECT_SELF, iPlot);
    if(GetImmortal() != iImmortal)
        SetImmortal(OBJECT_SELF, iPlot);

    // We make them hostile to our faction
    AdjustReputation(oTarget, OBJECT_SELF, HOSTILE);
    // Attack them
    SetLocalObject(OBJECT_SELF, AI_TO_ATTACK, oTarget);
    if(fDelay > 0.0)
    {
        // Round start...
        DelayCommand(fDelay, DetermineSpeakCombatRound(oTarget, I_WAS_ATTACKED));
    }
    else
    {
        // Round start...
        DetermineSpeakCombatRound(oTarget, I_WAS_ATTACKED);
    }
}

// This will make our faction hostile to the target, and shout.
// * oTarget - The target object to shout about.
// Use: Placeables, disturbers and so on.
void ShoutAbout(object oTarget)
{
    // We make them hostile to our faction
    AdjustReputation(oTarget, OBJECT_SELF, HOSTILE);
    // And shout for others to attack
    AISpeakString(CALL_TO_ARMS);
}

// This will make our faction hostile to ALL(!) PC's...in the area or game or range
// * iType - TYPE_ALL_PCS (1) is all PC's in the world.
//         - TYPE_ALL_AREA (2) is all PC's in the specific area.
//         - TYPE_IN_RANGE (3) is all PC's within fRange.
// * iPlot - The plot flag to set to (Usually FALSE).
// * iImmortal - The immortal flag to set to (Usually FALSE).
// * iAllAllies - This will determine combat rounds against the target, that are in 50.0M. False = Don't
void HostileAttackAllPCs(int iType = 1, float fRange = 40.0, int iPlot = FALSE, int iImmortal = FALSE, int iAllAllies = TRUE)
{
    object oPC, oToAttack;
    int iShout, iCnt;
    float fNearestEnemy = 10000.0;
    object oArea = GetArea(OBJECT_SELF);
    switch(iType)
    {
        case TYPE_ALL_PCS:// s all PC's in the world.
        {
            oPC = GetFirstPC();
            while(GetIsObjectValid(oPC))
            {
                if(!GetIsDM(oPC) &&
                    GetIsObjectValid(GetArea(oPC)))
                {
                    AdjustReputation(oPC, OBJECT_SELF, HOSTILE);
                    if(GetArea(oPC) == oArea)
                    {
                        if(GetDistanceToObject(oPC) <= fNearestEnemy)
                        {
                            oToAttack = oPC;
                        }
                    }
                    iShout = TRUE;
                }
                oPC = GetNextPC();
            }
        }
        break;
        case TYPE_ALL_AREA:// is all PC's in the specific area.
        {
            iCnt = 1;
            oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
            while(GetIsObjectValid(oPC))
            {
                // Attack it! (if not a DM!)
                if(!GetIsDM(oPC))
                {
                    AdjustReputation(oPC, OBJECT_SELF, HOSTILE);
                    if(GetArea(oPC) == oArea)
                    {
                        if(GetDistanceToObject(oPC) <= fNearestEnemy)
                        {
                            oToAttack = oPC;
                        }
                    }
                    iShout = TRUE;
                }
                // Next one
                iCnt++;
                oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC,
                                         OBJECT_SELF, iCnt);
            }
        }
        break;
        case TYPE_IN_RANGE:// is all PC's within fRange.
        {
            iCnt = 1;
            oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
            while(GetIsObjectValid(oPC) && GetDistanceToObject(oPC) <= fRange)
            {
                // Attack it! (if not a DM!)
                if(!GetIsDM(oPC))
                {
                    AdjustReputation(oPC, OBJECT_SELF, HOSTILE);
                    if(GetArea(oPC) == oArea)
                    {
                        if(GetDistanceToObject(oPC) <= fNearestEnemy)
                        {
                            oToAttack = oPC;
                        }
                    }
                    iShout = TRUE;
                }
                // Next one
                iCnt++;
                oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC,
                                         OBJECT_SELF, iCnt);
            }
        }
        break;
    }
    // Attack nearest one (if valid)
    if(GetIsObjectValid(oToAttack))
    {
        DetermineSpeakCombatRound(oToAttack);
        if(iAllAllies) AlliesAttack(oToAttack);
    }
    // Check if we shout
    if(iShout) AISpeakString(CALL_TO_ARMS);
}
// This will thier most damaging melee weapon, and wait to disarm it.
// * fDuration - Delay until the weapon is withdrawn.
void EquipWeaponsDuration(float fDuration, int iRanged = FALSE)
{
    if(iRanged)
    {
        // Equip any most damaging (don't use oVersus, incase it doesn't arm anything)
        ActionEquipMostDamagingRanged();
    }
    else
    {
        // Equip any most damaging (don't use oVersus, incase it doesn't arm anything)
        ActionEquipMostDamagingMelee();
    }
    // Delay the un-equip
    DelayCommand(fDuration, RemoveWeapons());
}
// Disarms the persons right-hand-weapon
void RemoveWeapons()
{
    // cannot be in combat, duh!
    if(GetIsInCombat() || GetIsObjectValid(GetAttackTarget()))
        return;
    // Get the weapon, make sure it is valid, and...
    object oUnequip = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    if(GetIsObjectValid(oUnequip))
    {
        // ...unequip it.
        ClearAllActions();
        ActionUnequipItem(oUnequip);
    }
}
/*::///////////////////////////////////////////////
//:: PlaySomeTaunt
//::///////////////////////////////////////////////
 Plays talks like "ATTACK!" and "Group Near Me" etc.
 * iLowest, iHighest - the High/Lowest value to use.
 0 = ATTACK, 1 = TAUNT, 2-4 = BATTLE(1-3), 5 = ENEMIES, 6 = GROUP, 7 = HELP.
//::///////////////////////////////////////////////
//:: Created by : Jasperre
//:://///////////////////////////////////////////*/
void PlaySomeTaunt(int iLowest, int iHighest)
{
    int iRandom = Random(iHighest) + iLowest;
    int iVoice = VOICE_CHAT_ATTACK;
    switch (iRandom)
    {
        case 0: iVoice = VOICE_CHAT_ATTACK; break;
        case 1: iVoice = VOICE_CHAT_TAUNT; break;
        case 2: iVoice = VOICE_CHAT_BATTLECRY1; break;
        case 3: iVoice = VOICE_CHAT_BATTLECRY2; break;
        case 4: iVoice = VOICE_CHAT_BATTLECRY3; break;
        case 5: iVoice = VOICE_CHAT_ENEMIES; break;
        case 6: iVoice = VOICE_CHAT_GROUP; break;
        case 7: iVoice = VOICE_CHAT_HELP; break;
        default: iVoice = VOICE_CHAT_ATTACK; break;
    }
    PlayVoiceChat(iVoice);
}

// Gets all allies of ourselves to attack oTarget
// * oTarget - The target to attack.
void AlliesAttack(object oTarget)
{
    if(!GetIsObjectValid(oTarget)) return;
    int iCnt = 1;
    object oAlly = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, iCnt, CREATURE_TYPE_IS_ALIVE, TRUE);
    while(GetIsObjectValid(oAlly) && GetDistanceToObject(oAlly) <= 50.0)
    {
        // A slightly modified way to determine a combat round.
        // * oTarget - The target to attack
        // * oAttacker - The NPC who you want to determine a combat round, on oTarget
        DetermineSpeakCombatRoundNotMe(oTarget, oAlly);
        iCnt++;
        oAlly = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, iCnt, CREATURE_TYPE_IS_ALIVE, TRUE);
    }
}

// Returns the nearest PC object
object GetNearestPCCreature()
{
    return GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
}
// Returns the nearest enemy (but doesn't determine if it can see/hear it)
object GetNearestEnemyCreature()
{
    return GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
}
// Returns the nearest friend
object GetNearestFriendCreature()
{
    return GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND);
}

//void main(){}

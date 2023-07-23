/*/////////////////////// [Include - Spawn In] /////////////////////////////////
    Filename: J_Inc_SpawnIn
///////////////////////// [Include - Spawn In] /////////////////////////////////
    This contains all the functions used in the spawning process, in one easy
    and very long file.

    It also importantly sets up spells we have, or at least talents, so we
    know if we have any spells from category X.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Changed, added a lot of new things (such as constants file)
    1.4 - No more setting talent categories On Spawn. This is too much hassel.
          See the On rest script for ideas (remove this when complete!).

          Perhaps set "Items" the first time we enter combat, and reset each time
          combat stops. Can be more efficeint maybe.
        - Skills set to "use" should have, say, 3 or more skill points to be
          used automatically, especially true for hiding.
///////////////////////// [Workings] ///////////////////////////////////////////
    This doesn't call anything to run the rest, except AI_SetUpEndOfSpawn has
    a lot of things that the generic AI requires (SetListeningPatterns and skills
    and waypoints ETC)

    See the spawn in script for all the actual uses.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A see spawn in script
///////////////////////// [Include - Spawn In] ///////////////////////////////*/

// All constants.
#include "J_INC_SETWEAPONS"
// Set weapons
// - Constants file is in this

// Special: Bioware SoU Waypoints/Animations constants
// - Here so I know where they are :-P
const string sAnimCondVarname = "NW_ANIM_CONDITION";
// If set, the NPC is civilized
const int NW_ANIM_FLAG_IS_CIVILIZED            = 0x00000400;
// If set, the NPC will use voicechats
const int NW_ANIM_FLAG_CHATTER                 = 0x00000004;
// If set, the NPC is mobile in a close-range
const int NW_ANIM_FLAG_IS_MOBILE_CLOSE_RANGE   = 0x00000200;

/******************************************************************************/
// Functions:
/******************************************************************************/
// This will activate one aura, very quickly.
// If we have more than one...oh well.
void AI_AdvancedAuras();
// Activate the aura number (IE: Spell number), if it is possible.
void AI_ActivateAura(int nAuraNumber);

// Base for moving round thier waypoints
// - Uses ExectuteScript to run the waypoint walking.
// * If bRun is TRUE, we run all the waypoint.
// * fPause is the time delay between walking to the next waypoint (default 1.0)
void SpawnWalkWayPoints(int bRun = FALSE, float fPause = 1.0);

// Sets up what we will listen to (everything!)
void AI_SetListeningPatterns();
// This will set what creature to create OnDeath.
void AI_SetDeathResRef(string sResRef);
// This will set the string, sNameOfValue, to sValue. Array size of 1.
// - Use nPercentToSay to determine what % out of 100 it is said.
void AI_SetSpawnInSpeakValue(string sNameOfValue, string sValue, int nPercentToSay = 100);
// This will choose a random string, using iAmountOfValues, which is
// the amount of non-empty strings given. The size of the array is therefore 1.
// - Use nPercentToSay to determine what % out of 100 it is said.
void AI_SetSpawnInSpeakRandomValue(string sNameOfValue, int nPercentToSay, int nAmountOfValues, string sValue1, string sValue2, string sValue3 = "", string sValue4 = "", string sValue5 = "", string sValue6 = "", string sValue7 = "", string sValue8 = "", string sValue9 = "", string sValue10 = "", string sValue11 = "", string sValue12 = "");
// This will set an array of values, to sNameOfValue, for one to be chosen to
// be said at the right time :-)
// - sNameOfValue must be a valid name.
// - Use iPercentToSay to determine what % out of 100 it is said.
// NOTE: If the sNameOfValue is any combat one, we make that 1/100 to 1/1000.
void AI_SetSpawnInSpeakArray(string sNameOfValue, int nPercentToSay, int nSize, string sValue1, string sValue2, string sValue3 = "", string sValue4 = "", string sValue5 = "", string sValue6 = "", string sValue7 = "", string sValue8 = "", string sValue9 = "", string sValue10 = "", string sValue11 = "", string sValue12 = "");

// This applies an increase, decrease or no change to the intended stat.
// * Applies the effects INSTANTLY. These CANNOT be removed easily!
void AI_ApplyStatChange(int nStat, int nAmount);
// This will alter (magically) an ammount of random stats - nAmount
// by a value within iLowest and nHighest.
// * Applies the effects INSTANTLY. These CANNOT be removed easily!
void AI_CreateRandomStats(int nLowest, int nHighest, int nAmount);
// This will randomise other stats. Put both numbers to 0 to ignore some.
// nHPMin, nHPMax                   = HP changes.
// nReflexSaveMin, nReflexSaveMax   = Reflex Save changes
// nWillSaveMin, nWillSaveMax       = Will Save changes
// nFortSaveMin, nFortSaveMax       = Fortitude Save changes
// nACMin, nACMax                   = AC change.
//      Use nACType to define the AC type - default AC_DODGE_BONUS
// * Applies the effects INSTANTLY. These CANNOT be removed easily!
void AI_CreateRandomOther(int nHPMin, int nHPMax, int nReflexSaveMin = 0, int nReflexSaveMax = 0, int nWillSaveMin = 0, int nWillSaveMax = 0, int nFortSaveMin = 0, int nFortSaveMax = 0, int nACMin = 0, int nACMax = 0, int nACType = AC_DODGE_BONUS);

// Sets up thier selection of skills, to integers, if they would ever use them.
// NOTE: it also triggers "hide" if they have enough skill and not stopped.
// * 1.4 Changes: Some skills are turned off automatically when they have very
//   low points in that skill (IE: No possibility of doing it sucessfully). Also
//   edited other parts of the AI to take this into account.
void AI_SetUpSkillToUse();
// Sets the turning level if we have FEAT_TURN_UNDEAD.
// - Called from AI_SetUpEndOfSpawn.
void AI_SetTurningLevel();
// This MUST be called. It fires these events:
// SetUpSpells, SetUpSkillToUse, SetListeningPatterns, SetWeapons, AdvancedAuras.
// These MUST be called! the AI might fail to work correctly if they don't fire!
void AI_SetUpEndOfSpawn();
// This will make the visual effect passed play INSTANTLY at the creatures location.
// * nVFX - The visual effect constant number
void AI_SpawnInInstantVisual(int nVFX);
// This will make the visual effect passed play PERMAMENTLY.
// * nVFX - The visual effect constant number
// NOTE: They will be made to be SUPERNATUAL, so are not dispelled!
void AI_SpawnInPermamentVisual(int nVFX);
// This should not be used!
// * called from SetUpEndOfSpawn.
void AI_SetMaybeFearless();
// This will set the MAXIMUM and MINIMUM targets to pass this stage (under sName)
// of the targeting system. IE:
// - If we set it to min of 5, max of 10, for AC, if we cancled 5 targets on having
//   AC higher then wanted, we will take the highest 5 minimum.
//   If there are over 10, we take a max of 10 to choose from.
// * nType - must be TARGET_HIGHER or TARGET_LOWER. Defaults to the lowest, so it
//           targets the lowest value for sName.
void AI_SetAITargetingValues(string sName, int nType, int nMinimum, int nMaximum);


// Levels up us.
// * nLevel - Levels to this number (doesn't do anything if already GetHitDice >= nLevel).
// * nClass, nClass2, nClass3 - the 3 classes to level up in. Only needs 1 minimum
// Spreads equally if there is more then 1 nClass.
// Sets up spells to use automatically, but DOES NOT CHANGE CHALLENGE RATING!
void AI_LevelUpCreature(int nLevel, int nClass, int nClass2 = CLASS_TYPE_INVALID,  int nClass3 = CLASS_TYPE_INVALID);

// Used in AI_LevelUpCreature.
// - Levels up OBJECT_SELF, in nClass for nLevels
void AI_LevelLoop(int nClass, int nLevels);

// Sets up what random spells to cheat-cast at the end of all known spells.
// it does NOT check for immunities, barriers, or anything else.
// - You can set spells to more then one of the imputs to have a higher % to cast that one.
void SetAICheatCastSpells(int nSpell1, int nSpell2, int nSpell3, int nSpell4, int nSpell5, int nSpell6);

// Mark that the given creature has the given condition set for anitmations
// * Bioware SoU animations thing.
void SetAnimationCondition(int nCondition, int bValid = TRUE, object oCreature = OBJECT_SELF);

// Sets we are a Beholder and use Ray attacks, and Animagic Ray.
void SetBeholderAI();
// Set we are a mindflayer, and uses some special AI for them.
void SetMindflayerAI();

// This will set a spell trigger up. Under cirtain conditions, spells are released
// and cast on the caster.
// Once fired, a spell trigger is only reset by resting. Only 1 of each max is fired at once!
// * sType - is specifically:
//   SPELLTRIGGER_DAMAGED_AT_PERCENT  - When damaged, the trigger fires. Use iValue for the %. One at a time is fired.
//   SPELLTRIGGER_IMMOBILE            - Fired when held/paralyzed/sleeping ETC. One at a time is fired.
//   SPELLTRIGGER_NOT_GOT_FIRST_SPELL - Makes sure !GetHasSpellEffect(iSpell1) already,
//                                  then fires. Checks all in this category each round (first one fires!)
//   SPELLTRIGGER_START_OF_COMBAT     - Triggered always, at the start of DetermineCombatRound.
// * nNumber - can be 1-9, in sequential order of when you want them to fire.
// * nValue - is only required with DAMAGED_AT_PERCENT.
// * nSpellX - Cannot be 0. It should only really be defensive spells.
void SetSpellTrigger(string sType, int nValue, int nNumber, int nSpell1, int nSpell2 = 0, int nSpell3 = 0, int nSpell4 = 0, int nSpell5 = 0, int nSpell6 = 0, int nSpell7 = 0, int nSpell8 = 0, int nSpell9 = 0);

// Mark that the given creature has the given condition set
void SetAnimationCondition(int nCondition, int bValid = TRUE, object oCreature = OBJECT_SELF)
{
    int nCurrentCond = GetLocalInt(oCreature, sAnimCondVarname);
    if (bValid) {
        SetLocalInt(oCreature, sAnimCondVarname, nCurrentCond | nCondition);
    } else {
        SetLocalInt(oCreature, sAnimCondVarname, nCurrentCond & ~nCondition);
    }
}

// Sets up what random spells to cheat-cast at the end of all known spells.
// it does NOT check for immunities, barriers, or anything else.
// - You can set spells to more then one of the imputs to have a higher % to cast that one.
void SetAICheatCastSpells(int nSpell1, int nSpell2, int nSpell3, int nSpell4, int nSpell5, int nSpell6)
{
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(1), nSpell1);
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(2), nSpell2);
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(3), nSpell3);
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(4), nSpell4);
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(5), nSpell5);
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(6), nSpell6);
}


// Levels up us.
// * nLevel - Levels to this number (doesn't do anything if already GetHitDice >= nLevel).
// * nClass, nClass2, nClass3 - the 3 classes to level up in. Only needs 1 minimum
// - Spreads equally if there is more then 1 nClass.
// - Sets up spells to use automatically, but DOES NOT CHANGE CHALLENGE RATING!
// - Does NOT check for validness, or report any information.
void AI_LevelUpCreature(int nLevel, int nClass, int nClass2 = CLASS_TYPE_INVALID,  int nClass3 = CLASS_TYPE_INVALID)
{
    // Divide by 1, 2 or 3 (100%, 50%, 33%)
    int nDivideBy = (nClass >= 0) + (nClass2 >= 0) + (nClass3 >= 0);

    int nTotalPerClass = nLevel / nDivideBy;

    // Limit and loop - Class 1.
    AI_LevelLoop(nClass, nTotalPerClass);
    // 2
    AI_LevelLoop(nClass2, nTotalPerClass);
    // 3
    AI_LevelLoop(nClass3, nTotalPerClass);
}

// Used in AI_LevelUpCreature.
// - Levels up OBJECT_SELF, in iClass for nLevels
void AI_LevelLoop(int nClass, int nLevels)
{
    // Limit and loop
    while(nLevels > FALSE)
    {
        LevelUpHenchman(OBJECT_SELF, nClass, TRUE);
        nLevels--;
    }
}


// This will set what creature to create OnDeath.
void AI_SetDeathResRef(string sResRef)
{
    SetLocalString(OBJECT_SELF, AI_WE_WILL_CREATE_ON_DEATH, sResRef);
}
// This will set the string, sNameOfValue, to sValue. Array size of 1.
// - Use iPercentToSay to determine what % out of 100 it is said.
void AI_SetSpawnInSpeakValue(string sNameOfValue, string sValue, int iPercentToSay)
{
    SetLocalString(OBJECT_SELF, sNameOfValue + "1", sValue);
    // The array is 1 big!
    SetLocalInt(OBJECT_SELF, ARRAY_SIZE + sNameOfValue, 1);
    SetLocalInt(OBJECT_SELF, ARRAY_PERCENT + sNameOfValue, iPercentToSay);
}
// This will choose a random string, using iAmountOfValues, which is
// the amount of non-empty strings given. The size of the array is therefore 1.
// - Use iPercentToSay to determine what % out of 100 it is said.
void AI_SetSpawnInSpeakRandomValue(string sNameOfValue, int nPercentToSay, int nAmountOfValues, string sValue1, string sValue2, string sValue3, string sValue4, string sValue5, string sValue6, string sValue7, string sValue8, string sValue9, string sValue10, string sValue11, string sValue12)
{
    // Need a value amount of values!
    if(nAmountOfValues)
    {
        int nRandomNum = Random(nAmountOfValues) - 1; // take one, as it is 0 - X, not 1 - X
        string sValueToUse;
        switch(nRandomNum)
        {
            case 0:{sValueToUse = sValue1;}break;
            case 1:{sValueToUse = sValue2;}break;
            case 2:{sValueToUse = sValue3;}break;
            case 3:{sValueToUse = sValue4;}break;
            case 4:{sValueToUse = sValue5;}break;
            case 5:{sValueToUse = sValue6;}break;
            case 6:{sValueToUse = sValue7;}break;
            case 7:{sValueToUse = sValue8;}break;
            case 8:{sValueToUse = sValue9;}break;
            case 9:{sValueToUse = sValue10;}break;
            case 10:{sValueToUse = sValue11;}break;
            case 11:{sValueToUse = sValue12;}break;
        }
        SetLocalString(OBJECT_SELF, sNameOfValue + "1", sValueToUse);
        // The array is 1 big!
        SetLocalInt(OBJECT_SELF, ARRAY_SIZE + sNameOfValue, 1);
        SetLocalInt(OBJECT_SELF, ARRAY_PERCENT + sNameOfValue, nPercentToSay);
    }
}
void AI_SetSpawnInSpeakArray(string sNameOfValue, int nPercentToSay, int nSize, string sValue1, string sValue2, string sValue3 = "", string sValue4 = "", string sValue5 = "", string sValue6 = "", string sValue7 = "", string sValue8 = "", string sValue9 = "", string sValue10 = "", string sValue11 = "", string sValue12 = "")
{
    if(nSize >= 1)
    {
        SetLocalString(OBJECT_SELF, sNameOfValue + "1", sValue1);
        if(nSize >= 2)
        {
            SetLocalString(OBJECT_SELF, sNameOfValue + "2", sValue2);
            if(nSize >= 3)
            {
                SetLocalString(OBJECT_SELF, sNameOfValue + "3", sValue3);
                if(nSize >= 4)
                {
                    SetLocalString(OBJECT_SELF, sNameOfValue + "4", sValue4);
                    if(nSize >= 5)
                    {
                        SetLocalString(OBJECT_SELF, sNameOfValue + "5", sValue5);
                        if(nSize >= 6)
                        {
                            SetLocalString(OBJECT_SELF, sNameOfValue + "6", sValue6);
                            if(nSize >= 7)
                            {
                                SetLocalString(OBJECT_SELF, sNameOfValue + "7", sValue7);
                                if(nSize >= 8)
                                {
                                    SetLocalString(OBJECT_SELF, sNameOfValue + "8", sValue8);
                                    if(nSize >= 9)
                                    {
                                        SetLocalString(OBJECT_SELF, sNameOfValue + "9", sValue9);
                                        if(nSize >= 10)
                                        {
                                            SetLocalString(OBJECT_SELF, sNameOfValue + "10", sValue10);
                                            if(nSize >= 11)
                                            {
                                                SetLocalString(OBJECT_SELF, sNameOfValue + "11", sValue11);
                                                if(nSize >= 12)
                                                {
                                                    SetLocalString(OBJECT_SELF, sNameOfValue + "12", sValue12);
    // Hehe, this looks not stright if you stare at it! :-P
    }   }   }   }   }   }   }   }   }   }   }   }
    // The array is so big...
    SetLocalInt(OBJECT_SELF, ARRAY_SIZE + sNameOfValue, nSize);
    SetLocalInt(OBJECT_SELF, ARRAY_PERCENT + sNameOfValue, nPercentToSay);
}
// This applies an increase, decrease or no change to the intended stat.
// * Applies the effects INSTANTLY. These CANNOT be removed easily!
void AI_ApplyStatChange(int nStat, int nAmount)
{
    if(nAmount != 0)
    {
        effect eChange;
        if(nAmount < 0)
        {
            nAmount = abs(nAmount);
            eChange = SupernaturalEffect(EffectAbilityDecrease(nStat, nAmount));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
        else
        {
            eChange = SupernaturalEffect(EffectAbilityIncrease(nStat, nAmount));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
    }
}
// This will, eventually, choose X number of stats, and change them within the
// range given.
void AI_CreateRandomStats(int nLowest, int nHighest, int nAmount)
{
    if(nAmount > 0 && nHighest != 0 && nLowest != 0 && nHighest >= nLowest)
    {
        int nRange = nHighest - nLowest;
        int nNumSlots = nAmount;
        if(nNumSlots > 6) nNumSlots = 6;
        int nNumLeft = 6;
        // Walk through each stat and figure out what it's chance of being
        // modified is.  As an example, suppose we wanted to have 4 randomized
        // abilities.  We'd look at the first ability and it would have a 4 in 6
        // chance of being picked.  Let's suppose it was, the next ability would
        // have a 3 in 5 chance of being picked.  If this next ability wasn't
        // picked to be changed, the 3rd ability woud have a 3 in 4 chance of
        // being picked and so on.
        int nCnt;
        int nChange;
        for(nCnt = 0; (nNumSlots > 0 && nCnt < 6); nCnt++)
        {
           if((nNumSlots == nNumLeft) || (Random(nNumLeft) < nNumSlots))
           {
              nChange = Random(nRange) + nLowest;
              AI_ApplyStatChange(nCnt, nChange);
              nNumSlots--;
           }
           nNumLeft--;
        }
    }
}

// This will randomise other stats. Put both numbers to 0 to ignore some.
// nHPMin, nHPMax                   = HP changes.
// nReflexSaveMin, nReflexSaveMax   = Reflex Save changes
// nWillSaveMin, nWillSaveMax       = Will Save changes
// nFortSaveMin, nFortSaveMax       = Fortitude Save changes
// nACMin, nACMax                   = AC change.
//      Use nACType to define the AC type - default AC_DODGE_BONUS
// * Applies the effects INSTANTLY. These CANNOT be removed easily!
void AI_CreateRandomOther(int nHPMin, int nHPMax, int nReflexSaveMin = 0, int nReflexSaveMax = 0, int nWillSaveMin = 0, int nWillSaveMax = 0, int nFortSaveMin = 0, int nFortSaveMax = 0, int nACMin = 0, int nACMax = 0, int nACType = AC_DODGE_BONUS)
{
    int nRange, nChange, nNewChange;
    effect eChange;
    if(!(nHPMin == 0 && nHPMax == 0) && nHPMax >= nHPMin)
    {
        nRange = nHPMax - nHPMin;
        nChange = Random(nRange) + nHPMin;
        if(nChange > 0)
        {
            eChange = SupernaturalEffect(EffectTemporaryHitpoints(nChange));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
        // * Must have 1HP remaining at least.
        else if(nChange < 0 && GetMaxHitPoints() > nChange)
        {
            eChange = EffectDamage(nChange, DAMAGE_TYPE_DIVINE, DAMAGE_POWER_PLUS_TWENTY);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
    }
    if(!(nReflexSaveMin == 0 && nReflexSaveMax == 0) && nReflexSaveMax >= nReflexSaveMin)
    {
        nRange = nReflexSaveMax - nReflexSaveMin;
        nChange = Random(nRange) + nReflexSaveMin;
        if(nChange > 0)
        {
            eChange = SupernaturalEffect(EffectSavingThrowIncrease(SAVING_THROW_REFLEX, nChange));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
        // Cannot apply 0 change, but can make our saves negative
        else if(nChange < 0)
        {
            nNewChange = abs(nChange);
            eChange = SupernaturalEffect(EffectSavingThrowDecrease(SAVING_THROW_REFLEX, nNewChange));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
    }
    if(!(nWillSaveMin == 0 && nWillSaveMax == 0) && nWillSaveMax >= nWillSaveMin)
    {
        nRange = nWillSaveMax - nWillSaveMin;
        nChange = Random(nRange) + nWillSaveMin;
        if(nChange > 0)
        {
            eChange = SupernaturalEffect(EffectSavingThrowIncrease(SAVING_THROW_WILL, nChange));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
        // Cannot apply 0 change, but can make our saves negative
        else if(nChange < 0)
        {
            nNewChange = abs(nChange);
            eChange = SupernaturalEffect(EffectSavingThrowDecrease(SAVING_THROW_WILL, nNewChange));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
    }
    if(!(nFortSaveMin == 0 && nFortSaveMax == 0) && nFortSaveMax >= nFortSaveMin)
    {
        nRange = nFortSaveMax - nFortSaveMin;
        nChange = Random(nRange) + nFortSaveMin;
        if(nChange > 0)
        {
            eChange = SupernaturalEffect(EffectSavingThrowIncrease(SAVING_THROW_FORT, nChange));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
        // Cannot apply 0 change, but can make our saves negative
        else if(nChange < 0)
        {
            nNewChange = abs(nChange);
            eChange = SupernaturalEffect(EffectSavingThrowDecrease(SAVING_THROW_FORT, nNewChange));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
    }
    if(!(nACMin == 0 && nACMax == 0) && nACMax >= nACMin)
    {
        nRange = nACMax - nACMin;
        nChange = Random(nRange) + nACMin;
        if(nChange > 0)
        {
            eChange = SupernaturalEffect(EffectACIncrease(nChange, nACType));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
        else if(nChange < 0)
        {
            nNewChange = abs(nChange);
            eChange = SupernaturalEffect(EffectACDecrease(nNewChange, nACType));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eChange, OBJECT_SELF);
        }
    }
}

/*::///////////////////////////////////////////////
//:: SetListeningPatterns
//:://////////////////////////////////////////////
    Changed a lot. added in "**" (all) listening, for hearing enemies.
//::////////////////////////////////////////////*/

void AI_SetListeningPatterns()
{
    // Lag check
    if(GetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_LISTENING, AI_OTHER_MASTER)) return;
    SetListening(OBJECT_SELF, TRUE);

    // Anyone that can hear it, and is not fighting, comes and helps
    SetListenPattern(OBJECT_SELF, AI_SHOUT_I_WAS_ATTACKED, AI_SHOUT_I_WAS_ATTACKED_CONSTANT);

    //Set a custom listening pattern for the creature so that placables with
    //"NW_BLOCKER" + Blocker NPC Tag will correctly call to their blockers.
    string sBlocker = "NW_BLOCKER_BLK_" + GetTag(OBJECT_SELF);
    SetListenPattern(OBJECT_SELF, sBlocker, AI_SHOUT_BLOCKER_CONSTANT);

    // Determines combat round, if not fighting
    SetListenPattern(OBJECT_SELF, AI_SHOUT_CALL_TO_ARMS, AI_SHOUT_CALL_TO_ARMS_CONSTANT);

    // These call to allies, to move them to a battle.
    SetListenPattern(OBJECT_SELF, AI_SHOUT_HELP_MY_FRIEND, AI_SHOUT_HELP_MY_FRIEND_CONSTANT);
    SetListenPattern(OBJECT_SELF, AI_SHOUT_LEADER_FLEE_NOW, AI_SHOUT_LEADER_FLEE_NOW_CONSTANT);
    SetListenPattern(OBJECT_SELF, AI_SHOUT_LEADER_ATTACK_TARGET, AI_SHOUT_LEADER_ATTACK_TARGET_CONSTANT);

    // 1.3 - Need a killed one.
    SetListenPattern(OBJECT_SELF, AI_SHOUT_I_WAS_KILLED, AI_SHOUT_I_WAS_KILLED_CONSTANT);

    // 1.3 - PLaceables/doors which shout this get responded to!
    SetListenPattern(OBJECT_SELF, AI_SHOUT_I_WAS_OPENED, AI_SHOUT_I_WAS_OPENED_CONSTANT);

    // This will make the listener hear anything, used to react to enemy talking.
    SetListenPattern(OBJECT_SELF, "**", AI_SHOUT_ANYTHING_SAID_CONSTANT);
}

// Base for moving round thier waypoints
// - Uses ExectuteScript to run the waypoint walking.
// * If bRun is TRUE, we run all the waypoint.
// * fPause is the time delay between walking to the next waypoint (default 1.0)
void SpawnWalkWayPoints(int bRun = FALSE, float fPause = 1.0)
{
    SetLocalInt(OBJECT_SELF, WAYPOINT_RUN, bRun);
    SetLocalFloat(OBJECT_SELF, WAYPOINT_PAUSE, fPause);
    ExecuteScript(FILE_WALK_WAYPOINTS, OBJECT_SELF);
}

// This MUST be called. It fires these events:
// SetUpSpells, SetUpSkillToUse, SetListeningPatterns, SetWeapons, AdvancedAuras.
// These MUST be called! the AI might fail to work correctly if they don't fire!
void AI_SetUpEndOfSpawn()
{
    if(GetSpawnInCondition(AI_FLAG_OTHER_RETURN_TO_SPAWN_LOCATION, AI_OTHER_MASTER))
    {
        // This will store thier starting location, and then move back there after combat
        // Will turn off if there are waypoints. It is set in SetUpEndOfSpawn.
        SetAILocation(AI_RETURN_TO_POINT, GetLocation(OBJECT_SELF));
    }

    // Set up if we are immune to cirtain levels of spells naturally for better
    // AI spellcasters.
    object oHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, OBJECT_SELF);
    // Get if immune is on
    if(GetItemHasItemProperty(oHide, ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL))
    {
        itemproperty eCheck = GetFirstItemProperty(oHide);
        int nAmount;
        // Check for item properties until we find the level.
        while(GetIsItemPropertyValid(eCheck) && nAmount == FALSE)
        {
            // Check subtype.
            if(GetItemPropertyType(eCheck) == ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL)
            {
                // Get the amount
                nAmount = GetItemPropertyCostTableValue(eCheck);
            }
            eCheck = GetNextItemProperty(oHide);
        }
        // Set it
        if(nAmount)
        {
            SetLocalInt(OBJECT_SELF, AI_SPELL_IMMUNE_LEVEL, nAmount);
        }
    }

    // All things only used by my personal AI.
    // * If we are not using a custom AI file, we do these things.
    if(GetCustomAIFileName() == "")
    {
        // If we are a commoner of any sort, and under 10 hit dice, we are
        // panicy - IE: We set to -1 morale, which triggers the "commoner" fleeing
        if(GetLevelByClass(CLASS_TYPE_COMMONER) && GetHitDice(OBJECT_SELF) < 10)
        {
            SetAIInteger(AI_MORALE, -1);
        }
        // If we are not set already to fearless, we might be set to fearless
        if(!GetSpawnInCondition(AI_FLAG_FLEEING_FEARLESS, AI_TARGETING_FLEE_MASTER))
        {
            AI_SetMaybeFearless();
        }
        // Set if we are a beholder or mindflayer
        switch(GetAppearanceType(OBJECT_SELF))
        {
            // Sets we are a Beholder and use Ray attacks, and Animagic Ray.
            case APPEARANCE_TYPE_BEHOLDER: // beholder, 401
            case APPEARANCE_TYPE_BEHOLDER_EYEBALL: // beholder, 402
            case APPEARANCE_TYPE_BEHOLDER_MAGE: // beholder, 403
            case APPEARANCE_TYPE_BEHOLDER_MOTHER: // Hive mother, 472
            {
                // 1 = beholder
                SetAIInteger(AI_SPECIAL_AI, AI_SPECIAL_AI_BEHOLDER);
            }
            break;

            // Set we are a mindflayer, and uses some special AI for them, IE:
            // brain sucking.
            case APPEARANCE_TYPE_MINDFLAYER: // Mindflayer, 413
            case APPEARANCE_TYPE_MINDFLAYER_2: // Mindflayer2, 414
            case APPEARANCE_TYPE_MINDFLAYER_ALHOON: // Mindflayer_Alhoon, 415
            {
                // 2 = mindflayer
                SetAIInteger(AI_SPECIAL_AI, AI_SPECIAL_AI_MINDFLAYER);
            }
            break;
        }

        // This will turn OFF skills we cannot use, so will never attempt them
        // at low skill levels anywhere in the AI.
        AI_SetUpSkillToUse();

        // Sets the turning level if we have FEAT_TURN_UNDEAD.
        AI_SetTurningLevel();

        // This sets what weapons the creature will use. They will use the best, according to a "value"
        // Giving a creature the feat Two-weapon-fighting makes them deul wield if appropriate weapons.
        SetWeapons();
    }

    // We don't set up corpses if set not to...else set to resurrect
    if(!GetSpawnInCondition(AI_FLAG_OTHER_TURN_OFF_CORPSES, AI_OTHER_MASTER))
    {
        // Note: Here, if we can, we set Bioware's lootable on.
        if(GetSpawnInCondition(AI_FLAG_OTHER_USE_BIOWARE_LOOTING, AI_OTHER_MASTER))
        {
            // Set to lootable
            SetLootable(OBJECT_SELF, TRUE);
        }
        // Just handling corpse raising/resurrection/removal
        // - Undestroyable, Raiseable and Selectable
        SetIsDestroyable(FALSE, TRUE, TRUE);
    }

    // Goes through and sets up which shouts the NPC will listen to.
    // - Custom AI uses this also, or should take advantage of it
    AI_SetListeningPatterns();

    // This activates the creatures aura's.
    if(GetCommandable()) AI_AdvancedAuras();
}

// Sets the turning level if we have FEAT_TURN_UNDEAD.
void AI_SetTurningLevel()
{
    // Most taken directly from NW_S2_TURNDEAD which is used with FEAT_TURN_UNDEAD
    if(GetHasFeat(FEAT_TURN_UNDEAD))
    {
        // By default, it is clerical levels which provide turn undead power.
        // We can turn HD up to nTurnLevel (HD = GetHitDice + GetTurnREsistsnceHD of undead)
        int nTurnLevel = GetLevelByClass(CLASS_TYPE_CLERIC);
        // Paladins turn at -2 the level of clerics
        if(GetLevelByClass(CLASS_TYPE_PALADIN) - 2 > nTurnLevel)
        {
            nTurnLevel = GetLevelByClass(CLASS_TYPE_PALADIN) - 2;
        }
        // Blackguard gets to turn at HITDICE -2 level, not character level,
        // as it says in NW_S2_TURNDEAD.
        if(GetLevelByClass(CLASS_TYPE_BLACKGUARD) > 0 &&
          (GetHitDice(OBJECT_SELF) - 2 > nTurnLevel))
        {
            nTurnLevel = GetHitDice(OBJECT_SELF) - 2;
        }
        // BTW, the number of undead turned is at least nTurnLevel, so we
        // can always turn one :-D
        SetAIInteger(AI_TURNING_LEVEL, nTurnLevel);
        // Note: Turn undead could be used for FEAT_DIVINE_MIGHT and
        // FEAT_DIVINE_SHIELD
    }
}
// This should not be used!
// * called from SetUpEndOfSpawn.
void AI_SetMaybeFearless()
{
    // Cirtain races are immune to fear
    switch(GetRacialType(OBJECT_SELF))
    {
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_DRAGON:
        case RACIAL_TYPE_UNDEAD:
        case RACIAL_TYPE_OUTSIDER:
        {
            SetSpawnInCondition(AI_FLAG_FLEEING_FEARLESS, AI_TARGETING_FLEE_MASTER);
            return;
        }
        break;
    }
    // If we are immune to fear anyway, we don't care
    if(GetHasFeat(FEAT_AURA_OF_COURAGE) ||
       GetHasFeat(FEAT_RESIST_NATURES_LURE) ||
       GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_FEAR))
    {
        SetSpawnInCondition(AI_FLAG_FLEEING_FEARLESS, AI_TARGETING_FLEE_MASTER);
    }
}

// Activate all auras.
void AI_ActivateAura(int nAuraNumber)
{
    // Just ActionCast - cheat cast, as then we can use it unlmimted times, as books say.
    if(GetHasSpell(nAuraNumber))
    {
        ActionCastSpellAtObject(nAuraNumber, OBJECT_SELF, METAMAGIC_NONE, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
    }
}
// This will activate one aura, very quickly.
// If we have more than one...oh well.
void AI_AdvancedAuras()
{
    // Do aura's

    // NOTE:
    // - All cheat cast. As DMG, they should be always on OR free action to reapply.
    ClearAllActions();
    AI_ActivateAura(SPELLABILITY_DRAGON_FEAR);
    AI_ActivateAura(SPELLABILITY_AURA_UNEARTHLY_VISAGE);
    AI_ActivateAura(SPELLABILITY_AURA_BLINDING);
    AI_ActivateAura(SPELLABILITY_AURA_OF_COURAGE);
    AI_ActivateAura(SPELLABILITY_AURA_PROTECTION);
    AI_ActivateAura(SPELLABILITY_AURA_STUN);
    AI_ActivateAura(SPELLABILITY_AURA_FIRE);
    AI_ActivateAura(SPELLABILITY_AURA_COLD);
    AI_ActivateAura(SPELLABILITY_AURA_ELECTRICITY);
    AI_ActivateAura(SPELLABILITY_AURA_UNNATURAL);
    AI_ActivateAura(SPELLABILITY_AURA_FEAR);
    AI_ActivateAura(SPELLABILITY_AURA_UNNATURAL);
    AI_ActivateAura(SPELLABILITY_AURA_MENACE);
    AI_ActivateAura(SPELLABILITY_TYRANT_FOG_MIST);
    AI_ActivateAura(AI_SPELLABILITY_AURA_OF_HELLFIRE);
    AI_ActivateAura(SPELLABILITY_AURA_HORRIFICAPPEARANCE);
}

// Sets up thier selection of skills, to integers, if they would ever use them.
// NOTE: it also triggers "hide" if they have enough skill and not stopped.
void AI_SetUpSkillToUse()
{
    // Get our hitdice
    int nHitDice = GetHitDice(OBJECT_SELF);
    int nRank;
    // Hiding. We turn off if we have no skill or under 1 skill in it
    // * Note: For the AI to decide "oh, we should hide", it requires a minimum
    //   of 7 points in hide, and Rank - 4 must be >= our HD too. Can be forced.
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_HIDING, AI_OTHER_COMBAT_MASTER))
    {
        if(!GetHasSkill(SKILL_HIDE) ||
            GetSkillRank(SKILL_HIDE) < 1)
        {
            SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_HIDING, AI_OTHER_COMBAT_MASTER);
            DeleteSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_HIDING, AI_OTHER_COMBAT_MASTER);
        }
    }
    // Pickpocketing...we only turn it OFF here if low skill
    // (or none) Needs 1/2 HD or 10 minimum - 10 is probably needed for the DC35
    // check for this skill at all.
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PICKPOCKETING, AI_OTHER_COMBAT_MASTER))
    {
        nRank = GetSkillRank(SKILL_PICK_POCKET);
        if(!GetHasSkill(SKILL_PICK_POCKET) ||
            nRank < nHitDice/2 || nRank < 10)
        {
            SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PICKPOCKETING, AI_OTHER_COMBAT_MASTER);
            DeleteSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_PICKPOCKETING, AI_OTHER_COMBAT_MASTER);
        }
    }
    // Taunting. Again, only off if low skill. Needs half of HD, or 3 minimum
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_TAUNTING, AI_OTHER_COMBAT_MASTER))
    {
        nRank = GetSkillRank(SKILL_TAUNT);
        if(!GetHasSkill(SKILL_TAUNT) ||
            nRank < nHitDice/2 || nRank < 3)
        {
            SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_TAUNTING, AI_OTHER_COMBAT_MASTER);
            DeleteSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_TAUNTING, AI_OTHER_COMBAT_MASTER);
        }
    }
    // Empathy. Again, only off if low skill. Needs any, checked futher in game.
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_EMPATHY, AI_OTHER_COMBAT_MASTER))
    {
        if(!GetHasSkill(SKILL_ANIMAL_EMPATHY))
        {
            SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_EMPATHY, AI_OTHER_COMBAT_MASTER);
            DeleteSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_EMPATHY, AI_OTHER_COMBAT_MASTER);
        }
    }
    // Unlocking doors. Again, only off if low skill. Needs any, checked futher in game.
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_OPENING_LOCKED_DOORS, AI_OTHER_COMBAT_MASTER))
    {
        if(!GetHasSkill(SKILL_OPEN_LOCK))
        {
            SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_OPENING_LOCKED_DOORS, AI_OTHER_COMBAT_MASTER);
            DeleteSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_OPENING_LOCKED_DOORS, AI_OTHER_COMBAT_MASTER);
        }
    }
    // Healing kits.
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_USING_HEALING_KITS, AI_OTHER_COMBAT_MASTER))
    {
        if(!GetHasSkill(SKILL_HEAL))
        {
            SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_USING_HEALING_KITS, AI_OTHER_COMBAT_MASTER);
            DeleteSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_USING_HEALING_KITS, AI_OTHER_COMBAT_MASTER);
        }
    }
    // Parrying
    // Only on if we have some skill in it :-)
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PARRYING, AI_OTHER_COMBAT_MASTER))
    {
        if(!GetHasSkill(SKILL_PARRY))
        {
            SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PARRYING, AI_OTHER_COMBAT_MASTER);
            DeleteSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_PARRYING, AI_OTHER_COMBAT_MASTER);
        }
    }
}

// This will make the visual effect passed play INSTANTLY at the creatures location.
// * nVFX - The visual effect constant number
void AI_SpawnInInstantVisual(int nVFX)
{
    // Beta 3 change: Made to at location.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT,
                          EffectVisualEffect(nVFX),
                          GetLocation(OBJECT_SELF));
}
// This will make the visual effect passed play PERMAMENTLY.
// * nVFX - The visual effect constant number
// NOTE: They will be made to be SUPERNATUAL, so are not dispelled!
void AI_SpawnInPermamentVisual(int nVFX)
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT,
                        SupernaturalEffect(EffectVisualEffect(nVFX)),
                        OBJECT_SELF);
}
// This will set the MAXIMUM and MINIMUM targets to pass this stage (under sName)
// of the targeting system. IE:
// - If we set it to min of 5, max of 10, for AC, if we cancled 5 targets on having
//   AC higher then wanted, we will take the highest 5 minimum.
//   If there are over 10, we take a max of 10 to choose from.
// * nType - must be TARGET_HIGHER or TARGET_LOWER. Defaults to the lowest, so it
//           targets the lowest value for sName.
void AI_SetAITargetingValues(string sName, int nType, int nMinimum, int nMaximum)
{
    // Error checking
    if((nType == TARGET_HIGHER || nType == TARGET_LOWER) &&
        nMinimum >= 1 && nMaximum >= 1 && nMaximum >= nMinimum)
    {
        // Set the type to sName.
        // - It is TARGET_HIGHER (1) or TARGET_LOWER (0).
        SetAIInteger(sName, nType);

        // Minimum amount of targets for this?
        SetAIInteger(sName + MINIMUM, nMinimum);

        // Maximum targets for this?
        SetAIInteger(sName + MAXIMUM, nMaximum);
    }
}

// This will set a spell trigger up. Under cirtain conditions, spells are released
// and cast on the caster.
// Once fired, a spell trigger is only reset by resting. Only 1 of each max is fired at once!
// * sType - is specifically:
//   SPELLTRIGGER_DAMAGED_AT_PERCENT  - When damaged, the trigger fires. Use iValue for the %. One at a time is fired.
//   SPELLTRIGGER_IMMOBILE            - Fired when held/paralyzed/sleeping ETC. One at a time is fired.
//   SPELLTRIGGER_NOT_GOT_FIRST_SPELL - Makes sure !GetHasSpellEffect(iSpell1) already,
//                                  then fires. Checks all in this category each round (first one fires!)
//   SPELLTRIGGER_START_OF_COMBAT     - Triggered always, at the start of DetermineCombatRound.
// * nNumber - can be 1-9, in sequential order of when you want them to fire.
// * nValue - is only required with DAMAGED_AT_PERCENT.
// * nSpellX - Cannot be 0. It should only really be defensive spells.
void SetSpellTrigger(string sType, int nValue, int nNumber, int nSpell1, int nSpell2 = 0, int nSpell3 = 0, int nSpell4 = 0, int nSpell5 = 0, int nSpell6 = 0, int nSpell7 = 0, int nSpell8 = 0, int nSpell9 = 0)
{
    // Either get our spell trigger (creature) or create one
    object oTrigger = GetAIObject(AI_SPELL_TRIGGER_CREATURE);
    // Is it valid?
    if(!GetIsObjectValid(oTrigger))
    {
        // Create it
        oTrigger = CreateObject(OBJECT_TYPE_CREATURE, "jass_spelltrig", GetLocation(OBJECT_SELF));
        // Set local on them for the target
        AddHenchman(OBJECT_SELF, oTrigger);
        // Local for us to get our spell trigger (should be our henchmen)
        SetAIObject(AI_SPELL_TRIGGER_CREATURE, oTrigger);
    }
    int nSize = 1;
    string sTotalID = sType + IntToString(nNumber);

    SetLocalInt(oTrigger, sTotalID + "1", nSpell1);
    if(nSpell2 != FALSE)
    {   nSize = 2;
        SetLocalInt(oTrigger, sTotalID + "2", nSpell2);    }
    if(nSpell3 != FALSE)
    {   nSize = 3;
        SetLocalInt(oTrigger, sTotalID + "3", nSpell3);    }
    if(nSpell4 != FALSE)
    {   nSize = 4;
        SetLocalInt(oTrigger, sTotalID + "4", nSpell4);    }
    if(nSpell5 != FALSE)
    {   nSize = 5;
        SetLocalInt(oTrigger, sTotalID + "5", nSpell5);    }
    if(nSpell6 != FALSE)
    {   nSize = 6;
        SetLocalInt(oTrigger, sTotalID + "6", nSpell6);    }
    if(nSpell7 != FALSE)
    {   nSize = 7;
        SetLocalInt(oTrigger, sTotalID + "7", nSpell7);    }
    if(nSpell8 != FALSE)
    {   nSize = 8;
        SetLocalInt(oTrigger, sTotalID + "8", nSpell8);    }
    if(nSpell9 != FALSE)
    {   nSize = 9;
        SetLocalInt(oTrigger, sTotalID + "9", nSpell9);    }

    // Set final sizes ETC.
    SetLocalInt(oTrigger, MAXINT_ + sTotalID, nSize);
    SetLocalInt(oTrigger, sTotalID + USED, FALSE);

    // Check value
    if(nValue > GetLocalInt(oTrigger, VALUE + sType))
    {
        SetLocalInt(oTrigger, VALUE + sType, nValue);
    }

    // Set how many spell triggers we have too
    if(nNumber > GetLocalInt(oTrigger, MAXIMUM + sType))
    {
        SetLocalInt(oTrigger, MAXIMUM + sType, nNumber);
    }
}
// Debug: To compile this script, uncomment all of the below.
/* - Add two "/"'s at the start of this line
void main()
{
    return;
}
//*/

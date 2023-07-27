/************************ [Spawn In Include] ***********************************
    Filename: J_Inc_SpawnIn
************************* [Spawn In Include] ***********************************
    This contains all the functions used in the spawning process, in one easy
    and very long file.

    It also importantly sets up spells we have, or at least talents, so we
    know if we have any spells from category X.
************************* [History] ********************************************
    1.3 - Changed, added a lot of new things (such as constants file)
************************* [Workings] *******************************************
    This doesn't call anything to run the rest, except AI_SetUpEndOfSpawn has
    a lot of things that the generic AI requires (SetListeningPatterns and skills
    and waypoints ETC)

    See the spawn in script for all the actual uses.
************************* [Arguments] ******************************************
    Arguments: N/A see spawn in script
************************* [Spawn In Include] **********************************/

// All constants.
#include "j_inc_setweapons"
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
// Activate the aura number, if it is possible.
void AI_ActivateAura(int nAuraNumber);
// This is an attempt to speed up some things.
// We use talents to set general valid categories.
// Levels are also accounted for, checking the spell given and using a switch
// statement to get the level.
void AI_SetUpSpells();

// Base for moving round thier waypoints
// - Uses ExectuteScript to run the waypoint walking.
void SpawnWalkWayPoints(int nRun = FALSE, float fPause = 1.0);

// Sets up what we will listen to (everything!)
void AI_SetListeningPatterns();
// This will set what creature to create OnDeath.
void AI_SetDeathResRef(string sResRef);
// This will set the string, sNameOfValue, to sValue. Array size of 1.
// - Use iPercentToSay to determine what % out of 100 it is said.
void AI_SetSpawnInSpeakValue(string sNameOfValue, string sValue, int iPercentToSay = 100);
// This will choose a random string, using iAmountOfValues, which is
// the amount of non-empty strings given. The size of the array is therefore 1.
// - Use iPercentToSay to determine what % out of 100 it is said.
void AI_SetSpawnInSpeakRandomValue(string sNameOfValue, int iPercentToSay, int iAmountOfValues, string sValue1, string sValue2, string sValue3 = "", string sValue4 = "", string sValue5 = "", string sValue6 = "", string sValue7 = "", string sValue8 = "", string sValue9 = "", string sValue10 = "", string sValue11 = "", string sValue12 = "");
// This will set an array of values, to sNameOfValue, for one to be chosen to
// be said at the right time :-)
// - sNameOfValue must be a valid name.
// - Use iPercentToSay to determine what % out of 100 it is said.
// NOTE: If the sNameOfValue is any combat one, we make that 1/100 to 1/1000.
void AI_SetSpawnInSpeakArray(string sNameOfValue, int iPercentToSay, int iSize, string sValue1, string sValue2, string sValue3 = "", string sValue4 = "", string sValue5 = "", string sValue6 = "", string sValue7 = "", string sValue8 = "", string sValue9 = "", string sValue10 = "", string sValue11 = "", string sValue12 = "");

// This applies an increase, decrease or no change to the intended stat.
void AI_ApplyStatChange(int iStat, int iAmount);
// This will alter (magically) an ammount of random stats - iAmount
// by a value within iLowest and iHighest.
void AI_CreateRandomStats(int iLowest, int iHighest, int iAmount);
// This will randomise other stats. Put both numbers to 0 to ignore some.
// iHPMin, iHPMax                   = HP changes.
// iReflexSaveMin, iReflexSaveMax   = Reflex Save changes
// iWillSaveMin, iWillSaveMax       = Will Save changes
// iFortSaveMin, iFortSaveMax       = Fortitude Save changes
// iACMin, iACMax                   = AC change.
//      Use iACType to define the AC type - default AC_DODGE_BONUS
void AI_CreateRandomOther(int iHPMin, int iHPMax, int iReflexSaveMin = 0, int iReflexSaveMax = 0, int iWillSaveMin = 0, int iWillSaveMax = 0, int iFortSaveMin = 0, int iFortSaveMax = 0, int iACMin = 0, int iACMax = 0, int iACType = AC_DODGE_BONUS);

// Sets up thier selection of skills, to integers, if they would ever use them.
// NOTE: it also triggers "hide" if they have enough skill and not stopped.
void AI_SetUpSkillToUse();
// Sets the turning level if we have FEAT_TURN_UNDEAD.
// - Called from AI_SetUpEndOfSpawn.
void AI_SetTurningLevel();
// This MUST be called. It fires these events:
// SetUpSpells, SetUpSkillToUse, SetListeningPatterns, SetWeapons, AdvancedAuras.
// These MUST be called! the AI might fail to work correctly if they don't fire!
void AI_SetUpEndOfSpawn();
// This will make the visual effect passed play INSTANTLY at the creatures location.
// * iVFX - The visual effect constant number
void AI_SpawnInInstantVisual(int iVFX);
// This will make the visual effect passed play PERMAMENTLY.
// * iVFX - The visual effect constant number
// NOTE: They will be made to be SUPERNATUAL, so are not dispelled!
void AI_SpawnInPermamentVisual(int iVFX);
// This should not be used!
// * called from SetUpEndOfSpawn.
void AI_SetMaybeFearless();
// This will set the MAXIMUM and MINIMUM targets to pass this stage (under sName)
// of the targeting system. IE:
// - If we set it to min of 5, max of 10, for AC, if we cancled 5 targets on having
//   AC higher then wanted, we will take the highest 5 minimum.
//   If there are over 10, we take a max of 10 to choose from.
// * iType - must be TARGET_HIGHER or TARGET_LOWER. Defaults to the lowest, so it
//           targets the lowest value for sName.
void AI_SetAITargetingValues(string sName, int iType, int iMinimum, int iMaximum);


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
void SetAICheatCastSpells(int iSpell1, int iSpell2, int iSpell3, int iSpell4, int iSpell5, int iSpell6);

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
// * iNumber - can be 1-9, in sequential order of when you want them to fire.
// * iValue - is only required with DAMAGED_AT_PERCENT.
// * iSpellX - Cannot be 0. It should only really be defensive spells.
void SetSpellTrigger(string sType, int iValue, int iNumber, int iSpell1, int iSpell2 = 0, int iSpell3 = 0, int iSpell4 = 0, int iSpell5 = 0, int iSpell6 = 0, int iSpell7 = 0, int iSpell8 = 0, int iSpell9 = 0);

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
void SetAICheatCastSpells(int iSpell1, int iSpell2, int iSpell3, int iSpell4, int iSpell5, int iSpell6)
{
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(i1), iSpell1);
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(i2), iSpell2);
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(i3), iSpell3);
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(i4), iSpell4);
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(i5), iSpell5);
    SetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(i6), iSpell6);
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
    int iDivideBy = (nClass >= i0) + (nClass2 >= i0) + (nClass3 >= i0);

    int iTotalPerClass = nLevel / iDivideBy;

    // Limit and loop - Class 1.
    AI_LevelLoop(nClass, iTotalPerClass);
    // 2
    AI_LevelLoop(nClass2, iTotalPerClass);
    // 3
    AI_LevelLoop(nClass3, iTotalPerClass);
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
    SetLocalString(OBJECT_SELF, sNameOfValue + s1, sValue);
    // The array is 1 big!
    SetLocalInt(OBJECT_SELF, ARRAY_SIZE + sNameOfValue, i1);
    SetLocalInt(OBJECT_SELF, ARRAY_PERCENT + sNameOfValue, iPercentToSay);
}
// This will choose a random string, using iAmountOfValues, which is
// the amount of non-empty strings given. The size of the array is therefore 1.
// - Use iPercentToSay to determine what % out of 100 it is said.
void AI_SetSpawnInSpeakRandomValue(string sNameOfValue, int iPercentToSay, int iAmountOfValues, string sValue1, string sValue2, string sValue3, string sValue4, string sValue5, string sValue6, string sValue7, string sValue8, string sValue9, string sValue10, string sValue11, string sValue12)
{
    // Need a value amount of values!
    if(iAmountOfValues)
    {
        int iRandomNum = Random(iAmountOfValues) -1; // take one, as it is 0 - X, not 1 - X
        string sValueToUse;
        switch(iRandomNum)
        {
            case(i0):{sValueToUse = sValue1;}break;
            case(i1):{sValueToUse = sValue2;}break;
            case(i2):{sValueToUse = sValue3;}break;
            case(i3):{sValueToUse = sValue4;}break;
            case(i4):{sValueToUse = sValue5;}break;
            case(i5):{sValueToUse = sValue6;}break;
            case(i6):{sValueToUse = sValue7;}break;
            case(i7):{sValueToUse = sValue8;}break;
            case(i8):{sValueToUse = sValue9;}break;
            case(i9):{sValueToUse = sValue10;}break;
            case(i10):{sValueToUse = sValue11;}break;
            case(i11):{sValueToUse = sValue12;}break;
        }
        SetLocalString(OBJECT_SELF, sNameOfValue + s1, sValueToUse);
        // The array is 1 big!
        SetLocalInt(OBJECT_SELF, ARRAY_SIZE + sNameOfValue, i1);
        SetLocalInt(OBJECT_SELF, ARRAY_PERCENT + sNameOfValue, iPercentToSay);
    }
}
void AI_SetSpawnInSpeakArray(string sNameOfValue, int iPercentToSay, int iSize, string sValue1, string sValue2, string sValue3 = "", string sValue4 = "", string sValue5 = "", string sValue6 = "", string sValue7 = "", string sValue8 = "", string sValue9 = "", string sValue10 = "", string sValue11 = "", string sValue12 = "")
{
    if(iSize >= i1)
    {
        SetLocalString(OBJECT_SELF, sNameOfValue + "1", sValue1);
        if(iSize >= i2)
        {
            SetLocalString(OBJECT_SELF, sNameOfValue + "2", sValue2);
            if(iSize >= i3)
            {
                SetLocalString(OBJECT_SELF, sNameOfValue + "3", sValue3);
                if(iSize >= i4)
                {
                    SetLocalString(OBJECT_SELF, sNameOfValue + "4", sValue4);
                    if(iSize >= i5)
                    {
                        SetLocalString(OBJECT_SELF, sNameOfValue + "5", sValue5);
                        if(iSize >= i6)
                        {
                            SetLocalString(OBJECT_SELF, sNameOfValue + "6", sValue6);
                            if(iSize >= i7)
                            {
                                SetLocalString(OBJECT_SELF, sNameOfValue + "7", sValue7);
                                if(iSize >= i8)
                                {
                                    SetLocalString(OBJECT_SELF, sNameOfValue + "8", sValue8);
                                    if(iSize >= i9)
                                    {
                                        SetLocalString(OBJECT_SELF, sNameOfValue + "9", sValue9);
                                        if(iSize >= i10)
                                        {
                                            SetLocalString(OBJECT_SELF, sNameOfValue + "10", sValue10);
                                            if(iSize >= i11)
                                            {
                                                SetLocalString(OBJECT_SELF, sNameOfValue + "11", sValue11);
                                                if(iSize >= i12)
                                                {
                                                    SetLocalString(OBJECT_SELF, sNameOfValue + "12", sValue12);
    // Hehe, this looks not stright if you stare at it! :-P
    }   }   }   }   }   }   }   }   }   }   }   }
    // The array is so big...
    SetLocalInt(OBJECT_SELF, ARRAY_SIZE + sNameOfValue, iSize);
    SetLocalInt(OBJECT_SELF, ARRAY_PERCENT + sNameOfValue, iPercentToSay);
}
// This applies an increase, decrease or no change to the intended stat.
void AI_ApplyStatChange(int iStat, int iAmount)
{
    if(iAmount != i0)
    {
        effect eChange;
        if(iAmount < i0)
        {
            int iNewAmount = abs(iAmount);
            eChange = SupernaturalEffect(EffectAbilityDecrease(iStat, iNewAmount));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
        else
        {
            eChange = SupernaturalEffect(EffectAbilityIncrease(iStat, iAmount));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
    }
}
// This will, eventually, choose X number of stats, and change them within the
// range given.
void AI_CreateRandomStats(int iLowest, int iHighest, int iAmount)
{
    if(iAmount > i0 && !(iLowest == i0 && iHighest == i0) && iHighest >= iLowest)
    {
        int iRange = iHighest - iLowest;
        int iNumSlots = iAmount;
        if(iNumSlots > i6) iNumSlots = i6;
        int iNumLeft = i6;
        // Walk through each stat and figure out what it's chance of being
        // modified is.  As an example, suppose we wanted to have 4 randomized
        // abilities.  We'd look at the first ability and it would have a 4 in 6
        // chance of being picked.  Let's suppose it was, the next ability would
        // have a 3 in 5 chance of being picked.  If this next ability wasn't
        // picked to be changed, the 3rd ability woud have a 3 in 4 chance of
        // being picked and so on.
        int iCnt;
        int iChange;
        for(iCnt = i0; (iNumSlots > i0) && (iCnt < i6); iCnt++)
        {
           if((iNumSlots == iNumLeft) || (Random(iNumLeft) < iNumSlots))
           {
              iChange = Random(iRange) + iLowest;
              AI_ApplyStatChange(iCnt, iChange);
              iNumSlots--;
           }
           iNumLeft--;
        }
    }
}

void AI_CreateRandomOther(int iHPMin, int iHPMax, int iReflexSaveMin = 0, int iReflexSaveMax = 0, int iWillSaveMin = 0, int iWillSaveMax = 0, int iFortSaveMin = 0, int iFortSaveMax = 0, int iACMin = 0, int iACMax = 0, int iACType = AC_DODGE_BONUS)
{
    int iRange, iChange, iNewChange;
    effect eChange;
    if(!(iHPMin == i0 && iHPMax == i0) && iHPMax >= iHPMin)
    {
        iRange = iHPMax - iHPMin;
        iChange = Random(iRange) + iHPMin;
        if(iChange > i0)
        {
            eChange = SupernaturalEffect(EffectTemporaryHitpoints(iChange));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
        else if(iChange < i0 && GetMaxHitPoints() > i1)
        {
            eChange = EffectDamage(iChange, DAMAGE_TYPE_DIVINE, DAMAGE_POWER_PLUS_FIVE);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
    }
    if(!(iReflexSaveMin == i0 && iReflexSaveMax == i0) && iReflexSaveMax >= iReflexSaveMin)
    {
        iRange = iReflexSaveMax - iReflexSaveMin;
        iChange = Random(iRange) + iReflexSaveMin;
        if(iChange > i0)
        {
            eChange = SupernaturalEffect(EffectSavingThrowIncrease(SAVING_THROW_REFLEX, iChange));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
        else if(iChange < i0 && GetReflexSavingThrow(OBJECT_SELF) > i1)
        {
            iNewChange = abs(iChange);
            eChange = SupernaturalEffect(EffectSavingThrowDecrease(SAVING_THROW_REFLEX, iNewChange));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
    }
    if(!(iWillSaveMin == i0 && iWillSaveMax == i0) && iWillSaveMax >= iWillSaveMin)
    {
        iRange = iWillSaveMax - iWillSaveMin;
        iChange = Random(iRange) + iWillSaveMin;
        if(iChange > i0)
        {
            eChange = SupernaturalEffect(EffectSavingThrowIncrease(SAVING_THROW_WILL, iChange));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
        else if(iChange < i0 && GetWillSavingThrow(OBJECT_SELF) > i1)
        {
            iNewChange = abs(iChange);
            eChange = SupernaturalEffect(EffectSavingThrowDecrease(SAVING_THROW_WILL, iNewChange));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
    }
    if(!(iFortSaveMin == i0 && iFortSaveMax == i0) && iFortSaveMax >= iFortSaveMin)
    {
        iRange = iFortSaveMax - iFortSaveMin;
        iChange = Random(iRange) + iFortSaveMin;
        if(iChange > i0)
        {
            eChange = SupernaturalEffect(EffectSavingThrowIncrease(SAVING_THROW_FORT, iChange));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
        else if(iChange < i0 && GetFortitudeSavingThrow(OBJECT_SELF) > 1)
        {
            iNewChange = abs(iChange);
            eChange = SupernaturalEffect(EffectSavingThrowDecrease(SAVING_THROW_FORT, iNewChange));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
    }
    if(!(iACMin == i0 && iACMax == i0) && iACMax >= iACMin)
    {
        iRange = iACMax - iACMin;
        iChange = Random(iRange) + iACMin;
        if(iChange > i0)
        {
            eChange = SupernaturalEffect(EffectACIncrease(iChange, iACType));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
        }
        else if(iChange < i0)
        {
            iNewChange = abs(iChange);
            eChange = SupernaturalEffect(EffectACDecrease(iNewChange, iACType));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eChange, OBJECT_SELF);
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
//  Anyone that can hear it, and is not fighting, comes and helps
    SetListenPattern(OBJECT_SELF, I_WAS_ATTACKED, i1);
    //Set a custom listening pattern for the creature so that placables with
    //"NW_BLOCKER" + Blocker NPC Tag will correctly call to their blockers.
    string sBlocker = "NW_BLOCKER_BLK_" + GetTag(OBJECT_SELF);
    SetListenPattern(OBJECT_SELF, sBlocker, i2);
//  Determines combat round, if not fighting
    SetListenPattern(OBJECT_SELF, CALL_TO_ARMS, i3);
    // These call to allies, to move them to a battle.
    SetListenPattern(OBJECT_SELF, HELP_MY_FRIEND, i4);
    SetListenPattern(OBJECT_SELF, LEADER_FLEE_NOW, i5);
    SetListenPattern(OBJECT_SELF, LEADER_ATTACK_TARGET, i6);
    // 1.3 - Need a killed one.
    SetListenPattern(OBJECT_SELF, I_WAS_KILLED, i7);
    // 1.3 - PLaceables/doors which shout this get responded to!
    SetListenPattern(OBJECT_SELF, I_WAS_OPENED, i8);
// This will make the listener hear anything, used to react to enemy talking.
    SetListenPattern(OBJECT_SELF, "**", i0);
}
// Base for moving round thier waypoints
// - Uses ExectuteScript to run the waypoint walking.
/*
void SpawnWalkWayPoints(int nRun = FALSE, float fPause = 1.0)
{
    SetLocalInt(OBJECT_SELF, WAYPOINT_RUN, nRun);
    SetLocalFloat(OBJECT_SELF, WAYPOINT_PAUSE, fPause);
    ExecuteScript(FILE_WALK_WAYPOINTS, OBJECT_SELF);
}
*/

void AI_SetUpEndOfSpawn()
{
    // Check if we are using custom AI - this cuts out much of the stuff
    // used on spawn.
    int bCustomAIFile = FALSE;

    // Check custom AI file
    if(GetCustomAIFileName() != "")
    {
        bCustomAIFile = TRUE;
    }

    if(GetSpawnInCondition(AI_FLAG_OTHER_RETURN_TO_SPAWN_LOCATION, AI_OTHER_MASTER))
    {
        // This will store thier starting location, and then move back there after combat
        // Will turn off if there are waypoints. It is set in SetUpEndOfSpawn.
        SetLocalLocation(OBJECT_SELF, AI_RETURN_TO_POINT, GetLocation(OBJECT_SELF));
    }

    // Set up if we are immune to cirtain levels of spells naturally for better
    // AI spellcasters.
    object oHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, OBJECT_SELF);
    // Get if immune is on
    if(GetItemHasItemProperty(oHide, ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL))
    {
        itemproperty eCheck = GetFirstItemProperty(oHide);
        int iAmount;
        // Check for item properties until we find the level.
        while(GetIsItemPropertyValid(eCheck) && iAmount == FALSE)
        {
            // Check subtype.
            if(GetItemPropertyType(eCheck) == ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL)
            {
                // Get the amount
                iAmount = GetItemPropertyCostTableValue(eCheck);
            }
            eCheck = GetNextItemProperty(oHide);
        }
        // Set it
        if(iAmount)
        {
            SetLocalInt(OBJECT_SELF, AI_SPELL_IMMUNE_LEVEL, iAmount);
        }
    }
    // Animations - any valid?
    if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS, NW_GENERIC_MASTER) ||
       GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN, NW_GENERIC_MASTER) ||
       GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS, NW_GENERIC_MASTER))
    {
       SetAIInteger(AI_VALID_ANIMATIONS, TRUE);
    }

    // All things only used by my personal AI.
    if(!bCustomAIFile)
    {
        if(GetLevelByClass(CLASS_TYPE_COMMONER) && GetHitDice(OBJECT_SELF) < i10)
        {
            SetAIInteger(AI_MORALE, iM1);
        }
        if(!GetSpawnInCondition(AI_FLAG_FLEEING_FEARLESS, AI_TARGETING_FLEE_MASTER))
        {
            AI_SetMaybeFearless();
        }
        // Set if we are a beholder or mindflayer
        switch(GetAppearanceType(OBJECT_SELF))
        {
            case 401: //beholder
            case 402: //beholder
            case 403: //beholder
            case 472: // Hive mother
                SetBeholderAI();
            break;

            case 413: //Mindflayer
            case 414: // Mindflayer2
            case 415: // Mindflayer_Alhoon
                SetMindflayerAI();
            break;
        }
            // This NEEDS to be called - to set up categories of spells the creature
            // will use
        AI_SetUpSpells();
            // Sets up thier selection of skills, to integers, if they would ever use them.
            // NOTE: it also triggers "hide" if they have enough skill and not stopped.
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
        // TFN assumes henchmen are destroyable, and fixes raisability itself anyway
        //SetIsDestroyable(FALSE, TRUE, TRUE);
    }


    // Goes through and sets up which shouts the NPC will listen to.
    // - Custom AI uses this also
    AI_SetListeningPatterns();

    // This activates the creatures top aura.
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
        if(GetLevelByClass(CLASS_TYPE_PALADIN) - i2 > nTurnLevel)
        {
            nTurnLevel = GetLevelByClass(CLASS_TYPE_PALADIN) - i2;
        }
        // Blackguard gets to turn at HITDICE -2 level, not character level,
        // as it says in NW_S2_TURNDEAD.
        if(GetLevelByClass(CLASS_TYPE_BLACKGUARD) > i0 && (GetHitDice(OBJECT_SELF) - i2 > nTurnLevel))
        {
            nTurnLevel = GetHitDice(OBJECT_SELF) - i2;
        }
        // BTW, the number of undead turned is at least nTurnLevel, so we
        // can always turn one :-D
        SetAIInteger(AI_TURNING_LEVEL, nTurnLevel);
        // Note: Turn undead could be used for FEAT_DIVINE_MIGHT and FEAT_DIVINE_SHIELD
    }
}

void AI_SetMaybeFearless()
{
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
        ActionCastSpellAtObject(nAuraNumber, OBJECT_SELF, METAMAGIC_NONE, TRUE, i20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
    }
}

void AI_AdvancedAuras()
{
    if(GetSpawnInCondition(AI_VALID_TALENT_PERSISTENT_AREA_OF_EFFECT, AI_VALID_SPELLS))
    {
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
    }
}

// Sets up thier selection of skills, to integers, if they would ever use them.
// NOTE: it also triggers "hide" if they have enough skill and not stopped.
void AI_SetUpSkillToUse()
{
    int iHitDice = GetHitDice(OBJECT_SELF);
    // Hiding. We turn off if we have no skill or under 1 skill in it
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_HIDING, AI_OTHER_COMBAT_MASTER))
    {
        if(!GetHasSkill(SKILL_HIDE) ||
            GetSkillRank(SKILL_HIDE) <= i1)
        {
            SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_HIDING, AI_OTHER_COMBAT_MASTER);
            DeleteSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_HIDING, AI_OTHER_COMBAT_MASTER);
        }
    }
    // Pickpocketing...we only turn it OFF here if low skill (or none) Needs 1/4 HD.
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PICKPOCKETING, AI_OTHER_COMBAT_MASTER))
    {
        if(!GetHasSkill(SKILL_PICK_POCKET) ||
            GetSkillRank(SKILL_PICK_POCKET) < (iHitDice/i4))
        {
            SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PICKPOCKETING, AI_OTHER_COMBAT_MASTER);
            DeleteSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_PICKPOCKETING, AI_OTHER_COMBAT_MASTER);
        }
    }
    // Taunting. Again, only off if low skill. Needs half of HD
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_TAUNTING, AI_OTHER_COMBAT_MASTER))
    {
        if(!GetHasSkill(SKILL_TAUNT) ||
            GetSkillRank(SKILL_TAUNT) < (iHitDice/i2))
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

// This is an attempt to speed up some things.
// We use talents to set general valid categories.
// Levels are also accounted for, checking the spell given and using a switch
// statement to get the level.
void AI_SetUpSpells()
{
    /***************************************************************************
    We use talents, and Get2daString to check levels, and so on...

    We set:
    - If the talent is a valid one at all
    - If we know it (GetHasSpell) we check the level of the spell. Set if highest.
    - We set the actual talent number as a spell.

    // These must match the list in nwscreaturestats.cpp
    int TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT   = 1;
    int TALENT_CATEGORY_HARMFUL_RANGED                    = 2;
    int TALENT_CATEGORY_HARMFUL_TOUCH                     = 3;
    int TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT     = 4;
    int TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH          = 5;
    int TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_AREAEFFECT = 6;
    int TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE     = 7;
    int TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_AREAEFFECT = 8;
    int TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE     = 9;
    int TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SELF       = 10;
    int TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT = 11;
    int TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF        = 12;
    int TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE      = 13;
    int TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT  = 14;
    int TALENT_CATEGORY_BENEFICIAL_OBTAIN_ALLIES          = 15;
    int TALENT_CATEGORY_PERSISTENT_AREA_OF_EFFECT         = 16;
    int TALENT_CATEGORY_BENEFICIAL_HEALING_POTION         = 17;
    int TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_POTION     = 18;
    int TALENT_CATEGORY_DRAGONS_BREATH                    = 19;
    int TALENT_CATEGORY_BENEFICIAL_PROTECTION_POTION      = 20;
    int TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_POTION     = 21;
    int TALENT_CATEGORY_HARMFUL_MELEE                     = 22;
    ***************************************************************************/
    talent tCheck;
    // This is set to TRUE if any are valid. :-D
    int SpellAnySpell;


    /** TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT   = 1; *****************
    These are *generally* spells which are Harmful, affect many targets in an
    area, and don't hit allies. Spells such as Wierd (An illusion fear spell, so
    allies would know it wasn't real, but enemies wouldn't) and so on.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_HARMFUL_AREAEFFECT_DISCRIMINANT, AI_VALID_SPELLS);
    }
    /** TALENT_CATEGORY_HARMFUL_RANGED                    = 2; *****************
    These are classed as single target, short or longer ranged spells. Anything
    that affects one target, and isn't a touch spell, is this category. Examples
    like Acid Arrow or Finger of Death.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_RANGED, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_HARMFUL_RANGED, AI_VALID_SPELLS);
    }
    /** TALENT_CATEGORY_HARMFUL_TOUCH                     = 3; *****************
    A limited selection. All touch spells, like Harm. Not much to add but they
    only affect one target. Note: Inflict range are also in here (but remember
    that GetHasSpell returns TRUE if they can spontaeously cast it as well!)
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_TOUCH, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_HARMFUL_TOUCH, AI_VALID_SPELLS);
    }
    /** TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT     = 4; *****************
    Healing area effects. Basically, only Mass Heal and Healing Circle :0P

    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT, MAXCR);
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_HEALING_AREAEFFECT, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH          = 5; *****************
    These are all the healing spells that touch - Cure X wounds and heal really.
    Also, feat Wholeness of Body and Lay on Hands as well.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_HEALING_TOUCH, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_AREAEFFECT = 6; *****************
    These are spells which help people in an area to rid effects, normally. IE
    normally, a condition must be met to cast it, like them being stunned.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_AREAEFFECT, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_CONDITIONAL_AREAEFFECT, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE     = 7; *****************
    This is the same as the AOE version, but things like Clarity, single target
    ones.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_CONDITIONAL_SINGLE, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_AREAEFFECT = 8; *****************
    Enhancing stats, or self or others. Friendly, and usually stat-changing. They
    contain all ones that, basically, don't protect and stop damage, but help
    defeat enemies. In the AOE ones are things like Invisiblity Sphere.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_AREAEFFECT, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_ENHANCEMENT_AREAEFFECT, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE     = 9; *****************
    Enchancing, these are the more single ones, like Bulls Strength. See above as well.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_ENHANCEMENT_SINGLE, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SELF       = 10; ****************
    Self-encancing spells, that can't be cast on allies, like Divine Power :-)
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SELF, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_ENHANCEMENT_SELF, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT = 11; ****************
    This is the AOE spells which never discriminate between allies, and enemies,
    such as the well known spell Fireball.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_HARMFUL_AREAEFFECT_INDISCRIMINANT, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF        = 12; ****************
    Protection spells are usually a Mage's only way to stop instant death. Self
    only spells include the likes of Premonition :-)
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_PROTECTION_SELF, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT  = 14; ****************
    Protection spells are usually a Mage's only way to stop instant death.
    Area effect ones are the likes of Protection From Spells. Limited ones here.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_PROTECTION_AREAEFFECT, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_BENEFICIAL_OBTAIN_ALLIES          = 15; ****************
    Allies, or obtaining them, is anything they can summon. Basically, all
    Summon Monster 1-9, Innate ones like Summon Tanarri and ones like Gate.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_OBTAIN_ALLIES, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_OBTAIN_ALLIES, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_PERSISTENT_AREA_OF_EFFECT         = 16; ****************
    These are NOT AOE spells like acid fog, but rather the Aura's that a monster
    can use. Also, oddly, Rage's, Monk's Wholeness of Body and so on are here...
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_PERSISTENT_AREA_OF_EFFECT, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        SpellAnySpell = TRUE;
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_PERSISTENT_AREA_OF_EFFECT, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_DRAGONS_BREATH                    = 19; ****************
    Dragon Breaths. These are all the breaths avalible to Dragons. :-D Nothing else.

    All counted as level 9 innate caster level. Monster ability only :0)

    Contains (By level, innate):
    9. Dragon Breath Acid, Cold, Fear, Fire, Gas, Lightning, Paralyze, Sleep, Slow, Weaken.
    ***************************************************************************/

    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_DRAGONS_BREATH, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck))
    {
        // Then set we have it
        SetSpawnInCondition(AI_VALID_TALENT_DRAGONS_BREATH, AI_VALID_SPELLS);
    }

    /** TALENT_CATEGORY_HARMFUL_MELEE                     = 22; ****************
    We might as well check if we have any valid feats :-P

    Contains:
        Called Shot, Disarm, Imp. Power Attack, Knockdown, Power Attack, Rapid Shot,
        Sap, Stunning Fist, Flurry of blows, Quivering Palm, Smite Evil,
        Expertise (and Imp), Smite Good
    Note:
        Whirlwind attack (Improved), Dirty Fighting.
    ***************************************************************************/
    tCheck = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_MELEE, MAXCR);
    // Valid?
    if(GetIsTalentValid(tCheck) ||
       GetHasFeat(FEAT_IMPROVED_WHIRLWIND) ||
       GetHasFeat(FEAT_WHIRLWIND_ATTACK) ||
       GetHasFeat(FEAT_DIRTY_FIGHTING) ||
       GetHasFeat(FEAT_KI_DAMAGE))
    {
        // Then set we have it. If we don't have any, we never check Knockdown ETC.
        SetSpawnInCondition(AI_VALID_TALENT_HARMFUL_MELEE, AI_VALID_SPELLS);
    }

    if(SpellAnySpell == TRUE)
    {
        SetSpawnInCondition(AI_VALID_ANY_SPELL, AI_VALID_SPELLS);
    }
    // All spells in no category.
    if(
//            GetHasSpell(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE) ||
       GetHasSpell(SPELL_DARKNESS) ||
//       GetHasSpell(71) || // Greater shadow conjuration
//       GetHasSpell(SPELL_IDENTIFY) ||
//       GetHasSpell(SPELL_KNOCK) ||
       GetHasSpell(SPELL_LIGHT) ||
       GetHasSpell(SPELL_POLYMORPH_SELF) ||
//       GetHasSpell(158) || // Shades
//       GetHasSpell(159) || // Shadow conjuration
       GetHasSpell(SPELL_SHAPECHANGE) ||
       GetHasSpell(321) || // Protection...
       GetHasSpell(322) || // Magic circle...
       GetHasSpell(323) || // Aura...
//       GetHasSpell(SPELL_LEGEND_LORE) ||
//       GetHasSpell(SPELL_FIND_TRAPS) ||
       GetHasSpell(SPELL_CONTINUAL_FLAME) ||
//       GetHasSpell(SPELL_ONE_WITH_THE_LAND) ||
//       GetHasSpell(SPELL_CAMOFLAGE) ||
       GetHasSpell(SPELL_BLOOD_FRENZY) ||
//       GetHasSpell(SPELL_AMPLIFY) ||
       GetHasSpell(SPELL_ETHEREALNESS) ||
       GetHasSpell(SPELL_DIVINE_SHIELD) ||
       GetHasSpell(SPELL_DIVINE_MIGHT) ||
       // Added in again 18th nov
       GetHasSpell(SPELL_INFLICT_SERIOUS_WOUNDS) ||
       GetHasSpell(SPELL_INFLICT_MODERATE_WOUNDS) ||
       GetHasSpell(SPELL_INFLICT_MINOR_WOUNDS) ||
       GetHasSpell(SPELL_INFLICT_LIGHT_WOUNDS) ||
       // Feats that will be cast in the spell list.
       // MOST are under talents anyway, these are ones which are not
       GetHasFeat(FEAT_PRESTIGE_DARKNESS))
    {
        SetSpawnInCondition(AI_VALID_OTHER_SPELL, AI_VALID_SPELLS);
        SetSpawnInCondition(AI_VALID_ANY_SPELL, AI_VALID_SPELLS);
    }
    // SPELL_GREATER_RESTORATION - Ability Decrease, AC decrease, Attack decrease,
    //  Damage Decrease, Damage Immunity Decrease, Saving Throw Decrease, Spell
    //  resistance Decrease, Skill decrease, Blindness, Deaf, Curse, Disease, Poison,
    //  Charmed, Dominated, Dazed, Confused, Frightened, Negative level, Paralyze,
    //  Slow, Stunned.
    // SPELL_FREEDOM - Paralyze, Entangle, Slow, Movement speed decrease. (+Immunity!)
    // SPELL_RESTORATION - Ability Decrease, AC decrease, Attack Decrease,
    //  Damage Decrease, Damage Immunity Decrease, Saving Throw Decrease,
    //  Spell Resistance Decrease, Skill Decrease, Blindess, Deaf, Paralyze, Negative level
    // SPELL_REMOVE_BLINDNESS_AND_DEAFNESS - Blindess, Deaf.
    // SPELL_NEUTRALIZE_POISON - Poison
    // SPELL_REMOVE_DISEASE - Disease
    // SPELL_REMOVE_CURSE - Curse
    // SPELL_LESSER_RESTORATION - Ability Decrease, AC decrease, Attack Decrease,
    // Cure condition spells! :-)
    if(GetHasSpell(SPELL_GREATER_RESTORATION) || GetHasSpell(SPELL_FREEDOM_OF_MOVEMENT) ||
       GetHasSpell(SPELL_RESTORATION) || GetHasSpell(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS) ||
       GetHasSpell(SPELL_NEUTRALIZE_POISON) || GetHasSpell(SPELL_REMOVE_DISEASE) ||
       GetHasSpell(SPELL_REMOVE_CURSE) || GetHasSpell(SPELL_LESSER_RESTORATION) ||
       GetHasSpell(SPELL_STONE_TO_FLESH))
    {
        SetSpawnInCondition(AI_VALID_CURE_CONDITION_SPELLS, AI_VALID_SPELLS);
    }
}

// This will make the visual effect passed play INSTANTLY at the creatures location.
// * iVFX - The visual effect constant number
void AI_SpawnInInstantVisual(int iVFX)
{
    // Beta 3 change: Made to at location.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT,
                          EffectVisualEffect(iVFX),
                          GetLocation(OBJECT_SELF));
}
// This will make the visual effect passed play PERMAMENTLY.
// * If a VFX is -1, it is ignored.
// * iVFX1-4 - The visual effect constant number
// NOTE: They will be made to be SUPERNATUAL, so are not dispelled!
void AI_SpawnInPermamentVisual(int iVFX)
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT,
                        SupernaturalEffect(EffectVisualEffect(iVFX)),
                        OBJECT_SELF);
}
// This will set the MAXIMUM and MINIMUM targets to pass this stage (under sName)
// of the targeting system. IE:
// - If we set it to min of 5, max of 10, for AC, if we cancled 5 targets on having
//   AC higher then wanted, we will take the highest 5 minimum.
//   If there are over 10, we take a max of 10 to choose from.
// * iType - must be TARGET_HIGHER or TARGET_LOWER. Defaults to the lowest, so it
//           targets the lowest value for sName.
void AI_SetAITargetingValues(string sName, int iType, int iMinimum, int iMaximum)
{
    // Error checking
    if((iType == TARGET_HIGHER || iType == TARGET_LOWER) &&
       iMinimum >= i1 && iMaximum >= i1 && iMaximum >= iMinimum)
    {
        // Set the type to sName.
        // - It is TARGET_HIGHER (1) or TARGET_LOWER (0).
        SetAIInteger(sName, iType);

        // Minimum amount of targets for this?
        SetAIInteger(sName + MINIMUM, iMinimum);

        // Maximum targets for this?
        SetAIInteger(sName + MAXIMUM, iMaximum);
    }
}

// Sets we are a Beholder and use Ray attacks, and Animagic Ray.
void SetBeholderAI()
{
    // 1 = beholder
    SetAIInteger(AI_SPECIAL_AI, i1);
}
// Set we are a mindflayer, and uses some special AI for them.
void SetMindflayerAI()
{
    // 2 = mindflayer
    SetAIInteger(AI_SPECIAL_AI, i2);
}

// This will set a spell trigger up. Under cirtain conditions, spells are released
// and cast on the caster.
// Once fired, a spell trigger is only reset by resting.
// * sType - is specifically:
//   SPELLTRIGGER_DAMAGED_AT_PERCENT  - When damaged, the trigger fires. Use iValue for the %. One at a time is fired.
//   SPELLTRIGGER_IMMOBILE            - Fired when held/paralyzed/sleeping ETC. One at a time is fired.
//   SPELLTRIGGER_NOT_GOT_FIRST_SPELL - Makes sure !GetHasSpellEffect(iSpell1) already,
//                                  then fires. Checks all in this category each round.
//   SPELLTRIGGER_START_OF_COMBAT     - All these are all fired at the start of combat.
// * iNumber - can be 1-9, in sequential order of when you want them to fire.
// * iValue - is only required with DAMAGED_AT_PERCENT. Only the first one set is used.
// * iSpellX - Cannot be 0. It should only really be defensive spells.
void SetSpellTrigger(string sType, int iValue, int iNumber, int iSpell1, int iSpell2 = 0, int iSpell3 = 0, int iSpell4 = 0, int iSpell5 = 0, int iSpell6 = 0, int iSpell7 = 0, int iSpell8 = 0, int iSpell9 = 0)
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
    int iSize = i1;
    string sTotalID = sType + IntToString(iNumber);

    SetLocalInt(oTrigger, sTotalID + "1", iSpell1);
    if(iSpell2 != FALSE)
    {   iSize = 2;
        SetLocalInt(oTrigger, sTotalID + "2", iSpell2);    }
    if(iSpell3 != FALSE)
    {   iSize = 3;
        SetLocalInt(oTrigger, sTotalID + "3", iSpell3);    }
    if(iSpell4 != FALSE)
    {   iSize = 4;
        SetLocalInt(oTrigger, sTotalID + "4", iSpell4);    }
    if(iSpell5 != FALSE)
    {   iSize = 5;
        SetLocalInt(oTrigger, sTotalID + "5", iSpell5);    }
    if(iSpell6 != FALSE)
    {   iSize = 6;
        SetLocalInt(oTrigger, sTotalID + "6", iSpell6);    }
    if(iSpell7 != FALSE)
    {   iSize = 7;
        SetLocalInt(oTrigger, sTotalID + "7", iSpell7);    }
    if(iSpell8 != FALSE)
    {   iSize = 8;
        SetLocalInt(oTrigger, sTotalID + "8", iSpell8);    }
    if(iSpell9 != FALSE)
    {   iSize = 9;
        SetLocalInt(oTrigger, sTotalID + "9", iSpell9);    }

    // Set final sizes ETC.
    SetLocalInt(oTrigger, MAXINT_ + sTotalID, iSize);
    SetLocalInt(oTrigger, sTotalID + USED, FALSE);

    // Check value
    if(iValue > GetLocalInt(oTrigger, VALUE + sType))
    {
        SetLocalInt(oTrigger, VALUE + sType, iValue);
    }

    // Set how many spell triggers we have too
    if(iNumber > GetLocalInt(oTrigger, MAXIMUM + sType))
    {
        SetLocalInt(oTrigger, MAXIMUM + sType, iNumber);
    }
}
// Debug: To compile this script, uncomment all of the below.
/* - Add two "/"'s at the start of this line
//void main()
//{
//    return;
//}
//*/

//:://////////////////////////////////////////////////
//:: X0_CH_HEN_HEART
/*

  OnHeartbeat event handler for henchmen/associates.

 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/05/2003
//:://////////////////////////////////////////////////
#include "X0_INC_HENAI"
#include "inc_hai_generic"
#include "inc_hai_act"
#include "inc_hai"
#include "inc_hai_assoc"

void DoBanter()
{
    if (GetIsDead(OBJECT_SELF) || GetIsInCombat(OBJECT_SELF) || IsInConversation(OBJECT_SELF) || GetIsFighting(OBJECT_SELF) || GetIsResting(OBJECT_SELF)) return;

    ExecuteScript("hen_banter", OBJECT_SELF);
}

void TestItemProperties()
{
    Jug_Debug(GetName(OBJECT_SELF) + " checking properties");
    int i;
    itemproperty oProp;

    for (i = 0; i < NUM_INVENTORY_SLOTS; i++)
    {
        object oItem = GetItemInSlot(i, OBJECT_SELF);

        if (GetIsObjectValid(oItem))
        {
            Jug_Debug("Checking item slot " + IntToString(i));
            oProp = GetFirstItemProperty(oItem);
            while (GetIsItemPropertyValid(oProp))
            {

                Jug_Debug("prop type " + IntToString(GetItemPropertyType(oProp)) + " duration " + IntToString(GetItemPropertyDurationType(oProp))  + " sub type " + IntToString(GetItemPropertySubType(oProp)) + " cost table " + IntToString(GetItemPropertyCostTable(oProp)) + " cost table value " + IntToString(GetItemPropertyCostTableValue(oProp)));

                oProp = GetNextItemProperty(oItem);
            }

        }
    }
}


int FindCategoryBest(object oTarget, int nCategory, int nCurSpellCount)
{
// really want arrays
    int spell1, spell2, spell3;
    int spell1Repeat, spell2Repeat, spell3Repeat;
    int spell1Feat, spell2Feat, spell3Feat;
    int spellsFound;

    Jug_Debug(GetName(OBJECT_SELF) + " searching category " + IntToString(nCategory));
    int nTry;

    while (nTry < 10)
    {
        talent tBest = GetCreatureTalentRandom(nCategory, oTarget);
        if(!GetIsTalentValid(tBest))
        {
            break;
        }

        int nNewSpellID = GetIdFromTalent(tBest);
        int nType = GetTypeFromTalent(tBest);

//        Jug_Debug(GetName(OBJECT_SELF) + " test talent " + IntToString(nType) + " " + IntToString(nNewSpellID));

        if (spellsFound == 0)
        {
            Jug_Debug(GetName(OBJECT_SELF) + " found talent " + IntToString(nType) + " " + IntToString(nNewSpellID));
            spell1 = nNewSpellID;
            spell1Feat = nType;
            spellsFound ++;
        }
        else if (spellsFound == 1)
        {
            if (spell1 == nNewSpellID && spell1Feat == nType)
            {
                spell1Repeat ++;
                if (spell1Repeat > 2)
                {
                    break;
                }
            }
            else
            {
                Jug_Debug(GetName(OBJECT_SELF) + " found talent " + IntToString(nType) + " " + IntToString(nNewSpellID));
                spell2 = nNewSpellID;
                spell2Feat = nType;
                spellsFound ++;
            }
        }
        else if (spellsFound == 2)
        {
            if (spell1 == nNewSpellID && spell1Feat == nType)
            {
                spell1Repeat ++;
                if (spell1Repeat > 2)
                {
                    break;
                }
            }
            else if (spell2 == nNewSpellID && spell2Feat == nType)
            {
                spell2Repeat ++;
                if (spell2Repeat > 2)
                {
                    break;
                }
            }
            else
            {
                Jug_Debug(GetName(OBJECT_SELF) + " found talent " + IntToString(nType) + " " + IntToString(nNewSpellID));
                spell3 = nNewSpellID;
                spell3Feat = nType;
                spellsFound ++;
            }
            // at most three
            break;
        }
        nTry ++;
    }
    return spellsFound;
}


void TestSpells()
{
//    if (!GetHasEffect(EFFECT_TYPE_ABILITY_DECREASE))
//    {
//        effect eDrain = EffectAbilityDecrease(ABILITY_CHARISMA, 10);
//        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDrain, OBJECT_SELF);
//    }
//    RemoveEffects(OBJECT_SELF);
    Jug_Debug(GetName(OBJECT_SELF) + " has 6 spell " + IntToString(GetHasSpell(SPELL_CHAIN_LIGHTNING)));
    Jug_Debug(GetName(OBJECT_SELF) + " has 5 spell " + IntToString(GetHasSpell(SPELL_CONE_OF_COLD)));
    Jug_Debug(GetName(OBJECT_SELF) + " has 4 spell " + IntToString(GetHasSpell(SPELL_ICE_STORM)));
    Jug_Debug(GetName(OBJECT_SELF) + " has 3 spell " + IntToString(GetHasSpell(SPELL_FIREBALL)));
    Jug_Debug(GetName(OBJECT_SELF) + " has 2 spell " + IntToString(GetHasSpell(SPELL_BULLS_STRENGTH)));
    Jug_Debug(GetName(OBJECT_SELF) + " has 1 spell " + IntToString(GetHasSpell(SPELL_BURNING_HANDS)));
    Jug_Debug(GetName(OBJECT_SELF) + " has 0 spell " + IntToString(GetHasSpell(SPELL_DAZE)));
}


void TestSpells2()
{
    Jug_Debug(GetName(OBJECT_SELF) + " has 4 spell " + IntToString(GetHasSpell(SPELL_CURE_CRITICAL_WOUNDS)) + " check spell id " +  IntToString(GetCreatureHasTalent(TalentSpell(SPELL_CURE_CRITICAL_WOUNDS))));
    Jug_Debug(GetName(OBJECT_SELF) + " has 3 spell " + IntToString(GetHasSpell(SPELL_CURE_SERIOUS_WOUNDS)) + " check spell id " +  IntToString(GetCreatureHasTalent(TalentSpell(SPELL_CURE_SERIOUS_WOUNDS))));
    Jug_Debug(GetName(OBJECT_SELF) + " has 2 spell " + IntToString(GetHasSpell(SPELL_CURE_MODERATE_WOUNDS)) + " check spell id " +  IntToString(GetCreatureHasTalent(TalentSpell(SPELL_CURE_MODERATE_WOUNDS))));
    Jug_Debug(GetName(OBJECT_SELF) + " has 1 spell " + IntToString(GetHasSpell(SPELL_CURE_LIGHT_WOUNDS)) + " check spell id " +  IntToString(GetCreatureHasTalent(TalentSpell(SPELL_CURE_LIGHT_WOUNDS))));
    Jug_Debug(GetName(OBJECT_SELF) + " has 0 spell " + IntToString(GetHasSpell(SPELL_CURE_MINOR_WOUNDS)) + " check spell id " +  IntToString(GetCreatureHasTalent(TalentSpell(SPELL_CURE_MINOR_WOUNDS))));
}

void TestSpells3()
{
    Jug_Debug(GetName(OBJECT_SELF) + " has prot vs evil " + IntToString(GetHasSpell(SPELL_PROTECTION_FROM_EVIL)));
    Jug_Debug(GetName(OBJECT_SELF) + " has prot vs good " + IntToString(GetHasSpell(SPELL_PROTECTION_FROM_GOOD)));
    Jug_Debug(GetName(OBJECT_SELF) + " has propt vs align " + IntToString(GetHasSpell(321)));
    Jug_Debug(GetName(OBJECT_SELF) + " has gate " + IntToString(GetHasSpell(SPELL_GATE)));
    Jug_Debug(GetName(OBJECT_SELF) + " check spell id " +  IntToString(GetCreatureHasTalent(TalentSpell(SPELL_PROTECTION_FROM_EVIL))));
    Jug_Debug(GetName(OBJECT_SELF) + " check main spell id " + IntToString(GetCreatureHasTalent(TalentSpell(321))));
}


void GetBestItemSpells()
{
    object oTarget = GetMaster();
    if (!GetIsObjectValid(oTarget))
    {
        return;
    }
    oTarget = OBJECT_SELF;

    // check if already silenced
    int nAlreadySilenced = GetHasEffect(EFFECT_TYPE_SILENCE);

    if (!nAlreadySilenced)
    {
//        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectSilence(), oTarget);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneImmobilize(), oTarget);
         // ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectParalyze(), OBJECT_SELF);
    }

    int nStep;
    for (nStep = 0; nStep <= 22; nStep++)
    {
        FindCategoryBest(oTarget, nStep, 0);
    }

    if (!nAlreadySilenced)
    {
        effect eSilence = GetFirstEffect(oTarget);
        while(GetIsEffectValid(eSilence))
        {
            if(GetEffectType(eSilence) == EFFECT_TYPE_CUTSCENEIMMOBILIZE)
            {
                RemoveEffect(oTarget, eSilence);
       //         break;
            }
            eSilence = GetNextEffect(oTarget);
        }
    }
}


void main()
{
    string sScript = GetLocalString(OBJECT_SELF, "heartbeat_script");
    if (sScript != "") ExecuteScript(sScript);

    if (GetIsObjectValid(GetMaster(OBJECT_SELF)) && GetStringLeft(GetResRef(OBJECT_SELF), 3) == "hen")
    {
        int nBanter = GetLocalInt(OBJECT_SELF, "banter");

        if (nBanter >= 100)
        {
            DelayCommand(IntToFloat(d20())+IntToFloat(d10())/10.0, DoBanter());
            DeleteLocalInt(OBJECT_SELF, "banter");
        }
        else
        {
            SetLocalInt(OBJECT_SELF, "banter", nBanter+d4());
        }
    }

//    Jug_Debug("*****" + GetName(OBJECT_SELF) + " heartbeat " + IntToString(GetCurrentAction()) + " busy " + IntToString(GetAssociateState(NW_ASC_IS_BUSY)));

   // dying script removed -pok

    //    GetBestItemSpells();
//    if (GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR,PLAYER_CHAR_IS_PC, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION,  PERCEPTION_HEARD)))
//    {
//        Jug_Debug("*****" + GetName(OBJECT_SELF) + " heartbeat action " + IntToString(GetCurrentAction()));
//    }

//    if (GetIsObjectValid(GetMaster()))
//    {
//        TestItemProperties();
//        Jug_Debug(GetName(OBJECT_SELF) + " challenge rating is " + FloatToString(GetChallengeRating(OBJECT_SELF)));
//        Jug_Debug(GetName(GetMaster()) + " challenge rating is " + FloatToString(GetChallengeRating(GetMaster())));
//    }
//    TestSpells();
//    TestSpells2();
//    TestSpells3();

    DeleteLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE);

    object oRealMaster = GetRealMaster();
        // destory self if pseudo summons and master not valid
    if (GetLocalInt(OBJECT_SELF, sHenchPseudoSummon))
    {
        oRealMaster = GetLocalObject(OBJECT_SELF, sHenchPseudoSummon);
        if (!GetIsObjectValid(oRealMaster))
        {
            DestroyObject(OBJECT_SELF, 0.1);
            ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(OBJECT_SELF));
            return;
        }
    }

    // GZ: Fallback for timing issue sometimes preventing epic summoned creatures from leveling up to their master's level.
    // There is a timing issue with the GetMaster() function not returning the fof a creature
    // immediately after spawn. Some code which might appear to make no sense has been added
    // to the nw_ch_ac1 and x2_inc_summon files to work around this
    // This code is only run at the first hearbeat
    /*
    int nLevel = SSMGetSummonFailedLevelUp(OBJECT_SELF);
    if (nLevel != 0)
    {
        int nRet;
        if (nLevel == -1) // special shadowlord treatment
        {
            SSMScaleEpicShadowLord(OBJECT_SELF);
        }
        else if  (nLevel == -2)
        {
            SSMScaleEpicFiendishServant(OBJECT_SELF);
        }
        else
        {
            nRet = SSMLevelUpCreature(OBJECT_SELF, nLevel, CLASS_TYPE_INVALID);
            if (nRet == FALSE)
            {
                WriteTimestampedLogEntry("WARNING - nw_ch_ac1:: could not level up " + GetTag(OBJECT_SELF) + "!");
            }
        }

        // regardless if the actual levelup worked, we give up here, because we do not
        // want to run through this script more than once.
        SSMSetSummonLevelUpOK(OBJECT_SELF);
    }
    */
    // Check if concentration is required to maintain this creature
    //X2DoBreakConcentrationCheck();

    // * if I am dominated, ask for some help
    // TK removed SendForHelp
//    if (GetHasEffect(EFFECT_TYPE_DOMINATED, OBJECT_SELF) == TRUE && GetIsEncounterCreature(OBJECT_SELF) == FALSE)
//    {
//        SendForHelp();
//    }

        // restore associate settings
    HenchGetDefSettings();

    if(GetAssociateState(NW_ASC_IS_BUSY))
    {
        return;
    }
    int iAmNotDoingAnything = GetIAmNotDoingAnything();
    if (!iAmNotDoingAnything)
    {
        return;
    }
    if (!GetIsObjectValid(oRealMaster))
    {
        return;
    }

    if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND))
    {
        if (HenchGetIsEnemyPerceived())
        {
            HenchDetermineCombatRound();
            return;
        }
        if (GetLocalInt(OBJECT_SELF, sHenchLastHeardOrSeen))
        {
            // continue to move to target
            MoveToLastSeenOrHeard(FALSE);
            return;
        }
    }

    if ((GetLocalObject(OBJECT_SELF,"NW_L_FORMERMASTER") != OBJECT_INVALID)
        && (GetLocalInt(OBJECT_SELF, "haveCheckedFM") != 1))
    {
        // Auldar: For a little OnHeartbeat efficiency, I'll set a localint so we don't
        // keep checking stealth mode etc. This will be cleared in NW_CH_JOIN, as will
        // the LocalObject for NW_L_FORMERMASTER.
        // A little quirk with this behaviour - the ActionUseSkill's do not execute until the henchman rejoins
        // however if the player re-loads, or leaves the area and returns, the henchman will no longer be in stealth etc.
        // I couldn't find any way around that odd behaviour, but this works for the most part.
        SetLocalInt(OBJECT_SELF, "haveCheckedFM", 1);
        SetAssociateState(NW_ASC_AGGRESSIVE_SEARCH, FALSE);
        SetLocalInt(OBJECT_SELF, sHenchStealthMode, 0);
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, FALSE);
        SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, FALSE);
    }

    // Check to see if should re-enter stealth mode
    int nStealth = GetLocalInt(GetTopAssociate(), sHenchStealthMode);
    if (nStealth == 1 || nStealth == 2)
    {
        if(!GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH))
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
        }
    }
    else
    {
        if(!GetActionMode(oRealMaster, ACTION_MODE_STEALTH))
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, FALSE);
        }
    }

    CleanCombatVars();

    if (GetLocalInt(OBJECT_SELF, henchHealCountStr))
    {
        ExecuteScript("hen_heal", OBJECT_SELF);
        return;
    }
    if (GetLocalInt(OBJECT_SELF, henchBuffCountStr))
    {
        ActionDoCommand(ActionWait(2.0));
        ActionDoCommand(ExecuteScript("hen_enhance", OBJECT_SELF));
        return;
    }

    if (HenchCheckArea())
    {
        return;
    }
        // Pausanias: Hench tends to get stuck on follow.
    if (GetCurrentAction(OBJECT_SELF) == ACTION_FOLLOW)
    {
        if (GetDistanceToObject(oRealMaster) >= 2.2 &&
            GetAssociateState(NW_ASC_DISTANCE_2_METERS)) return;
        if (GetDistanceToObject(oRealMaster) >= 4.2 &&
            GetAssociateState(NW_ASC_DISTANCE_4_METERS)) return;
        if (GetDistanceToObject(oRealMaster) >= 6.2 &&
            GetAssociateState(NW_ASC_DISTANCE_6_METERS)) return;
        ClearAllActions();
    }

    if (GetLocalInt(OBJECT_SELF,"SwitchedToMelee") &&
        GetAssociateState(NW_ASC_USE_RANGED_WEAPON))
    {
        ClearAllActions();
        ClearWeaponStates();
        HenchEquipDefaultWeapons(OBJECT_SELF, TRUE);
        return;
    }

    int bIsScouting = GetLocalInt(OBJECT_SELF, sHenchScoutingFlag);
    if (bIsScouting)
    {
        if (GetDistanceToObject(oRealMaster) < 6.0)
        {
            SpeakString(sHenchGetOutofWay);
        }
        object oScoutTarget = GetLocalObject(OBJECT_SELF, sHenchScoutTarget);
        if (GetDistanceBetween(oScoutTarget, oRealMaster) > henchMaxScoutDistance)
        {
            DeleteLocalInt(OBJECT_SELF, sHenchScoutingFlag);
            bIsScouting = FALSE;
        }
        else
        {
            if (CheckStealth() && !GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH))
            {
                SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
            }
            ActionMoveToObject(oScoutTarget, FALSE, 1.0);
        }
    }

    if(!bIsScouting && !GetAssociateState(NW_ASC_MODE_STAND_GROUND) &&
        (GetAssociateState(NW_ASC_HAVE_MASTER) && !GetIsFighting(OBJECT_SELF) &&
        GetDistanceToObject(oRealMaster) > GetFollowDistance()))
    {
        ClearAllActions();
        ActionForceFollowObject(oRealMaster, GetFollowDistance());
    }

    if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_HEARTBEAT));
    }
}





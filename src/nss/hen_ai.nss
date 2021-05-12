#include "inc_hai_heal"
#include "inc_hai_spells"
#include "inc_hai"
#include "inc_hai_act"


// Threshold challenge rating for buff spells
const float PAUSANIAS_CHALLENGE_THRESHOLD = -2.0;
const float PAUSANIAS_FAMILIAR_THRESHOLD = -2.0;
const float PAUSANIAS_DISTANCE_THRESHOLD = 5.0;



void main()
{
    object oIntruder = GetLocalObject(OBJECT_SELF, HENCH_AI_SCRIPT_INTRUDER_OBJ);
    int bForce = GetLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_FORCE);

    int curIntrudeCount = GetLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE);
    ++curIntrudeCount;
    SetLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE, curIntrudeCount);

        // destroy self if pseudo summons and master not valid
    if (GetLocalInt(OBJECT_SELF, sHenchPseudoSummon) && !GetIsObjectValid(GetLocalObject(OBJECT_SELF, sHenchPseudoSummon)))
    {
        DestroyObject(OBJECT_SELF, 0.1);
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(OBJECT_SELF));
        return;
    }

//    Jug_Debug(GetName(OBJECT_SELF) + " starting det combat int = " + GetName(oIntruder) + " action " + IntToString(GetCurrentAction()));

    int iHP = GetPercentageHPLoss(OBJECT_SELF);
    int iCheckHealing = iHP < 50;

    SetLocalInt(OBJECT_SELF, HENCH_HEAL_SELF_STATE, iCheckHealing ? HENCH_HEAL_SELF_CANT : HENCH_HEAL_SELF_WAIT);

    int nCurAction = GetCurrentAction();

    // ----------------------------------------------------------------------------------------
    // Oct 06/2003 - Georg Zoeller,
    // Fix for ActionRandomWalk blocking the action queue under certain circumstances
    // ----------------------------------------------------------------------------------------
    if (nCurAction == ACTION_RANDOMWALK)
    {
        ClearAllActions();
    }

    // Auldar: Don't want anything to disturb the Taunt attempt.
    // dying condition removed - pok
    if(GetAssociateState(NW_ASC_IS_BUSY) || nCurAction == ACTION_TAUNT || nCurAction == ACTION_HEAL || nCurAction == ACTION_ANIMALEMPATHY)
    {
        DeleteLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE);
        return;
    }

    // Finish casting your spells if you've started.
    if ((nCurAction == ACTION_CASTSPELL) || (nCurAction == ACTION_ITEMCASTSPELL))
    {
        // cancel if target has died
        object oLastSpellTarget = GetLocalObject(OBJECT_SELF, sLastSpellTargetObject);
        if (GetIsObjectValid(oLastSpellTarget) &&
            (GetCurrentHitPoints(oLastSpellTarget) > HENCH_BLEED_NEGHPS))
        {
            return;
        }
    }

    // MODIFIED FEBRUARY 13 2003
    // The associate will not engage in battle if in Stand Ground mode unless
    // he takes damage
    if(GetAssociateState(NW_ASC_MODE_STAND_GROUND) && !GetIsObjectValid(GetLastHostileActor()))
    {
        DeleteLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE);
        return;
    }

    int iEffectsOnSelf = 0;

    effect eCheck = GetFirstEffect(OBJECT_SELF);
    while (GetIsEffectValid(eCheck))
    {
        switch(GetEffectType(eCheck))
        {
    // Pausanias: sanity check for various effects
        case EFFECT_TYPE_PARALYZE:
        case EFFECT_TYPE_STUNNED:
        case EFFECT_TYPE_FRIGHTENED:
        case EFFECT_TYPE_SLEEP:
        case EFFECT_TYPE_PETRIFY:
        case EFFECT_TYPE_TURNED:
        // TODO handle daze - can walk away
        case EFFECT_TYPE_DAZED:
            DeleteLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE);
            DeleteLocalObject(OBJECT_SELF, sHenchLastTarget);
            return;
        case EFFECT_TYPE_ETHEREAL:
            iEffectsOnSelf |= HENCH_HAS_ETHEREAL_EFFECT;
            break;
        case EFFECT_TYPE_CONCEALMENT:
            iEffectsOnSelf |= HENCH_HAS_CONCEALMENT_EFFECT;
            break;
        case EFFECT_TYPE_INVISIBILITY:
        case EFFECT_TYPE_IMPROVEDINVISIBILITY:
            iEffectsOnSelf |= HENCH_HAS_INVISIBILITY_EFFECT;
            break;
        case EFFECT_TYPE_SANCTUARY:
            iEffectsOnSelf |= HENCH_HAS_SANTUARY_EFFECT;
            break;
        case EFFECT_TYPE_CONFUSED:
            iEffectsOnSelf |= HENCH_HAS_CONFUSED_EFFECT;
            break;
        case EFFECT_TYPE_CHARMED:
            iEffectsOnSelf |= HENCH_HAS_CHARMED_EFFECT;
            break;
        case EFFECT_TYPE_POLYMORPH:
            iEffectsOnSelf |= HENCH_HAS_POLYMORPH_EFFECT;
            break;
        case EFFECT_TYPE_HASTE:
            iEffectsOnSelf |= HENCH_HAS_HASTE_EFFECT;
            break;
        case EFFECT_TYPE_TIMESTOP:
            iEffectsOnSelf |= HENCH_HAS_TIMESTOP_EFFECT;
            break;
        }
        eCheck = GetNextEffect(OBJECT_SELF);
    }

    // reset action queue
    if (nCurAction != ACTION_INVALID)
    {
        ClearAllActions();
    }

    object oMaster = GetMaster();
    object oRealMaster = GetRealMaster();
    int iAmMonster = GetIsEnemy(GetFirstPC());
    int iHaveMaster = !iAmMonster && GetIsObjectValid(oMaster);

    int iAmHenchman,iAmFamiliar,iAmCompanion;
    if (iHaveMaster)
    {
        int nAssocType = GetAssociateType(OBJECT_SELF);
        iAmHenchman = nAssocType == ASSOCIATE_TYPE_HENCHMAN;
        iAmFamiliar = nAssocType == ASSOCIATE_TYPE_FAMILIAR;
        iAmCompanion = nAssocType == ASSOCIATE_TYPE_ANIMALCOMPANION;
    }

    //if (!iAmMonster)
    //{
        HenchGetDefSettings();
    //}

    object oClosestSeen;
    object oClosestHeard;
    object oClosestNonActive;
    object oClosestSummoned;

    int curCount = 1;
    while (TRUE)
    {
        oClosestSeen = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                            OBJECT_SELF, curCount, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN,
                            CREATURE_TYPE_IS_ALIVE, TRUE);
        if (!GetIsObjectValid(oClosestSeen))
        {
            break;
        }
        if (GetPlotFlag(oClosestSeen))
        {
            // ignore plot creatures
        }
        else if (GetLocalInt(oClosestSeen, sHenchRunningAway) || GetIsDisabled(oClosestSeen))
        {
            if (!GetIsObjectValid(oClosestNonActive))
            {
                oClosestNonActive = oClosestSeen;
            }
        }
        else if (GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) > 9 && !GetIsObjectValid(oClosestSummoned) &&
            GetAssociateType(oClosestSeen) != ASSOCIATE_TYPE_HENCHMAN &&
            GetAssociateType(oClosestSeen) != ASSOCIATE_TYPE_NONE)
        {
            oClosestSummoned = oClosestSeen;
        }
        // never consider dying henchman
        /*
        else if (!GetAssociateState(NW_ASC_MODE_DYING, oClosestSeen))
        {
            break;
        }
        */
        curCount++;
    }

    curCount = 1;
    while (TRUE)
    {
        oClosestHeard = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                            OBJECT_SELF, curCount, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD_AND_NOT_SEEN,
                            CREATURE_TYPE_IS_ALIVE, TRUE);
        if (!GetIsObjectValid(oClosestHeard))
        {
            break;
        }
        if (GetPlotFlag(oClosestHeard))
        {
            // ignore plot creatures
        }
        else if (GetLocalInt(oClosestHeard, sHenchRunningAway) || GetIsDisabled(oClosestHeard))
        {
            if (!GetIsObjectValid(oClosestNonActive))
            {
                oClosestNonActive = oClosestHeard;
            }
        }
        /*
        // never consider dying henchman
        else if (!GetAssociateState(NW_ASC_MODE_DYING, oClosestHeard))
        {
            break;
        }
        */
        curCount++;
    }
    // find dying creatures to finish off
    if (iAmMonster && !GetIsObjectValid(oClosestNonActive))
    {
        curCount = 1;
        while (1)
        {
            oClosestNonActive = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF,
                curCount, CREATURE_TYPE_IS_ALIVE, FALSE);
            if (!GetIsObjectValid(oClosestNonActive))
            {
                break;
            }
            if (GetPlotFlag(oClosestNonActive))
            {
                // ignore plot creatures
            }
            else if (GetDistanceToObject(oClosestNonActive) >= 30.0)
            {
                oClosestNonActive = OBJECT_INVALID;
                break;
            }
            if (GetCurrentHitPoints(oClosestNonActive) > HENCH_BLEED_NEGHPS)
            {
                break;
            }
            curCount++;
        }
    }

    float fDistance = 1000.0;
    object oClosestSeenOrHeard;
    if (GetIsObjectValid(oClosestSeen))
    {
        oClosestSeenOrHeard = oClosestSeen;
        fDistance = GetDistanceToObject(oClosestSeen);
    }
    if (GetIsObjectValid(oClosestSummoned))
    {
        float fTestDistance = GetDistanceToObject(oClosestSummoned);
        if (fTestDistance < fDistance)
        {
            oClosestSeenOrHeard = oClosestSummoned;
            fDistance = fTestDistance;
        }
    }
    if (GetIsObjectValid(oClosestHeard))
    {
        float fTestDistance = GetDistanceToObject(oClosestHeard);
        if (fTestDistance < fDistance)
        {
            oClosestSeenOrHeard = oClosestHeard;
            fDistance = fTestDistance;
        }
    }

    int iMeleeAttackers = fDistance <= 5.0 &&
        (fabs(GetPosition(OBJECT_SELF).z - GetPosition(oClosestSeenOrHeard).z ) < 2.0) &&
        // no one can attack while in time stop
        !(iEffectsOnSelf & HENCH_HAS_TIMESTOP_EFFECT);

    object oFriend = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                        OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN,
                        CREATURE_TYPE_IS_ALIVE, TRUE);

        // this is the first target, use
    object oLastTarget = GetLocalObject(OBJECT_SELF, sHenchLastTarget);

    if (GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) < 7)
    {
        oLastTarget = OBJECT_INVALID;
    }
    object oNotHeardOrSeen = OBJECT_INVALID;

    if(!GetIsObjectValid(oLastTarget) ||
        (GetIsDead(oLastTarget) && (GetCurrentHitPoints(oLastTarget) <= HENCH_BLEED_NEGHPS)) ||
        !GetIsEnemy(oLastTarget) ||
        GetLocalInt(oLastTarget, sHenchRunningAway) ||
        GetAssociateState(NW_ASC_MODE_DYING, oLastTarget) ||
        GetPlotFlag(oLastTarget) ||
        GetArea(OBJECT_SELF) != GetArea(oLastTarget) ||
        (!GetObjectSeen(oLastTarget) && (!GetObjectHeard(oLastTarget) || !LineOfSightObject(OBJECT_SELF, oLastTarget))) ||
        GetIsDisabled(oLastTarget))
    {
        oLastTarget = OBJECT_INVALID;
    }

    if(!GetIsObjectValid(oIntruder) ||
        GetIsDead(oIntruder) ||
        GetLocalInt(oIntruder, sHenchRunningAway) ||
        GetAssociateState(NW_ASC_MODE_DYING, oIntruder) ||
        GetPlotFlag(oIntruder) ||
        GetArea(OBJECT_SELF) != GetArea(oIntruder))
    {
        oIntruder = OBJECT_INVALID;
    }
    else if (!GetObjectSeen(oIntruder) && !GetObjectHeard(oIntruder))
    {
    // don't know where intruder is
        oNotHeardOrSeen = oIntruder;
        oIntruder = OBJECT_INVALID;
    }
    // don't remove if it isnt forced - pok
    /*
    if (!bForce)
    {
        oIntruder = OBJECT_INVALID;
    }
    */
    if (iHaveMaster)
    {
           // TODO more checks for allies
        if ((GetMaster(oIntruder) == oMaster) || (GetMaster(oIntruder) == oRealMaster))
        {
            oIntruder = OBJECT_INVALID;
        }
    }

    if (((d2() == 1) && (iEffectsOnSelf & HENCH_HAS_CONFUSED_EFFECT)) ||
        (iEffectsOnSelf & HENCH_HAS_CHARMED_EFFECT))
    {
        if (!GetIsObjectValid(oFriend))
        {
            // just do nothing for this case
            DeleteLocalObject(OBJECT_SELF, sHenchLastTarget);
            return;
        }
        oIntruder = oFriend;
        oLastTarget = OBJECT_INVALID;
    }
    else if (iHaveMaster && oIntruder == oRealMaster)
    {
        if (GetHenchmanOptions(HENCH_HENAI_NOATTACK) & HENCH_HENAI_NOATTACK)
        {
            oIntruder = OBJECT_INVALID;
        }
    }

    // Get all enemies within 40 meters and store them in an array.
    // Auldar: Lets try 25 meters. 40 causes monsters to go too far past the PC
    // Tony K changed - this used to not use seen or heard, used all
    // enemies within a set radius (25)
    if(iAmMonster && !iMeleeAttackers &&
        (GetMonsterOptions(HENCH_MONAI_DISTRIB) & HENCH_MONAI_DISTRIB)
        && !GetIsObjectValid(oIntruder) && !GetIsObjectValid(oLastTarget) &&
        GetIsObjectValid(oClosestSeenOrHeard))
    {
        int perceptionType;
        if (GetIsObjectValid(oClosestSeen) || GetIsObjectValid(oClosestSummoned))
        {
            perceptionType = PERCEPTION_SEEN;
        }
        else
        {
            perceptionType = PERCEPTION_HEARD_AND_NOT_SEEN;
        }
        int iNth = 0;
        int iLoop = 1;
        while (TRUE)
        {
            object oNextTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                                REPUTATION_TYPE_ENEMY, OBJECT_SELF, iLoop,
                                CREATURE_TYPE_PERCEPTION, perceptionType,
                                CREATURE_TYPE_IS_ALIVE, TRUE);
            if (!GetIsObjectValid(oNextTarget) || GetDistanceToObject(oNextTarget) > 25.)
            {
                break;
            }
            ++iLoop;
            if (!GetLocalInt(oNextTarget, sHenchRunningAway) && !GetAssociateState(NW_ASC_MODE_DYING, oNextTarget))
            {
                ++iNth;
                if (Random(iNth) == 0)
                {
                    oIntruder = oNextTarget;
                }
            }
        }
    }

        // Determine the best target
    if (!GetIsObjectValid(oIntruder))
    {
        if (GetIsObjectValid(oLastTarget) && GetDistanceToObject(oLastTarget) <= 5.0)
        {
            if (GetObjectSeen(oLastTarget))
            {
                oIntruder = oLastTarget;
            }
            else if (GetIsObjectValid(oClosestSeen) && GetDistanceToObject(oClosestSeen) <= 5.0)
            {
                oIntruder = oClosestSeen;
            }
            else if (GetIsObjectValid(oClosestSummoned) && GetDistanceToObject(oClosestSummoned) <= 5.0)
            {
                oIntruder = oClosestSummoned;
            }
            else
            {
                oIntruder = oLastTarget;
            }
        }
        else if (GetIsObjectValid(oClosestSeen) && GetDistanceToObject(oClosestSeen) <= 5.0)
        {
            oIntruder = oClosestSeen;
        }
        else if (GetIsObjectValid(oClosestSummoned) && GetDistanceToObject(oClosestSummoned) <= 5.0)
        {
            oIntruder = oClosestSummoned;
        }
        else if (GetIsObjectValid(oClosestHeard) && GetDistanceToObject(oClosestHeard) <= 5.0)
        {
            oIntruder = oClosestHeard;
        }
        else if (GetIsObjectValid(oLastTarget))
        {
            if (GetObjectSeen(oLastTarget))
            {
                oIntruder = oLastTarget;
            }
            else if (GetIsObjectValid(oClosestSeen))
            {
                oIntruder = oClosestSeen;
            }
            else if (GetIsObjectValid(oClosestSummoned))
            {
                oIntruder = oClosestSummoned;
            }
            else
            {
                oIntruder = oLastTarget;
            }
        }
        else if (GetIsObjectValid(oClosestSeen))
        {
            oIntruder = oClosestSeen;
        }
        else if (GetIsObjectValid(oClosestSummoned))
        {
            oIntruder = oClosestSummoned;
        }
        else if (GetIsObjectValid(oClosestHeard))
        {
            oIntruder = oClosestHeard;
        }
        else if (GetIsObjectValid(oClosestNonActive))
        {
            oIntruder = oClosestNonActive;
        }
    }

    object oIntruderSeen;
    if (!GetObjectSeen(oIntruder))
    {
        if (GetIsObjectValid(oClosestSeen))
        {
            oIntruderSeen = oClosestSeen;
        }
        else if (GetIsObjectValid(oClosestSummoned))
        {
            oIntruderSeen = oClosestSummoned;
        }
        else if (GetIsObjectValid(oClosestNonActive) && GetObjectSeen(oClosestNonActive))
        {
            oIntruderSeen = oClosestNonActive;
        }
    }
    else
    {
        oIntruderSeen = oIntruder;
    }

    // Auldar: If we are still in Search mode when we start to attack the enemy, stop searching.
    if (GetIsObjectValid(oIntruderSeen) && GetActionMode(OBJECT_SELF, ACTION_MODE_DETECT))
    {
        SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, FALSE);
    }

    if (iAmMonster)
    {
        // reset scout mode (no wandering enable pursue to open doors)
        SetLocalInt(OBJECT_SELF,"ScoutMode", 0);
    }

    int iSummonHelp = TRUE;
    if (GetLocalInt(OBJECT_SELF, sHenchDontSummon))
    {
        iSummonHelp = FALSE;
    }
    int iUseMagic = GetLocalInt(OBJECT_SELF, "X2_L_STOPCASTING") != 10;

    if (iHaveMaster && !GetIsObjectValid(oIntruder) && !GetIsObjectValid(oNotHeardOrSeen))
    {
//        Jug_Debug(GetName(OBJECT_SELF) + " checking heal count " + IntToString(GetLocalInt(OBJECT_SELF, henchHealCountStr)));
        if (GetLocalInt(OBJECT_SELF, henchHealCountStr))
        {
            ExecuteScript("hen_heal", OBJECT_SELF);
            return;
        }
        if (GetLocalInt(OBJECT_SELF, henchBuffCountStr))
        {
            ExecuteScript("hen_enhance", OBJECT_SELF);
            return;
        }
        if(HenchBashDoorCheck(iEffectsOnSelf & HENCH_HAS_POLYMORPH_EFFECT))
        {
            DeleteLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE);
            return;
        }
    }

    // The following tweaks are implemented via Pausanias' dialog mods.
    int nClass = HenchDetermineClassToUse();
    // Herbivores should escape
   // special combat calls
    if(GetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE) || nClass == CLASS_TYPE_COMMONER)
    {
        HenchTalentHide(iEffectsOnSelf, nGlobalMeleeAttackers);
        if (HenchTalentFlee(oClosestSeenOrHeard)) return;
    }
    if (GetCombatCondition(X0_COMBAT_FLAG_COWARDLY)
        && SpecialTacticsCowardly(oClosestSeenOrHeard))
    {
        return;
    }
        //This check is to see if the master is being attacked and in need of help
    if(GetAssociateState(NW_ASC_HAVE_MASTER))
    {
        if(GetAssociateState(NW_ASC_MODE_DEFEND_MASTER))
        {
//          Jug_Debug(GetName(OBJECT_SELF) + " checking defend master " + GetName(oRealMaster));
            int bFoundTarget = FALSE;
            oIntruder = GetLastHostileActor(oRealMaster);
            if (!GetIsObjectValid(oIntruder) || (GetIsFriend(oIntruder) || GetFactionEqual(oIntruder)))
            {
                oIntruder = GetGoingToBeAttackedBy(oRealMaster);
                if (!GetIsObjectValid(oIntruder) || (GetIsFriend(oIntruder) || GetFactionEqual(oIntruder)))
                {
                    oIntruder = GetLastHostileActor();
                    if(!GetIsObjectValid(oIntruder))
                    {
                        if (GetAssociateState(NW_ASC_USE_RANGED_WEAPON))
                        {
                            if (fDistance > 20.)
                            {
                                DeleteLocalObject(OBJECT_SELF, sHenchLastTarget);
                                return;
                            }
                        }
                        else if (fDistance > 7.0)
                        {
                            DeleteLocalObject(OBJECT_SELF, sHenchLastTarget);
                            return;
                        }
                    }
                    else
                    {
    //                  Jug_Debug(GetName(OBJECT_SELF) + " found enemy of " + GetName(oIntruder));
                        bFoundTarget = TRUE;
                    }
                }
                else
                {
    //              Jug_Debug(GetName(OBJECT_SELF) + " found going to be attacked by " + GetName(oIntruder));
                    bFoundTarget = TRUE;
                }
            }
            else
            {
//              Jug_Debug(GetName(OBJECT_SELF) + " found last hostile master " + GetName(oIntruder));
                bFoundTarget = TRUE;
            }
            if (bFoundTarget)
            {
                if (!GetObjectSeen(oIntruder) && !GetObjectHeard(oIntruder))
                {
                // don't know where intruder is
//                  Jug_Debug("@@@@@@@@@@@@@@" + GetName(OBJECT_SELF) + " setting unseen intruder to " + GetName(oIntruder));
                    oNotHeardOrSeen = oIntruder;
                    oIntruder = OBJECT_INVALID;
                }
                else
                {
                    bForce = TRUE;
                }
            }
        }
    }

    // NEXT: Do not attack if the master told you not to
    if (GetLocalInt(OBJECT_SELF, sHenchDontAttackFlag) &&
        !(iEffectsOnSelf & (HENCH_HAS_CONFUSED_EFFECT | HENCH_HAS_CHARMED_EFFECT)))
    {
        if (iAmMonster)
        {
            DeleteLocalInt(OBJECT_SELF, sHenchDontAttackFlag);
        }
        else
        {
            if (d10() > 7 && !GetLocalInt(OBJECT_SELF, sHenchShouldIAttackMessageGiven) &&
                (GetIsObjectValid(oIntruder) || GetIsObjectValid(oNotHeardOrSeen)))
            {
                if (iAmHenchman)
                    SpeakString(sHenchHenchmanAskAttack);
                else if (iAmFamiliar)
                    SpeakString(sHenchFamiliarAskAttack);
                else if (iAmCompanion)
                    SpeakString("<" + GetName(OBJECT_SELF) + sHenchAnCompAskAttack);
                else
                    SpeakString(sHenchOtherFollow1 + GetName(OBJECT_SELF) + sHenchOtherAskAttack);
                SetLocalInt(OBJECT_SELF, sHenchShouldIAttackMessageGiven, TRUE);
            }
            ActionForceFollowObject(oRealMaster, GetFollowDistance());
            return;
        }
    }

    if (!GetIsObjectValid(oIntruder))
    {
        // henchmen using ranged weapons will not move to unheard and unseen enemies
        if (!bForce && !iAmMonster && GetAssociateState(NW_ASC_USE_RANGED_WEAPON))
        {
            ActionMoveToObject(oRealMaster, TRUE);
            ClearEnemyLocation();
            return;
        }
        else if (GetIsObjectValid(oNotHeardOrSeen))
        {
            SetEnemyLocation(oNotHeardOrSeen);
        }
        if (GetLocalInt(OBJECT_SELF, sHenchLastHeardOrSeen))
        {
            InitializeItemSpells(nClass, iEffectsOnSelf & HENCH_HAS_POLYMORPH_EFFECT, HENCH_INIT_ALL_SPELLS);

            // TODO have hench buff - need to check CR
            if (iUseMagic && iAmMonster && HenchTalentHide(iEffectsOnSelf, nGlobalMeleeAttackers))
            {
            }
            else if (iUseMagic  && iAmMonster && TK_UseBestSpell(OBJECT_INVALID, oNotHeardOrSeen, oFriend,
                FALSE, FALSE, FALSE, iSummonHelp, TRUE, TRUE, TRUE, FALSE, iAmMonster))
            {
            }
            else
            {
                MoveToLastSeenOrHeard();
            }
        }
        else
        {
            ClearAllActions(TRUE);
            CleanCombatVars();
            if (iAmMonster)
            {
                SetLocalObject(OBJECT_SELF, "NW_GENERIC_LAST_ATTACK_TARGET", OBJECT_INVALID);
                WalkWayPoints();
            }
            ClearWeaponStates();
            HenchEquipDefaultWeapons();
        }
        DeleteLocalObject(OBJECT_SELF, sHenchLastTarget);
        DeleteLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE);
        // nothing more to do
        return;
    }

    ClearEnemyLocation();
    DeleteLocalInt(OBJECT_SELF, henchBuffCountStr);
    DeleteLocalInt(OBJECT_SELF, henchHealCountStr);

    // fail safe set of last target
    // only change target if it is no longer valid - pok
    if (!GetIsValidTarget(GetLocalObject(OBJECT_SELF, sHenchLastTarget)))
        SetLocalObject(OBJECT_SELF, sHenchLastTarget, oIntruder);

    int combatRoundCount;
    combatRoundCount = GetLocalInt(OBJECT_SELF, henchCombatRoundStr);
    combatRoundCount ++;
    SetLocalInt(OBJECT_SELF, henchCombatRoundStr, combatRoundCount);

        //Shout that I was attacked
    if (!(iAmHenchman || iAmFamiliar || iAmCompanion) &&
        (HENCH_MONSTER_SHOUT_FREQUENCY > 0) &&
        (combatRoundCount % HENCH_MONSTER_SHOUT_FREQUENCY == 1))
    {
        SpeakString("NW_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);
        SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);
    }

    // June 2/04: Fix for when henchmen is told to use stealth until next fight
    if(GetLocalInt(OBJECT_SELF, sHenchStealthMode)==2)
    {
        SetLocalInt(OBJECT_SELF, sHenchStealthMode, 0);
    }

    // ----------------------------------------------------------------------------------------
    // July 27/2003 - Georg Zoeller,
    // Added to allow a replacement for determine combat round
    // If a creature has a local string variable named X2_SPECIAL_COMBAT_AI_SCRIPT
    // set, the script name specified in the variable gets run instead
    // see x2_ai_behold for details:
    // ----------------------------------------------------------------------------------------
    string sSpecialAI = GetLocalString(OBJECT_SELF,"X2_SPECIAL_COMBAT_AI_SCRIPT");
    if (sSpecialAI == "")
    {
        if (GetHasSpell(SPELL_HENCH_Beholder_Special_Spell_AI) ||
            GetHasSpell(SPELL_HENCH_Beholder_Anti_Magic_Cone))
        {
            sSpecialAI = "x2_ai_behold";
        }
    }
    if (sSpecialAI != "")
    {
        SetLocalObject(OBJECT_SELF,"X2_NW_I0_GENERIC_INTRUDER", oIntruder);
        ExecuteScript(sSpecialAI, OBJECT_SELF);
        if (GetLocalInt(OBJECT_SELF,"X2_SPECIAL_COMBAT_AI_SCRIPT_OK"))
        {
            DeleteLocalInt(OBJECT_SELF,"X2_SPECIAL_COMBAT_AI_SCRIPT_OK");
            return;
        }
    }

//    Jug_Debug(GetName(OBJECT_SELF) + " intruder " + GetName(oIntruder));

    InitializeItemSpells(nClass, iEffectsOnSelf & HENCH_HAS_POLYMORPH_EFFECT, HENCH_INIT_ALL_SPELLS);

        // try to go invis if have sneak attack at beginning of combat (helps with sneaking)
    if (iUseMagic && (combatRoundCount < 2 || GetHasFeat(FEAT_SNEAK_ATTACK)))
    {
        HenchTalentStealth(nGlobalMeleeAttackers);
    }

    // Get distance closer than which henchman will swap to melee.
    float fThresholdDistance = GetLocalFloat(OBJECT_SELF, sHenchHenchRange);
    if (fThresholdDistance == 0.0)
        fThresholdDistance = PAUSANIAS_DISTANCE_THRESHOLD;

    // Get challenge below which no defensive spells are cast
    float fThresholdChallenge = GetLocalFloat(OBJECT_SELF, sHenchSpellChallenge);
    if (fThresholdChallenge == 0.0)
    {
        if (nClass == CLASS_TYPE_WIZARD || nClass == CLASS_TYPE_SORCERER)
        {
            fThresholdChallenge = -3.;
        }
        else
        {
            fThresholdChallenge = PAUSANIAS_CHALLENGE_THRESHOLD;
        }
    }

    // Signal to try to get some distance between self and the enemy.
    int bBackAway = FALSE;
    if (fThresholdDistance > 50.0)
    {
        bBackAway = TRUE;
        fThresholdDistance = PAUSANIAS_DISTANCE_THRESHOLD;
    }

    // Monsters and non-associates do not care about the challenge rating for now.
    if (iAmMonster || !iHaveMaster)
        fThresholdChallenge = -100.;

    // Should I try to cast spells if monsters are nearby? Yes by default
    int iCastMelee = TRUE;
    if (GetLocalInt(OBJECT_SELF,sHenchDontCastMelee))
        iCastMelee = FALSE;

    int iHealMelee = TRUE;
    if (GetLocalInt(OBJECT_SELF,"DoNotHealMelee"))
        iHealMelee = FALSE;

    // The FIRST PRIORITY: self-preservation

    int nRacialType = GetRacialType(OBJECT_SELF);

    if (iCheckHealing && iAmMonster)
    {
        int nMonsterDamageOpt = GetMonsterOptions(HENCH_MONAI_HASTE | HENCH_MONAI_HEALPT);
        if (nMonsterDamageOpt)
        {
            // Pausanias: Monsters get tougher for the harder game settings.
            if ((nMonsterDamageOpt & HENCH_MONAI_HASTE) &&
                !(iEffectsOnSelf & HENCH_HAS_HASTE_EFFECT))
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectHaste(), OBJECT_SELF, 60.);
            }
            if ((nMonsterDamageOpt & HENCH_MONAI_HEALPT) && !(iHP < 20 && iMeleeAttackers))
            {
                if (nRacialType != RACIAL_TYPE_UNDEAD && GetCreatureUseItems(OBJECT_SELF))
                {
                    int nHeal = GetLocalInt(OBJECT_SELF,"GaveHealing");
                    if (nHeal < (GetHitDice(OBJECT_SELF)/2))
                    {
                        ++nHeal;
                        SetLocalInt(OBJECT_SELF, "GaveHealing", nHeal);
                        CreateItemOnObject("NW_IT_MPOTION003", OBJECT_SELF, 1);
                    }
                }
            }
        }
    }

    float fChallenge;
    if (iAmMonster || !iHaveMaster)
    {
        // Monsters and non-associates do not care about the challenge rating for now.
        fChallenge = 100.0;
    }
    else
    {
        // Pausanias's Combined Challenge Rating (CCR)
        fChallenge = GetEnemyChallenge();
    }

      // I am a familiar or animal companion
    if ((iAmFamiliar || iAmCompanion) && GetIsObjectValid(oClosestSeenOrHeard))
    {
        // Get challenge above which familiar or animal companion will run away
        float fAssociateChallenge;
        int bFightToTheDeath;
        if (iAmFamiliar)
        {
            fAssociateChallenge = GetLocalFloat(oMaster, sHenchFamiliarChallenge);
            if (fAssociateChallenge == 0.0)
                fAssociateChallenge = PAUSANIAS_FAMILIAR_THRESHOLD;
            bFightToTheDeath = GetLocalInt(oMaster, sHenchFamiliarToDeath);
        }
        else
        {
            // default to 0.0 challenge if not set
            fAssociateChallenge = GetLocalFloat(oMaster, sHenchAniCompChallenge);
            bFightToTheDeath = GetLocalInt(oMaster, sHenchAniCompToDeath);
        }
        // Run away from tough enemies
        if (!bFightToTheDeath && (fChallenge >= fAssociateChallenge || (iHP < 40)))
        {
            if (iAmFamiliar)
            {
                switch (d10())
                {
                    case 1: SpeakString(sHenchFamiliarFlee1); return;
                    case 2: SpeakString(sHenchFamiliarFlee2); break;
                    case 3: SpeakString(sHenchFamiliarFlee3); break;
                    case 4: SpeakString(sHenchFamiliarFlee4); break;
                }
            }
            else
            {
                if (d3() == 1)
                {
                    SpeakString(sHenchAniCompFlee);
                }
            }
            ClearAllActions();
            HenchTalentHide(iEffectsOnSelf, nGlobalMeleeAttackers);
            ActionMoveAwayFromObject(oClosestSeenOrHeard,TRUE,40.);
            ActionMoveAwayFromObject(oClosestSeenOrHeard,TRUE,40.);
            ActionMoveAwayFromObject(oClosestSeenOrHeard,TRUE,40.);
            ActionMoveAwayFromObject(oClosestSeenOrHeard,TRUE,40.);
            SetLocalInt(OBJECT_SELF, sHenchRunningAway, TRUE);
            return;
        }
    }
    if (!iMeleeAttackers)
    {
        nGlobalMeleeAttackers = 0;
    }
        // Condition for immediate self-healing
    if (iCheckHealing)
    {
            // if hidden, try to bring up to max HP
        if (HenchTalentHeal(OBJECT_SELF, iEffectsOnSelf, (iHP <= 90) && InvisibleTrue() ?
            HENCH_HEAL_FORCE : HENCH_HEAL_NO_MINOR)) return;
        if ((iAmHenchman || iAmFamiliar) && (GetLocalInt(OBJECT_SELF, HENCH_HEAL_SELF_STATE) == HENCH_HEAL_SELF_CANT))
        {
            if (iAmHenchman)
            {
                if (Random(100) > 80) VoiceHealMe();
            }
            else
            {
                SpeakString(sHenchHealMe);
            }
        }
    }

    // get in as many melee attacks as possible before spell ends
    if (GetHasSpellEffect(SPELL_TRUE_STRIKE))
    {
        HenchTalentMeleeAttack(oIntruder, fThresholdDistance, iMeleeAttackers,
            iAmMonster ? 0 : (iAmHenchman ? 1 : 2), iEffectsOnSelf & HENCH_HAS_POLYMORPH_EFFECT);
        return;
    }

    // NEXT priority: Heal master if needed.
    if (GetAssociateHealMaster())
    {
        if (fDistance > fThresholdDistance || iHealMelee)
        {
           if (HenchTalentHeal(oMaster, iEffectsOnSelf, HENCH_HEAL_FORCE | HENCH_HEAL_NO_MINOR)) return;
           if (d10() > 6 &&
              (nClass == CLASS_TYPE_BARD || nClass == CLASS_TYPE_CLERIC ||
               nClass == CLASS_TYPE_DRUID || nClass == CLASS_TYPE_PALADIN))
                  SpeakString(sHenchCantHealMaster);
        }
        else
           if (d10() > 6)
               SpeakString(sHenchAskHealMaster);
    }

    // NEXT priority: follow or return to master for up to three rounds.
    int nFollow = GetLocalInt(OBJECT_SELF,"FollowCount");
    ++nFollow;
    if(iHaveMaster && !GetLocalInt(OBJECT_SELF, sHenchRunningAway) &&
        (!bBackAway || GetLocalInt(OBJECT_SELF, sHenchScoutingFlag)))
    {
        SetLocalInt(OBJECT_SELF, sHenchScoutingFlag, FALSE);

        if(GetDistanceToObject(oRealMaster) > 15.0 && !GetObjectSeen(oRealMaster))
        {
            if(GetCurrentAction(oRealMaster) != ACTION_FOLLOW)
            {
                ActionForceFollowObject(oRealMaster, GetFollowDistance());
                return;
            }
            else if (nFollow < 4)
            {
                return;
            }
        }
    }
    SetLocalInt(OBJECT_SELF, "FollowCount", 0);

    // Pausanias: Combat has finally begun, so we are no longer scouting
    DeleteLocalInt(OBJECT_SELF, sHenchScoutingFlag);
    DeleteLocalInt(OBJECT_SELF, sHenchRunningAway);

    int iPanicMode = (GetLocalInt(OBJECT_SELF, "INeedHealing") == 2 && iHP < 35) ||
        (iHaveMaster && GetPercentageHPLoss(oRealMaster) < 35);
    if (iPanicMode)
    {
        //iCastMelee = TRUE;
        iHealMelee = TRUE;
        fChallenge = 90.0;
    }

// TODO HotU adjust tactics to be more in line with HoTU overrides?
         // Should I try to cast spells if monsters are nearby? Yes by default
    int useAttackSpells = FALSE;
    int buffSelf = FALSE;
    int buffOthers = FALSE;
    int allowWeakOffSpells = FALSE;
    int allowAttackAbilities = FALSE;
    int allowUnlimitedAttackAbilities = iUseMagic;
    int allowBuffAbilities = FALSE;

    if (iUseMagic && fChallenge >= fThresholdChallenge)
    {
        buffSelf = TRUE;
        allowAttackAbilities = TRUE;
        allowBuffAbilities = TRUE;
        int nMaxHitDieTest = GetHitDice(OBJECT_SELF);
        if (nMaxHitDieTest > 9)
        {
            nMaxHitDieTest = 9;
        }
        if (!iMeleeAttackers)
        {
            switch (nClass)
            {
            case CLASS_TYPE_WIZARD:
            case CLASS_TYPE_SORCERER:
            case CLASS_TYPE_FEY:
            case CLASS_TYPE_OUTSIDER:
                useAttackSpells = TRUE;
                allowWeakOffSpells = d10(2) >= nMaxHitDieTest;
                buffOthers = d2() == 1;
                break;
            case CLASS_TYPE_BARD:
            case CLASS_TYPE_DRUID:
                useAttackSpells = TRUE;
                allowWeakOffSpells = useAttackSpells && d3(3) >= nMaxHitDieTest;
                buffOthers = d2() == 1;
                break;
            case CLASS_TYPE_CLERIC:
            case CLASS_TYPE_MAGICAL_BEAST:
                useAttackSpells = d3() != 1;
                allowWeakOffSpells = useAttackSpells && d3(3) >= nMaxHitDieTest;
                buffOthers = TRUE;
                break;
            default:
                useAttackSpells = d3() == 1;
                allowWeakOffSpells = useAttackSpells && d3(3) >= nMaxHitDieTest;
                buffOthers = TRUE;
                break;
            }
        }
        else if (iCastMelee)
        {
            switch (nClass)
            {
            case CLASS_TYPE_WIZARD:
            case CLASS_TYPE_SORCERER:
                useAttackSpells = TRUE;
                allowWeakOffSpells = d10(2) >= nMaxHitDieTest;
                buffOthers = d6() == 1;
                break;
            case CLASS_TYPE_BARD:
            case CLASS_TYPE_DRUID:
            case CLASS_TYPE_FEY:
            case CLASS_TYPE_OUTSIDER:
                useAttackSpells = d2() == 1;
                allowWeakOffSpells = useAttackSpells && d4() >= nMaxHitDieTest;
                buffOthers = d6() == 1;
                break;
            case CLASS_TYPE_CLERIC:
            case CLASS_TYPE_MAGICAL_BEAST:
                useAttackSpells = d4() == 1;
                allowWeakOffSpells = useAttackSpells && d4() >= nMaxHitDieTest;
                buffOthers = d4() == 1;
                break;
            default:
                useAttackSpells = d8() == 1;
                allowWeakOffSpells = useAttackSpells && d4() >= nMaxHitDieTest;
                buffOthers = d10() == 1;
                break;
            }
        }
    }

        // if raging, then turn off most spell casting
    if (GetHasSpellEffect(SPELLABILITY_RAGE_5) || GetHasSpellEffect(SPELLABILITY_RAGE_4) ||
        GetHasSpellEffect(SPELLABILITY_RAGE_3) || GetHasSpellEffect(SPELLABILITY_FEROCITY_2) ||
        GetHasSpellEffect(SPELLABILITY_FEROCITY_1) || GetHasSpellEffect(SPELL_BLOOD_FRENZY) ||
        GetHasFeatEffect(FEAT_BARBARIAN_RAGE) || GetHasFeatEffect(SPELLABILITY_FEROCITY_3))
    {
        useAttackSpells = FALSE;
        buffSelf = buffSelf && d6() == 1;
        buffOthers = FALSE;
        allowWeakOffSpells = FALSE;
        iSummonHelp = FALSE;
    }
        // if have melee attack bonuses, then turn off most spell casting
    else if (GetHasSpellEffect(SPELLABILITY_DIVINE_STRENGTH) || GetHasSpellEffect(SPELLABILITY_DIVINE_PROTECTION) ||
        GetHasSpellEffect(SPELL_DIVINE_POWER) || GetHasSpellEffect(SPELLABILITY_BATTLE_MASTERY) ||
        GetHasSpellEffect(SPELL_DIVINE_FAVOR) || GetHasFeatEffect(FEAT_DIVINE_MIGHT) ||
        GetHasFeatEffect(FEAT_DIVINE_SHIELD))
    {
        useAttackSpells = FALSE;
        buffSelf = buffSelf && d2() == 1;
        buffOthers = FALSE;
        allowWeakOffSpells = FALSE;
        iSummonHelp = FALSE;
    }

    if (!GetIsObjectValid(oIntruderSeen))
    {
        useAttackSpells = FALSE;
        allowAttackAbilities = FALSE;
        allowUnlimitedAttackAbilities = FALSE;
        allowWeakOffSpells = FALSE;
    }
    else
    {
        if (oIntruderSeen == oClosestNonActive)
        {
            // only wizards or sorcerers attack disabled creatures with spells
            if (nClass != CLASS_TYPE_SORCERER && nClass != CLASS_TYPE_WIZARD)
            {
                useAttackSpells = FALSE;
                allowAttackAbilities = FALSE;
                allowWeakOffSpells = FALSE;
            }
            buffSelf = FALSE;
            buffOthers = FALSE;
            iSummonHelp = FALSE;
        }
    }

        // I am a henchman
    if (GetIsObjectValid(oClosestSeenOrHeard) && ((iAmHenchman && bBackAway) || GetCombatCondition(X0_COMBAT_FLAG_RANGED)))
    {
        if (fDistance < 8.0 && fDistance > 3.0)
        {
        // Try to get some distance for up to 3 rounds if told to do so.
            int nBackAway = GetLocalInt(OBJECT_SELF,"BackAway");
            if (nBackAway < 4)
            {
                ActionMoveAwayFromObject(oClosestSeenOrHeard, TRUE, 15.0);
                ++nBackAway;
                SetLocalInt(OBJECT_SELF,"BackAway", nBackAway);
                return;
            }
        }
        SetLocalInt(OBJECT_SELF,"BackAway",0);
    }
    int iCloseBuff = 0;
    if (iAmHenchman && GetIsObjectValid(oClosestSeenOrHeard))
    {
        // 5% chance per round of speaking the relative challenge of the encounter.
        if (d20() == 1)
        {
            if (fChallenge < -3.) SpeakString(sHenchWeakAttacker);
            else if (fChallenge < -1.) SpeakString(sHenchModAttacker);
            else if (fChallenge < 2.) SpeakString(sHenchStrongAttacker);
            else SpeakString(sHenchOverpoweringAttacker);
        }

        // Logic: if we are at close range, and the encounter is tough
        // Then Buff the PC up once, and then fight. Otherwise, if
        // we are at close range, fight; else 20% chance of using
        // the missile weapon. Sorcerors or wizards try to cast spells
        // rather than fight.

        if ((nClass != CLASS_TYPE_WIZARD && nClass != CLASS_TYPE_SORCERER) ||
            !iCastMelee)
        {
            if (iCastMelee && iMeleeAttackers && !iPanicMode)
            {
                if (fChallenge >= 0.0)
                {
                    iCloseBuff = GetLocalInt(OBJECT_SELF,"CloseRangeEnhanced");
                    iCloseBuff++;
                    if (iCloseBuff == 1)
                    {
                        buffOthers = TRUE; buffSelf = FALSE;
                    }
                    else if (iCloseBuff == 2)
                    {
                        buffOthers = FALSE; buffSelf = TRUE;
                    }
                    else
                    {
                        buffOthers = FALSE; buffSelf = FALSE;
                    }
                }
                else
                {
                    buffOthers = FALSE; buffSelf = FALSE;
                }
            }
            // 30% chance of attacking weak opponents outright even if
            // they are not at close range.
            // There's a 20% chance of attacking anyway if the missile weapon is equipped.
            if (iMeleeAttackers || (fChallenge < -3. && d100() < 30) ||
                (GetAssociateState(NW_ASC_USE_RANGED_WEAPON) && (d100() < 20)))
            {
                useAttackSpells = FALSE;
                buffSelf = FALSE;
                buffOthers = FALSE;
                allowWeakOffSpells = FALSE;
                iSummonHelp = FALSE;
            }
        }
    }
        // check for area effect spells damaging self
    if (CheckAOEForSelf()) {return;}

    /* TODO leave out for now
    if (GetCombatCondition(X0_COMBAT_FLAG_AMBUSHER)
        && SpecialTacticsAmbusher(oClosestSeenOrHeard))
    {
        return;
    }*/

        //Remove negative effects from allies
    if(iUseMagic && HenchTalentCureCondition()) {return;}
        //Check if allies or self are injured
    if(iUseMagic && HenchTalentHealAllies(iEffectsOnSelf, HENCH_HEAL_NO_MINOR)) {return;}

    if (allowBuffAbilities)
    {
         if (HenchTalentPersistentAbilities()) {return;}
         if(HenchTalentBardSong()) {return;}
    }

    if (InvisibleTrue())
    {
        // while invisible do maximum amount of buffing & summoning
        int result = TK_UseBestSpell(OBJECT_INVALID, OBJECT_INVALID, oFriend, FALSE, FALSE, FALSE,
            iSummonHelp, buffSelf, buffOthers, allowBuffAbilities, FALSE, iAmMonster);
        if ((iCloseBuff == 1 && result == TK_BUFFOTHER) || (iCloseBuff == 2 && result == TK_BUFFSELF))
        {
            SetLocalInt(OBJECT_SELF,"CloseRangeEnhanced", iCloseBuff);
        }
        if (result) { return; }
        iSummonHelp = FALSE;
        buffSelf = FALSE;
        allowBuffAbilities = FALSE;
    }

        // transformation spells if got here for druid or shifter
    if (iUseMagic && allowAttackAbilities && GetLevelByClass(CLASS_TYPE_DRUID))
    {
        if (HenchTalentAdvancedPolymorph(iEffectsOnSelf & HENCH_HAS_POLYMORPH_EFFECT)) { return; }
    }

    int result = TK_UseBestSpell(oIntruderSeen, GetIsObjectValid(oClosestHeard) ? oClosestHeard : oNotHeardOrSeen, oFriend,
        useAttackSpells, allowAttackAbilities, allowUnlimitedAttackAbilities, iSummonHelp, buffSelf, buffOthers,
        allowBuffAbilities, allowWeakOffSpells, iAmMonster);
    if ((iCloseBuff == 1 && result == TK_BUFFOTHER) || (iCloseBuff == 2 && result == TK_BUFFSELF))
    {
        SetLocalInt(OBJECT_SELF,"CloseRangeEnhanced", iCloseBuff);
    }
    if (result) { return; }

        // transformation spells if got here for wizard, sor, or druid
    if (iUseMagic && buffSelf && !(iEffectsOnSelf & HENCH_HAS_POLYMORPH_EFFECT))
    {
        if (HenchTalentPolymorph()) { return; }
    }

    if (!iMeleeAttackers && GetIsObjectValid(oIntruderSeen) && (!iAmHenchman || GetAssociateState(NW_ASC_USE_RANGED_WEAPON)) && GetCreatureUseItems(OBJECT_SELF))
    {
        if (HenchUseGrenade(oIntruderSeen)) { return; }
    }
        //Attack if out of spells
    HenchTalentMeleeAttack(oIntruder, fThresholdDistance, iMeleeAttackers,
        iAmMonster ? 0 : (iAmHenchman ? 1 : 2), iEffectsOnSelf & HENCH_HAS_POLYMORPH_EFFECT);
}


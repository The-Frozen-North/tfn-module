/* COMBAT Library by Gigaschatten */

#include "inc_ai_combat2"
#include "inc_ai_combat3"
//#include "gs_inc_flag"

//void main() {}

void DoCombatVoice()
{
    if (GetIsDead(OBJECT_SELF)) return;

    string sBattlecryScript = GetLocalString(OBJECT_SELF, "battlecry_script");
    if (sBattlecryScript != "")
    {
        ExecuteScript(sBattlecryScript, OBJECT_SELF);
    }
    else
    {
        int nRand = 40;
        if (GetLocalInt(OBJECT_SELF, "boss") == 1) nRand = nRand/2;

        switch (Random(nRand))
        {
            case 0: PlayVoiceChat(VOICE_CHAT_BATTLECRY1, OBJECT_SELF); break;
            case 1: PlayVoiceChat(VOICE_CHAT_BATTLECRY2, OBJECT_SELF); break;
            case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY3, OBJECT_SELF); break;
            case 3: PlayVoiceChat(VOICE_CHAT_ATTACK, OBJECT_SELF); break;
            case 4: PlayVoiceChat(VOICE_CHAT_TAUNT, OBJECT_SELF); break;
            case 5: PlayVoiceChat(VOICE_CHAT_LAUGH, OBJECT_SELF); break;
        }
    }
}


const int GS_CB_BEHAVIOR_DEFENSIVE       = 1;
const int GS_CB_BEHAVIOR_ATTACK_SPELL    = 2;
const int GS_CB_BEHAVIOR_ATTACK_PHYSICAL = 3;

//return random class type by class relation of caller
int gsCBDetermineClass();
//return TRUE if oObject perceives oTarget
int gsCBGetIsPerceived(object oTarget, object oObject = OBJECT_SELF);
//return and set attack target of oObject, primary oTarget can be specified
object gsCBGetAttackTarget(object oObject = OBJECT_SELF, object oTarget = OBJECT_INVALID);
//return last attack target of oObject
object gsCBGetLastAttackTarget(object oObject = OBJECT_SELF);
//return TRUE if oObject has attack target
int gsCBGetHasAttackTarget(object oObject = OBJECT_SELF);
//set oTarget as attack target of oObject
void gsCBSetAttackTarget(object oTarget, object oObject = OBJECT_SELF);
//clear attack target of oObject
void gsCBClearAttackTarget(object oObject = OBJECT_SELF);
//return TRUE if caller is involved in combat
int gsCBGetIsInCombat();
//return TRUE if oObject is actually following a target across area borders
int gsCBGetIsFollowing(object oObject = OBJECT_SELF);
//return creature of nRace with distance between fMinimumDistance and fMaximumDistance to lLocation, specified by flag nFriendly, nNeutral, nHostile, nDamaged, nRequiredAid and nCounterMeasure
object gsCBGetCreatureAtLocation(location lLocation, int nFriendly = TRUE, int nNeutral = TRUE, int nHostile = TRUE, float fMinimumDistance = 0.0, float fMaximumDistance = 5.0, int nRace = RACIAL_TYPE_ALL, int nDamaged = FALSE, int nRequiredAid = FALSE, int nCounterMeasure = FALSE);
//return number of creatures of nRace with distance between fMinimumDistance and fMaximumDistance to lLocation, specified by flag nFriendly, nNeutral, nHostile, nDamaged, nRequiredAid and nCounterMeasure
int gsCBGetCreatureCountAtLocation(location lLocation, int nFriendly = TRUE, int nNeutral = TRUE, int nHostile = TRUE, float fMinimumDistance = 0.0, float fMaximumDistance = 5.0, int nRace = RACIAL_TYPE_ALL, int nDamaged = FALSE, int nRequiredAid = FALSE, int nCounterMeasure = FALSE);
//return force balance at location of caller
int gsCBGetForceBalance();

//caller decides to attack oVictim, the attacker of oVictim or to do no action
void gsCBDetermineAttackTarget(object oVictim);
//main combat ai function
void gsCBDetermineCombatRound(object oTarget = OBJECT_INVALID);

//return TRUE if tTalent is used on oTarget
int gsCBUseTalentOnObject(talent tTalent, object oTarget = OBJECT_SELF);
//return TRUE if nFeat is used on oTarget
int gsCBUseFeatOnObject(int nFeat, object oTarget = OBJECT_SELF);
//return TRUE if nSpell is cast at oTarget
int gsCBCastSpellAtObject(int nSpell, object oTarget = OBJECT_SELF);
//return TRUE if caller can use a talent from the specified categories on itself
int gsCBTalentSelf(int nTalentCategorySelf, int nTalentCategorySingle = FALSE, int nTalentCategoryPotion = FALSE,int nTalentCategoryArea = FALSE);
//return TRUE if caller can use a talent from the specified categories on allies
int gsCBTalentOthers(int nTalentCategoryArea, int nTalentCategorySingle = FALSE);
//return TRUE if caller can protect itself with spells, features or potions
int gsCBTalentProtectSelf();
//return TRUE if caller can protect allies with spells or features
int gsCBTalentProtectOthers();
//return TRUE if caller can enhance itself with spells, features or potions
int gsCBTalentEnhanceSelf();
//return TRUE if caller can enhance allies with spells or features
int gsCBTalentEnhanceOthers();
//return TRUE if caller can use persistent effect on itself
int gsCBTalentPersistentEffect();
//return TRUE if caller can heal itself with spells, features or potions
int gsCBTalentHealSelf();
//return TRUE if caller can heal allies with spells or features
int gsCBTalentHealOthers();
//return TRUE if caller can remove negative conditions from itself or allies
int gsCBTalentCureCondition();
//internally used
object _gsCBTalentCureCondition(location lLocation, int nRequiredAid);
//return TRUE if caller can take counter measure against enemy
int gsCBTalentCounterMeasure();
//internally used
object _gsCBTalentCounterMeasure(location lLocation, int nCounterMeasure);
//return TRUE if caller can obtain ally near oTarget
int gsCBTalentSummonAlly(object oTarget = OBJECT_SELF);
//return TRUE if caller can turn/destroy enemies
int gsCBTalentUseTurning();
//return TRUE if caller can use dragon breath on oTarget
int gsCBTalentDragonBreath(object oTarget);
//return TRUE if caller can use dragon wing on oTarget
int gsCBTalentDragonWing(object oTarget, int nFly = FALSE);
//internally used
void _gsCBTalentDragonWing(object oObject);
//internally used
void __gsCBTalentDragonWing(object oObject);
//internally used
int ___gsCBTalentDragonWing(location lLocation);
//internally used
void ____gsCBTalentDragonWing(location lLocation);
//return TRUE if caller can cast harmful spell on oTarget
int gsCBTalentSpellAttack(object oTarget);
//caller tries to physically attack oTarget
void gsCBTalentAttack(object oTarget);
//internally used
void _gsCBTalentAttack(object oTarget, int nDistance);
//return TRUE if caller follows attack target across area borders
int gsCBTalentFollow();
//return TRUE if caller can use protection spell on itself
int gsCBTalentProtectBySpell();
//internally used
int _gsCBTalentProtectBySpell(int nSpell, int nInstant = FALSE);
//return TRUE if caller can dispel benevolent magic on oTarget
int gsCBTalentDispelMagic(object oTarget);
//return TRUE if caller takes action to evade darkness effect
int gsCBTalentEvadeDarkness();

//caller issues requests reinforcement if required
void gsCBRequestReinforcement();
//set reinforcement requested by oObject from caller
void gsCBSetReinforcementRequestedBy(object oObject);
//return TRUE if caller follows reinforcement request
int gsCBReinforce();

int gsCBDetermineClass()
{
    int nClass1      = GetClassByPosition(1);
    int nClass2      = GetClassByPosition(2);
    int nClass3      = GetClassByPosition(3);
    int nClassLevel1 = GetLevelByClass(nClass1);
    int nClassLevel2 = GetLevelByClass(nClass2);
    int nClassLevel3 = GetLevelByClass(nClass3);
    int nClassLevel  = nClassLevel1 + nClassLevel2 + nClassLevel3;
    int nRandom      = Random(nClassLevel);

    if (nRandom < nClassLevel1)                return nClass1;
    if (nRandom < nClassLevel1 + nClassLevel2) return nClass2;
    return nClass3;
}
//----------------------------------------------------------------
int gsCBGetIsPerceived(object oTarget, object oObject = OBJECT_SELF)
{
    if (gsC2GetHasEffect(EFFECT_TYPE_TRUESEEING, oObject))   return TRUE;
    if (gsC2GetHasEffect(EFFECT_TYPE_ETHEREAL, oTarget))     return FALSE;
    if (GetObjectSeen(oTarget, oObject))                     return TRUE;
    if (gsC2GetHasEffect(EFFECT_TYPE_SANCTUARY, oTarget))    return FALSE;
    if (GetObjectHeard(oTarget, oObject))                    return TRUE;
    if (GetActionMode(oTarget, ACTION_MODE_STEALTH) &&
        ! (GetIsSkillSuccessful(oObject, SKILL_SPOT, GetSkillRank(SKILL_HIDE, oTarget) + d20()) ||
           GetIsSkillSuccessful(oObject, SKILL_LISTEN, GetSkillRank(SKILL_MOVE_SILENTLY, oTarget) + d20())))
    {
        return FALSE;
    }
    if (gsC2GetHasEffect(EFFECT_TYPE_SEEINVISIBLE, oObject)) return TRUE;
    if (gsC2GetHasEffect(EFFECT_TYPE_INVISIBILITY, oTarget)) return FALSE;
    return TRUE;
}
//----------------------------------------------------------------
object gsCBGetAttackTarget(object oObject = OBJECT_SELF, object oTarget = OBJECT_INVALID)
{
    if (! GetIsObjectValid(oTarget) ||
        GetPlotFlag(oTarget) ||
        GetIsDead(oTarget) ||
        GetDistanceBetween(oObject, oTarget) > 60.0 ||
        (! GetIsEnemy(oTarget, oObject) && GetFactionEqual(oObject, oTarget)) ||
        ! gsCBGetIsPerceived(oTarget, oObject))
    {
        oTarget = gsCBGetLastAttackTarget(oObject);

        if (! GetIsObjectValid(oTarget) ||
            GetPlotFlag(oTarget) ||
            GetIsDead(oTarget) ||
            (! GetIsEnemy(oTarget, oObject) && GetFactionEqual(oObject, oTarget)) ||
            ! gsCBGetIsPerceived(oTarget, oObject))
        {
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                                         oObject, 1,
                                         CREATURE_TYPE_IS_ALIVE, TRUE,
                                         CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);

            if (! GetIsObjectValid(oTarget) ||
                GetPlotFlag(oTarget))
            {
                oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                                             oObject, 1,
                                             CREATURE_TYPE_IS_ALIVE, TRUE,
                                             CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD);

                if (! GetIsObjectValid(oTarget) ||
                    GetPlotFlag(oTarget))
                {
                    gsCBClearAttackTarget(oObject);
                    return OBJECT_INVALID;
                }
            }
        }
    }

    gsCBSetAttackTarget(oTarget, oObject);
    return oTarget;
}
//----------------------------------------------------------------
object gsCBGetLastAttackTarget(object oObject = OBJECT_SELF)
{
    return GetLocalObject(oObject, "GS_CB_ATTACK_TARGET");
}
//----------------------------------------------------------------
int gsCBGetHasAttackTarget(object oObject = OBJECT_SELF)
{
    return GetIsObjectValid(gsCBGetLastAttackTarget(oObject));
}
//----------------------------------------------------------------
void gsCBSetAttackTarget(object oTarget, object oObject = OBJECT_SELF)
{
    SetLocalObject(oObject, "GS_CB_ATTACK_TARGET", oTarget);
}
//----------------------------------------------------------------
void gsCBClearAttackTarget(object oObject = OBJECT_SELF)
{
    DeleteLocalObject(oObject, "GS_CB_ATTACK_TARGET");
}
//----------------------------------------------------------------
int gsCBGetIsInCombat()
{
    return GetIsInCombat() ||
           GetIsObjectValid(GetAttackTarget()) ||
           GetIsObjectValid(GetAttemptedAttackTarget()) ||
           GetIsObjectValid(GetAttemptedSpellTarget());
}
//----------------------------------------------------------------
int gsCBGetIsFollowing(object oObject = OBJECT_SELF)
{
    return GetIsObjectValid(GetLocalObject(oObject, "GS_CB_FOLLOW_TARGET"));
}
//----------------------------------------------------------------
object gsCBGetCreatureAtLocation(location lLocation,
                                 int nFriendly          = TRUE,
                                 int nNeutral           = TRUE,
                                 int nHostile           = TRUE,
                                 float fMinimumDistance = 0.0,
                                 float fMaximumDistance = 5.0,
                                 int nRace              = RACIAL_TYPE_ALL,
                                 int nDamaged           = FALSE,
                                 int nRequiredAid       = FALSE,
                                 int nCounterMeasure    = FALSE)
{
    object oObject   = GetFirstObjectInShape(SHAPE_SPHERE, fMaximumDistance, lLocation, TRUE);
    vector vPosition = GetPositionFromLocation(lLocation);
    float fDistance  = 0.0;
    int nReputation  = 0;

    while (GetIsObjectValid(oObject))
    {
        nReputation = GetReputation(OBJECT_SELF, oObject);

        if (! GetIsDead(oObject) &&
            (nFriendly && nReputation >= 65)                    ||
            (nNeutral  && nReputation > 35 && nReputation < 65) ||
            (nHostile  && nReputation <= 35))
        {
            fDistance = VectorMagnitude(vPosition - GetPosition(oObject));

            if (fDistance >= fMinimumDistance                                                 &&
                                      nRace                          & GetRacialType(oObject) &&
                (! nDamaged        || gsC2GetIsDamaged(oObject))                              &&
                (! nRequiredAid    || gsC2GetRequiredAid(oObject)    & nRequiredAid)          &&
                (! nCounterMeasure || gsC2GetCounterMeasure(oObject) & nCounterMeasure))
            {
                return oObject;
            }
        }

        oObject     = GetNextObjectInShape(SHAPE_SPHERE, fMaximumDistance, lLocation, TRUE);
    }

    return OBJECT_INVALID;
}
//----------------------------------------------------------------
int gsCBGetCreatureCountAtLocation(location lLocation,
                                   int nFriendly          = TRUE,
                                   int nNeutral           = TRUE,
                                   int nHostile           = TRUE,
                                   float fMinimumDistance = 0.0,
                                   float fMaximumDistance = 5.0,
                                   int nRace              = RACIAL_TYPE_ALL,
                                   int nDamaged           = FALSE,
                                   int nRequiredAid       = FALSE,
                                   int nCounterMeasure    = FALSE)
{
    object oObject   = GetFirstObjectInShape(SHAPE_SPHERE, fMaximumDistance, lLocation, TRUE);
    vector vPosition = GetPositionFromLocation(lLocation);
    float fDistance  = 0.0;
    int nReputation  = 0;
    int nCount       = 0;

    while (GetIsObjectValid(oObject))
    {
        nReputation = GetReputation(OBJECT_SELF, oObject);

        if (! GetIsDead(oObject) &&
            (nFriendly && nReputation >= 65)                    ||
            (nNeutral  && nReputation > 35 && nReputation < 65) ||
            (nHostile  && nReputation <= 35))
        {
            fDistance = VectorMagnitude(vPosition - GetPosition(oObject));

            if (fDistance >= fMinimumDistance                                                 &&
                                      nRace                          & GetRacialType(oObject) &&
                (! nDamaged        || gsC2GetIsDamaged(oObject))                              &&
                (! nRequiredAid    || gsC2GetRequiredAid(oObject)    & nRequiredAid)          &&
                (! nCounterMeasure || gsC2GetCounterMeasure(oObject) & nCounterMeasure))
            {
                if (++nCount == 3) return nCount;
            }
        }

        oObject     = GetNextObjectInShape(SHAPE_SPHERE, fMaximumDistance, lLocation, TRUE);
    }

    return nCount;
}
//----------------------------------------------------------------
int gsCBGetForceBalance()
{
    location lLocation = GetLocation(OBJECT_SELF);
    object oObject     = GetFirstObjectInShape(SHAPE_SPHERE, 15.0, lLocation, TRUE);
    float fRating      = 0.0;
    float fBalance     = 0.0;
    int nReputation    = 0;

    while (GetIsObjectValid(oObject))
    {
        nReputation = GetReputation(OBJECT_SELF, oObject);

        if (! GetIsDead(oObject) &&
            (nReputation <= 35 || nReputation >= 65))
        {
            fRating   = (GetIsPC(oObject) ?
                         IntToFloat(GetHitDice(oObject)) :
                         GetChallengeRating(oObject))
                        * IntToFloat(GetCurrentHitPoints(oObject))
                        / IntToFloat(GetMaxHitPoints(oObject));
            fBalance += nReputation >= 65 ? fRating : -fRating;
        }

        oObject = GetNextObjectInShape(SHAPE_SPHERE, 15.0, lLocation, TRUE);
    }

    return FloatToInt(fBalance * 10.0);
}
//----------------------------------------------------------------
//COMBAT
//----------------------------------------------------------------
void gsCBDetermineAttackTarget(object oVictim)
{
    if (GetIsObjectValid(oVictim))
    {
        object oAttacker = GetIsPC(oVictim) ?
                           OBJECT_INVALID :
                           gsCBGetAttackTarget(oVictim);

        if (GetIsObjectValid(oAttacker))
        {
            int nReputationVictim   = GetReputation(OBJECT_SELF, oVictim);
            int nReputationAttacker = GetReputation(OBJECT_SELF, oAttacker);

            if (nReputationVictim >= 65 &&
                nReputationVictim > nReputationAttacker)
            {
                gsCBDetermineCombatRound(oAttacker);
            }
            else if (nReputationAttacker >= 65)
            {
                gsCBDetermineCombatRound(oVictim);
            }
        }
        else if (GetIsEnemy(oVictim))
        {
            gsCBDetermineCombatRound(oVictim);
        }
    }
}
//----------------------------------------------------------------
void gsCBDetermineCombatRound(object oTarget = OBJECT_INVALID)
{
//    if (GetPlotFlag() ||
//        gsFLGetFlag(GS_FL_DISABLE_COMBAT))
//    {
//        return;
//    }

    //attack target
    oTarget = gsCBGetAttackTarget(OBJECT_SELF, oTarget);

    if (! GetIsObjectValid(oTarget))
    {
        ClearAllActions();
        return;
    }

// Turn off Detect if there is a valid target
    SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, FALSE);

    DoCombatVoice();

    if (! GetIsEnemy(oTarget)) SetIsTemporaryEnemy(oTarget, OBJECT_SELF, TRUE, 1800.00);

    //analyze
    gsC2Analyze();

    if (GetStandardFactionReputation(STANDARD_FACTION_COMMONER) > 25) SpeakString("GS_AI_INNOCENT_ATTACKED", TALKVOLUME_SILENT_TALK);

    //follow target
    if (gsCBGetIsFollowing()) return;

    //call aid
//    if (! gsFLGetFlag(GS_FL_DISABLE_CALL))
//    if (GetLocalInt(OBJECT_SELF, "boss") == 1 || GetLocalInt(OBJECT_SELF, "semiboss") == 1)
//    {
        SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);
        gsCBRequestReinforcement();
//    }

    if (gsCBReinforce()) oTarget = gsCBGetLastAttackTarget();

    if (GetCurrentAction() != ACTION_CASTSPELL) ClearAllActions();

//    //no magic area
//    if (gsFLGetAreaFlag("OVERRIDE_MAGIC"))
//    {
//        SetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOR", GS_CB_BEHAVIOR_ATTACK_PHYSICAL);
//        gsCBTalentAttack(oTarget);
//        return;
//    }

    //initial protection
    if (! gsCBGetIsInCombat()) gsCBTalentProtectBySpell();

    float fDistance = GetDistanceToObject(oTarget);

    if (GetLocalInt(OBJECT_SELF, "range") == 1 && fDistance >= 2.0 && fDistance <= 8.0)
    {
        ActionMoveAwayFromObject(oTarget, TRUE, 10.0);
    }

    int nBehavior   = GetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOR");
    int nAttack     = 80;
    int nSpell      = 20;

    //adjust class behavior
    switch (gsCBDetermineClass())
    {
    case CLASS_TYPE_ABERRATION:
        break;
    case CLASS_TYPE_ANIMAL:
        nAttack = 70;
        break;
    case CLASS_TYPE_ARCANE_ARCHER:
        break;
    case CLASS_TYPE_ASSASSIN:
        nAttack = 70;
        break;
    case CLASS_TYPE_BARBARIAN:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_BARD:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_BEAST:
        nAttack = 90;
        break;
    case CLASS_TYPE_BLACKGUARD:
        nAttack = 90;
        break;
    case CLASS_TYPE_CLERIC:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_COMMONER:
        nAttack = 20;
        break;
    case CLASS_TYPE_CONSTRUCT:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_DRAGON:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_DRAGONDISCIPLE:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_DRUID:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_DWARVENDEFENDER:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_ELEMENTAL:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_FEY:
        nAttack = 70;
        nSpell  = 60;
        break;
    case CLASS_TYPE_FIGHTER:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_GIANT:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_HARPER:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_HUMANOID:
        nAttack = 70;
        break;
    case CLASS_TYPE_MAGICAL_BEAST:
        nAttack = 90;
        nSpell  = 40;
        break;
    case CLASS_TYPE_MONK:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_MONSTROUS:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_OOZE:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_OUTSIDER:
        nSpell  = 30;
        break;
    case CLASS_TYPE_PALADIN:
        nAttack = 90;
        break;
    case CLASS_TYPE_PALEMASTER:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_RANGER:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_ROGUE:
        nAttack = 70;
        break;
    case CLASS_TYPE_SHADOWDANCER:
        nAttack = 70;
        break;
    case CLASS_TYPE_SHAPECHANGER:
        break;
    case CLASS_TYPE_SHIFTER:
        break;
    case CLASS_TYPE_SORCERER:
        nSpell  = 100;
        break;
    case CLASS_TYPE_UNDEAD:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_VERMIN:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_WEAPON_MASTER:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_WIZARD:
        nSpell  = 100;
        break;
    }

    //additional behavior adjustment
    if (fDistance > 5.0)
    {
        nSpell  +=  10;
        nAttack -=  50;
    }

    nSpell -= GetArcaneSpellFailure(OBJECT_SELF);

    if (nBehavior == GS_CB_BEHAVIOR_DEFENSIVE)
    {
        nAttack  = 100;
    }

    //primary
    if (gsCBTalentEvadeDarkness())           return;
    if (gsCBTalentDragonWing(oTarget, TRUE)) return;

    //defensive
    if (Random(100) >= nAttack)
    {
        SetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOR", GS_CB_BEHAVIOR_DEFENSIVE);

        if (gsCBTalentHealSelf() || gsCBTalentHealOthers())        return;
        if (Random(100) >= 25 && gsCBTalentCureCondition())        return;
        if (Random(100) >= 25 && gsCBTalentPersistentEffect())     return;
        if (Random(100) >= 25 && gsCBTalentProtectSelf())          return;
        //if (Random(100) >= 25 && gsCBTalentProtectOthers())        return;
        if (Random(100) >= 25 && gsCBTalentEnhanceSelf())          return;
        if (Random(100) >= 25 && gsCBTalentEnhanceOthers())        return;
        if (Random(100) >= 25 && gsCBTalentSummonAlly(oTarget))    return;
    }

    //spell
    if (Random(100) < nSpell && LineOfSightObject(OBJECT_SELF, oTarget))
    {
        SetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOR", GS_CB_BEHAVIOR_ATTACK_SPELL);

        if (Random(100) >= 25 && gsCBTalentUseTurning())           return;
        if (Random(100) >= 25 && gsCBTalentCounterMeasure())       return;
        if (Random(100) >= 25 && gsCBTalentDispelMagic(oTarget))   return;
        if (Random(100) >= 50 && gsCBTalentDragonBreath(oTarget))  return;
        if (gsCBTalentSpellAttack(oTarget))                        return;
    }

    //offensive
    SetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOR", GS_CB_BEHAVIOR_ATTACK_PHYSICAL);

    if (Random(100) >= 50 && gsCBTalentDragonWing(oTarget)) return;
    gsCBTalentAttack(oTarget);
}
//----------------------------------------------------------------
int gsCBUseTalentOnObject(talent tTalent, object oTarget = OBJECT_SELF)
{
    if (GetIsTalentValid(tTalent))
    {
        int nID = GetIdFromTalent(tTalent);

        switch (GetTypeFromTalent(tTalent))
        {
        case TALENT_TYPE_FEAT:
            return gsCBUseFeatOnObject(nID, oTarget);

        case TALENT_TYPE_SKILL:
            if (GetHasSkill(nID))
            {
                ActionUseSkill(nID, oTarget);
                return TRUE;
            }
            break;

        case TALENT_TYPE_SPELL:
            return gsCBCastSpellAtObject(GetIdFromTalent(tTalent), oTarget);
        }
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBUseFeatOnObject(int nFeat, object oTarget = OBJECT_SELF)
{
    if (gsC3VerifyFeat(nFeat, oTarget))
    {
        ActionUseFeat(nFeat, oTarget);
        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBCastSpellAtObject(int nSpell, object oTarget = OBJECT_SELF)
{
    if (gsC3VerifySpell(nSpell, oTarget))
    {
        ActionCastSpellAtObject(nSpell, oTarget);
        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentSelf(int nTalentCategorySelf,
                   int nTalentCategorySingle = FALSE,
                   int nTalentCategoryPotion = FALSE,
                   int nTalentCategoryArea   = FALSE)
{
    talent tTalent = GetCreatureTalentBest(nTalentCategorySelf, 100);

    if (! GetIsTalentValid(tTalent) && nTalentCategorySingle)
    {
        tTalent = GetCreatureTalentBest(nTalentCategorySingle, 100);

        if (! GetIsTalentValid(tTalent) && nTalentCategoryPotion)
        {
            tTalent = GetCreatureTalentBest(nTalentCategoryPotion, 100);

            if (! GetIsTalentValid(tTalent) && nTalentCategoryArea)
            {
                tTalent = GetCreatureTalentBest(nTalentCategoryArea, 100);
            }
        }
    }

    return gsCBUseTalentOnObject(tTalent);
}
//----------------------------------------------------------------
int gsCBTalentOthers(int nTalentCategoryArea,
                     int nTalentCategorySingle = FALSE)
{
    object oTarget = OBJECT_INVALID;
    talent tTalent = GetCreatureTalentBest(nTalentCategoryArea, 100);
    int nNth       = 0;
    int nCount     = 0;

    if (GetIsTalentValid(tTalent))
    {
        nNth    = 1;
        oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                     OBJECT_SELF, 1,
                                     CREATURE_TYPE_IS_ALIVE, TRUE,
                                     CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);

        while (GetIsObjectValid(oTarget) &&
               GetDistanceToObject(oTarget) <= 10.0)
        {
            nCount  = gsCBGetCreatureCountAtLocation(GetLocation(oTarget),
                                                     TRUE, FALSE, FALSE);

            if (d3() >= nCount && gsCBUseTalentOnObject(tTalent, oTarget)) return TRUE;
            if (++nNth > 3)                                                break;

            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                         OBJECT_SELF, nNth,
                                         CREATURE_TYPE_IS_ALIVE, TRUE,
                                         CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        }
    }

    if (nTalentCategorySingle)
    {
        tTalent = GetCreatureTalentBest(nTalentCategorySingle, 100);

        if (GetIsTalentValid(tTalent))
        {
            nNth    = 1;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                         OBJECT_SELF, 1,
                                         CREATURE_TYPE_IS_ALIVE, TRUE,
                                         CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);

            while (GetIsObjectValid(oTarget) &&
                   GetDistanceToObject(oTarget) <= 10.0)
            {
                if (gsCBUseTalentOnObject(tTalent, oTarget)) return TRUE;
                if (++nNth > 3)                              break;

                oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                             OBJECT_SELF, nNth,
                                             CREATURE_TYPE_IS_ALIVE, TRUE,
                                             CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
            }
        }
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentProtectSelf()
{
    return gsCBTalentSelf(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF,
                          TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE,
                          TALENT_CATEGORY_BENEFICIAL_PROTECTION_POTION,
                          TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT);
}
//----------------------------------------------------------------
int gsCBTalentProtectOthers()
{
    return gsCBTalentOthers(TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT,
                            TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE);
}
//----------------------------------------------------------------
int gsCBTalentEnhanceSelf()
{
    return gsCBTalentSelf(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SELF,
                          TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE,
                          TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_POTION,
                          TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_AREAEFFECT);
}
//----------------------------------------------------------------
int gsCBTalentEnhanceOthers()
{
    return gsCBTalentOthers(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_AREAEFFECT,
                            TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE);
}
//----------------------------------------------------------------
int gsCBTalentPersistentEffect()
{
    return gsCBTalentSelf(TALENT_CATEGORY_PERSISTENT_AREA_OF_EFFECT);
}
//----------------------------------------------------------------
int gsCBTalentHealSelf()
{
    if (gsC2GetIsDamaged() &&
        GetRacialType(OBJECT_SELF) != RACIAL_TYPE_UNDEAD)
    {
        return gsCBTalentSelf(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH,
                              FALSE,
                              TALENT_CATEGORY_BENEFICIAL_HEALING_POTION,
                              TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT);
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentHealOthers()
{
    object oTarget = gsCBGetCreatureAtLocation(
        GetLocation(OBJECT_SELF),
        TRUE, FALSE, FALSE,
        0.0, 20.0,
        RACIAL_TYPE_ALL & ~RACIAL_TYPE_UNDEAD,
        TRUE);

    if (! GetIsObjectValid(oTarget)) return FALSE;

    talent tTalent;
    int nCount     = gsCBGetCreatureCountAtLocation(
        GetLocation(oTarget),
        TRUE, FALSE, FALSE,
        0.0, 5.0,
        RACIAL_TYPE_ALL & ~RACIAL_TYPE_UNDEAD,
        TRUE);

    if (nCount > 1)
    {
        tTalent = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT, 100);
        if (! GetIsTalentValid(tTalent))
            tTalent = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, 100);
    }
    else
    {
        tTalent = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, 100);
        if (! GetIsTalentValid(tTalent))
            tTalent = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT, 100);
    }

    return gsCBUseTalentOnObject(tTalent, oTarget);
}
//----------------------------------------------------------------
int gsCBTalentCureCondition()
{
    object oTarget     = OBJECT_INVALID;
    location lLocation = GetLocation(OBJECT_SELF);

    if (GetHasSpell(SPELL_GREATER_RESTORATION)) //7
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_GREATER_RESTORATION);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_GREATER_RESTORATION, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_RESTORATION)) //4
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_RESTORATION);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_RESTORATION, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_LESSER_RESTORATION)) //2
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_LESSER_RESTORATION);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_LESSER_RESTORATION, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_STONE_TO_FLESH))
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_STONE_TO_FLESH);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_STONE_TO_FLESH, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_FREEDOM_OF_MOVEMENT)) //4
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_FREEDOM_OF_MOVEMENT);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_FREEDOM_OF_MOVEMENT, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_REMOVE_PARALYSIS)) //2
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_REMOVE_PARALYSIS);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_REMOVE_PARALYSIS, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_MIND_BLANK)) //8
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_MIND_BLANK);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_MIND_BLANK, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_LESSER_MIND_BLANK)) //5
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_LESSER_MIND_BLANK);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_LESSER_MIND_BLANK, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_CLARITY)) //2
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_CLARITY);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_CLARITY, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS)) //3
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_REMOVE_BLINDNESS_AND_DEAFNESS);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_REMOVE_FEAR)) //1
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_REMOVE_FEAR);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_REMOVE_FEAR, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_NEUTRALIZE_POISON)) //3
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_NEUTRALIZE_POISON);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_NEUTRALIZE_POISON, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_REMOVE_DISEASE)) //3
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_REMOVE_DISEASE);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_REMOVE_DISEASE, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_REMOVE_CURSE)) //3
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_REMOVE_CURSE);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_REMOVE_CURSE, oTarget))
        {
            return TRUE;
        }
    }

    return FALSE;
}
//----------------------------------------------------------------
object _gsCBTalentCureCondition(location lLocation, int nRequiredAid)
{
    return gsCBGetCreatureAtLocation(
        lLocation,
        TRUE, FALSE, FALSE,
        0.0, 20.0,
        RACIAL_TYPE_ALL,
        FALSE, nRequiredAid);
}
//----------------------------------------------------------------
int gsCBTalentCounterMeasure()
{
    object oTarget     = OBJECT_INVALID;
    location lLocation = GetLocation(OBJECT_SELF);

    if (! (gsC2GetHasEffect(EFFECT_TYPE_TRUESEEING) ||
           gsC2GetHasEffect(EFFECT_TYPE_SEEINVISIBLE)))
    {
        if (GetHasSpell(SPELL_TRUE_SEEING)) //5
        {
            oTarget = _gsCBTalentCounterMeasure(lLocation, GS_C2_TRUE_SEEING);
            if (GetIsObjectValid(oTarget) &&
                gsCBCastSpellAtObject(SPELL_TRUE_SEEING, OBJECT_SELF))
            {
                return TRUE;
            }
        }

        if (GetHasSpell(SPELL_SEE_INVISIBILITY)) //2
        {
            oTarget = _gsCBTalentCounterMeasure(lLocation, GS_C2_SEE_INVISIBILITY);
            if (GetIsObjectValid(oTarget) &&
                gsCBCastSpellAtObject(SPELL_SEE_INVISIBILITY, OBJECT_SELF))
            {
                return TRUE;
            }
        }
    }

    if (GetHasSpell(SPELL_INVISIBILITY_PURGE)) //3
    {
        oTarget = _gsCBTalentCounterMeasure(lLocation, GS_C2_INVISIBILITY_PURGE);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_SEE_INVISIBILITY, oTarget))
        {
            return TRUE;
        }
    }

    return FALSE;
}
//----------------------------------------------------------------
object _gsCBTalentCounterMeasure(location lLocation, int nCounterMeasure)
{
    return gsCBGetCreatureAtLocation(
        lLocation,
        FALSE, FALSE, TRUE,
        0.0, 10.0,
        RACIAL_TYPE_ALL,
        FALSE, FALSE, nCounterMeasure);
}
//----------------------------------------------------------------
int gsCBTalentSummonAlly(object oTarget = OBJECT_SELF)
{
    return gsCBUseTalentOnObject(
        GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_OBTAIN_ALLIES, 100),
        oTarget);
}
//----------------------------------------------------------------
int gsCBTalentUseTurning()
{
    if (GetHasFeat(FEAT_TURN_UNDEAD))
    {
        location lLocation = GetLocation(OBJECT_SELF);
        int nRace          = RACIAL_TYPE_UNDEAD;

        if (GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER))
        {
            nRace |= RACIAL_TYPE_CONSTRUCT;
        }
        if (GetHasFeat(FEAT_AIR_DOMAIN_POWER) ||
            GetHasFeat(FEAT_EARTH_DOMAIN_POWER) ||
            GetHasFeat(FEAT_FIRE_DOMAIN_POWER) ||
            GetHasFeat(FEAT_FIRE_DOMAIN_POWER))
        {
            nRace |= RACIAL_TYPE_ELEMENTAL;
        }
        if (GetHasFeat(FEAT_GOOD_DOMAIN_POWER) ||
            GetHasFeat(FEAT_EVIL_DOMAIN_POWER))
        {
            nRace |= RACIAL_TYPE_OUTSIDER;
        }
        if (GetHasFeat(FEAT_PLANT_DOMAIN_POWER) ||
            GetHasFeat(FEAT_ANIMAL_COMPANION))
        {
            nRace |= RACIAL_TYPE_VERMIN;
        }

        return gsCBGetCreatureCountAtLocation(lLocation, FALSE, FALSE, TRUE, 0.0, 10.0, nRace) &&
               gsCBUseFeatOnObject(FEAT_TURN_UNDEAD);
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentDragonBreath(object oTarget)
{
    talent tTalent    = GetCreatureTalentBest(TALENT_CATEGORY_DRAGONS_BREATH, 100);
    int nTalentID     = 0;
    int nLastTalentID = GetLocalInt(OBJECT_SELF, "GS_CB_TALENT_BREATH");

    if (GetIsTalentValid(tTalent))
    {
        nTalentID = GetIdFromTalent(tTalent);

        if (nTalentID == nLastTalentID)
        {
            tTalent   = GetCreatureTalentRandom(TALENT_CATEGORY_DRAGONS_BREATH);
            nTalentID = GetIdFromTalent(tTalent);
        }

        if (gsCBUseTalentOnObject(tTalent, oTarget))
        {
            SetLocalInt(OBJECT_SELF, "GS_CB_TALENT_BREATH", nTalentID);
            return TRUE;
        }
    }

    DeleteLocalInt(OBJECT_SELF, "GS_CB_TALENT_BREATH");
    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentDragonWing(object oTarget, int nFly = FALSE)
{
    if (GetRacialType(OBJECT_SELF) != RACIAL_TYPE_DRAGON) return FALSE;

    if (nFly)
    {
        if (GetDistanceToObject(oTarget) > RADIUS_SIZE_COLOSSAL)
        {
            ActionDoCommand(_gsCBTalentDragonWing(oTarget));
            return TRUE;
        }
    }
    else if (___gsCBTalentDragonWing(GetLocation(OBJECT_SELF)))
    {
        ActionDoCommand(__gsCBTalentDragonWing(oTarget));
        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
void _gsCBTalentDragonWing(object oObject)
{
    location lSelf     = GetLocation(OBJECT_SELF);
    location lLocation = GetLocation(oObject);
    effect eEffect     = EffectVisualEffect(VFX_IMP_PULSE_WIND);
    float fDistance    = GetDistanceToObject(oObject);
    float fDelay       = fDistance / 10.0 + 3.0;

    ClearAllActions();

    SetFacingPoint(GetPosition(oObject));
    ApplyEffectToObject(
        DURATION_TYPE_TEMPORARY,
        EffectDisappearAppear(lLocation),
        OBJECT_SELF,
        fDelay);

    if (___gsCBTalentDragonWing(lSelf))
    {
        ____gsCBTalentDragonWing(lSelf);
    }
    else
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEffect, lSelf);
    }

    if (___gsCBTalentDragonWing(lLocation))
    {
        DelayCommand(
            fDelay + 1.0,
            ____gsCBTalentDragonWing(lLocation));
    }
    else
    {
        DelayCommand(
            fDelay + 1.0,
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEffect, lLocation));
    }

    DelayCommand(fDelay + 1.5, SetCommandable(TRUE));
    DelayCommand(fDelay + 2.0, ActionAttack(oObject));

    SetCommandable(FALSE);
}
//----------------------------------------------------------------
void __gsCBTalentDragonWing(object oObject)
{
    ClearAllActions();

    ApplyEffectToObject(
        DURATION_TYPE_INSTANT,
        EffectAppear(),
        OBJECT_SELF);

    ____gsCBTalentDragonWing(GetLocation(OBJECT_SELF));

    DelayCommand(1.5, SetCommandable(TRUE));
    DelayCommand(2.0, ActionAttack(oObject));

    SetCommandable(FALSE);
}
//----------------------------------------------------------------
int ___gsCBTalentDragonWing(location lLocation)
{
    if (GetCreatureSize(OBJECT_SELF) != CREATURE_SIZE_HUGE) return FALSE;

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLocation);
    int nFlag      = FALSE;

    while (GetIsObjectValid(oTarget))
    {
        if (oTarget != OBJECT_SELF &&
            GetCreatureSize(oTarget) != CREATURE_SIZE_HUGE)
        {
            if (GetIsEnemy(oTarget)) nFlag = TRUE;
            else                     return FALSE;
        }

        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLocation);
    }

    return nFlag;
}
//----------------------------------------------------------------
void ____gsCBTalentDragonWing(location lLocation)
{
    object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLocation);
    effect eEffect   = EffectKnockdown();
    float fDistance  = 0.0;
    float fDelay     = 0.0;
    float fDuration  = RoundsToSeconds(2);
    int nHitDice     = GetHitDice(OBJECT_SELF);

    ApplyEffectAtLocation(
        DURATION_TYPE_INSTANT,
        EffectVisualEffect(VFX_IMP_PULSE_WIND),
        lLocation);

    while (GetIsObjectValid(oCreature))
    {
        if (oCreature != OBJECT_SELF &&
            GetCreatureSize(oCreature) != CREATURE_SIZE_HUGE &&
            ! FortitudeSave(oCreature, nHitDice))
        {
            fDistance = GetDistanceToObject(oCreature);
            fDelay    = fDistance / 20.0;

            if (fDistance <= RADIUS_SIZE_GARGANTUAN)
            {
                DelayCommand(fDelay,
                    ApplyEffectToObject(
                        DURATION_TYPE_INSTANT,
                        EffectDamage(Random(nHitDice) + 11, DAMAGE_TYPE_BLUDGEONING),
                        oCreature));
            }

            DelayCommand(fDelay,
                ApplyEffectToObject(
                    DURATION_TYPE_TEMPORARY,
                    eEffect,
                    oCreature,
                    fDuration));
        }

        oCreature = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLocation);
    }
}
//----------------------------------------------------------------
int gsCBTalentSpellAttack(object oTarget)
{
    talent tTalent;
    location lTarget        = GetLocation(oTarget);
    float fDistance         = GetDistanceToObject(oTarget);
    int nEnemy              = gsCBGetCreatureCountAtLocation(
                                  lTarget,
                                  FALSE, FALSE, TRUE,
                                  0.0, 10.0);
    int nFriend             = gsCBGetCreatureCountAtLocation(
                                  lTarget,
                                  TRUE, TRUE, FALSE,
                                  0.0, 10.0);
    int nAreaDiscriminant   = -1;
    int nAreaIndiscriminant = -1;
    int nSingleRanged       = -1;
    int nSingleTouch        = -1;
    int nSpell              = -1;
    int nNth                =  0;

    tTalent = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT, 100);
    if (GetIsTalentValid(tTalent))
    {
        nAreaDiscriminant   = GetIdFromTalent(tTalent);
        if (! gsC3VerifySpell(nAreaDiscriminant, oTarget))
        {
            for (nNth = 0; nNth < 2; nNth++)
            {
                tTalent             = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT);
                nAreaDiscriminant   = GetIdFromTalent(tTalent);
                if (gsC3VerifySpell(nAreaDiscriminant, oTarget)) break;
                nAreaDiscriminant   = -1;
            }
        }
    }

    if (! nFriend)
    {
        tTalent = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT, 100);
        if (GetIsTalentValid(tTalent))
        {
            nAreaIndiscriminant = GetIdFromTalent(tTalent);
            if (! gsC3VerifySpell(nAreaIndiscriminant, oTarget))
            {
                for (nNth = 0; nNth < 2; nNth++)
                {
                    tTalent             = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT);
                    nAreaIndiscriminant = GetIdFromTalent(tTalent);
                    if (gsC3VerifySpell(nAreaIndiscriminant, oTarget)) break;
                    nAreaIndiscriminant = -1;
                }
            }
        }
    }

    tTalent = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_RANGED, 100);
    if (GetIsTalentValid(tTalent))
    {
        nSingleRanged       = GetIdFromTalent(tTalent);
        if (! gsC3VerifySpell(nSingleRanged, oTarget))
        {
            for (nNth = 0; nNth < 2; nNth++)
            {
                tTalent             = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_RANGED);
                nSingleRanged       = GetIdFromTalent(tTalent);
                if (gsC3VerifySpell(nSingleRanged, oTarget)) break;
                nSingleRanged       = -1;
            }
        }
    }

    tTalent = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_TOUCH, 100);
    if (GetIsTalentValid(tTalent))
    {
        nSingleTouch        = GetIdFromTalent(tTalent);
        if (! gsC3VerifySpell(nSingleTouch, oTarget))
        {
            for (nNth = 0; nNth < 2; nNth++)
            {
                tTalent             = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_TOUCH);
                nSingleTouch        = GetIdFromTalent(tTalent);
                if (gsC3VerifySpell(nSingleTouch, oTarget)) break;
                nSingleTouch        = -1;
            }
        }
    }

    if (fDistance > 10.0)
    {
        if (nEnemy == 1) nSpell = nSingleRanged;
        if (nSpell == -1)
        {
            nSpell = nAreaIndiscriminant;
            if (nSpell == -1)
            {
                nSpell = nAreaDiscriminant;
                if (nSpell == -1)
                {
                    nSpell = nSingleRanged;
                    if (nSpell == -1) nSpell = nSingleTouch;
                }
            }
        }

        return nSpell != -1 && gsCBCastSpellAtObject(nSpell, oTarget);
    }

    if (nEnemy == 1)
    {
        if (fDistance <= 2.5) nSpell = nSingleTouch;
        if (nSpell == -1)     nSpell = nSingleRanged;
    }
    if (nSpell == -1)
    {
        nSpell = nAreaDiscriminant;
        if (nSpell == -1)
        {
            if (fDistance <= 2.5) nSpell = nSingleTouch;
            if (nSpell == -1)
            {
                nSpell = nSingleRanged;
                if (nSpell == -1) nSpell = nSingleTouch;
            }
        }
    }

    return nSpell != -1 && gsCBCastSpellAtObject(nSpell, oTarget);
}
//----------------------------------------------------------------
void gsCBTalentAttack(object oTarget)
{
    int nDistance = GetDistanceToObject(oTarget) > 5.0;

    if (nDistance) ActionEquipMostDamagingRanged(oTarget);
    else           ActionEquipMostDamagingMelee(oTarget);

    ActionDoCommand(_gsCBTalentAttack(oTarget, nDistance));
}
//----------------------------------------------------------------
void _gsCBTalentAttack(object oTarget, int nDistance)
{
    if (nDistance)
    {
        object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);

        if (! (GetIsObjectValid(oWeapon) ||
               GetWeaponRanged(oWeapon)))
        {
            ActionEquipMostDamagingMelee(oTarget);
            ActionDoCommand(_gsCBTalentAttack(oTarget, FALSE));
            return;
        }
    }

    if (Random(2))
    {
        talent tTalent = GetCreatureTalentRandom(
                             nDistance ?
                             TALENT_CATEGORY_HARMFUL_RANGED :
                             TALENT_CATEGORY_HARMFUL_MELEE);

        gsCBUseTalentOnObject(tTalent, oTarget);
    }

    ActionAttack(oTarget);
}
//----------------------------------------------------------------
int gsCBTalentFollow()
{
    if (GetLevelByClass(CLASS_TYPE_COMMONER)) return FALSE;

    object oTarget1 = OBJECT_INVALID;
    int nFlag       = FALSE;

    if (GetCurrentHitPoints() > GetMaxHitPoints() * 25 / 100)
    {
        oTarget1 = gsCBGetLastAttackTarget();

        if (GetIsObjectValid(oTarget1))
        {
            if (GetArea(oTarget1) == GetArea(OBJECT_SELF))
            {
                nFlag = TRUE;
            }
            else
            {
                object oTarget2 = GetLocalObject(OBJECT_SELF, "GS_CB_FOLLOW_TARGET");
                int nCounter    = 0;

                if (oTarget1 == oTarget2)
                    nCounter = GetLocalInt(OBJECT_SELF, "GS_CB_FOLLOW_COUNTER");

                if (nCounter < 10)
                {
                    if (! nCounter) ClearAllActions(TRUE);
                    ActionMoveToLocation(GetLocation(oTarget1), TRUE);
                    SetLocalObject(OBJECT_SELF, "GS_CB_FOLLOW_TARGET", oTarget1);
                    SetLocalInt(OBJECT_SELF, "GS_CB_FOLLOW_COUNTER", nCounter + 1);
                    return TRUE;
                }
            }
        }
    }

    DeleteLocalObject(OBJECT_SELF, "GS_CB_FOLLOW_TARGET");
    DeleteLocalInt(OBJECT_SELF, "GS_CB_FOLLOW_COUNTER");
    if (nFlag) gsCBDetermineCombatRound(oTarget1);
    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentProtectBySpell()
{
    object oPC    = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    int nInstant  = GetDistanceToObject(oPC) > 10.0;
    int nValue    = FALSE;

    //invisibility
    nValue       |= _gsCBTalentProtectBySpell(SPELL_ETHEREALNESS, nInstant) || //7
                    _gsCBTalentProtectBySpell(SPELL_IMPROVED_INVISIBILITY, nInstant) || //4
                    _gsCBTalentProtectBySpell(SPELL_INVISIBILITY_SPHERE, nInstant) || //3
                    _gsCBTalentProtectBySpell(SPELL_INVISIBILITY, nInstant) || //2
                    _gsCBTalentProtectBySpell(SPELL_SANCTUARY, nInstant); //1

    //combat protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_PREMONITION, nInstant) || //8
                    _gsCBTalentProtectBySpell(SPELL_GREATER_STONESKIN, nInstant) || //6
                    _gsCBTalentProtectBySpell(SPELL_STONESKIN, nInstant) || //4
                    _gsCBTalentProtectBySpell(SPELL_SHADES_STONESKIN, nInstant) || //4
                    _gsCBTalentProtectBySpell(SPELL_BARKSKIN, nInstant); //2

    //visage protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_SHADOW_SHIELD, nInstant) || //7
                    _gsCBTalentProtectBySpell(SPELL_ETHEREAL_VISAGE, nInstant) || //5
                    _gsCBTalentProtectBySpell(SPELL_GHOSTLY_VISAGE, nInstant) || //2
                    _gsCBTalentProtectBySpell(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE, nInstant); //2

    //mantle protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_GREATER_SPELL_MANTLE, nInstant) || //9
                    _gsCBTalentProtectBySpell(SPELL_SPELL_MANTLE, nInstant) || //7
                    _gsCBTalentProtectBySpell(SPELL_LESSER_SPELL_MANTLE, nInstant); //5

    //globe protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_GLOBE_OF_INVULNERABILITY, nInstant) || //6
                    _gsCBTalentProtectBySpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, nInstant) || //4
                    _gsCBTalentProtectBySpell(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, nInstant); //4

    //damage shield
    nValue       |= _gsCBTalentProtectBySpell(SPELL_MESTILS_ACID_SHEATH, nInstant) || //5
                    _gsCBTalentProtectBySpell(SPELL_ELEMENTAL_SHIELD, nInstant) || //4
                    _gsCBTalentProtectBySpell(SPELL_WOUNDING_WHISPERS, nInstant) || //3
                    _gsCBTalentProtectBySpell(SPELL_DEATH_ARMOR, nInstant); //2

    //elemental protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_ENERGY_BUFFER, nInstant) || //5
                    _gsCBTalentProtectBySpell(SPELL_PROTECTION_FROM_ELEMENTS, nInstant) || //3
                    _gsCBTalentProtectBySpell(SPELL_RESIST_ELEMENTS, nInstant) || //2
                    _gsCBTalentProtectBySpell(SPELL_ENDURE_ELEMENTS, nInstant); //1

    //mind protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_MIND_BLANK, nInstant) || //8
                    _gsCBTalentProtectBySpell(SPELL_LESSER_MIND_BLANK, nInstant) || //5
                    _gsCBTalentProtectBySpell(SPELL_CLARITY, nInstant); //2

    //vision
    nValue       |= _gsCBTalentProtectBySpell(SPELL_TRUE_SEEING, nInstant) || //6
                    _gsCBTalentProtectBySpell(SPELL_INVISIBILITY_PURGE, nInstant) || //3
                    _gsCBTalentProtectBySpell(SPELL_SEE_INVISIBILITY, nInstant); //2

    return nValue;
}
//----------------------------------------------------------------
int _gsCBTalentProtectBySpell(int nSpell, int nInstant = FALSE)
{
    if (gsC3VerifySpell(nSpell))
    {
        ActionCastSpellAtObject(
            nSpell,
            OBJECT_SELF,
            METAMAGIC_ANY,
            FALSE,
            0,
            PROJECTILE_PATH_TYPE_DEFAULT,
            nInstant);

        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentDispelMagic(object oTarget)
{
    int nSpell = -1;

    if (gsC2GetHasBreachableSpell(oTarget))
    {
        if (GetHasSpell(SPELL_GREATER_SPELL_BREACH))      nSpell = SPELL_GREATER_SPELL_BREACH;
        else if (GetHasSpell(SPELL_LESSER_SPELL_BREACH))  nSpell = SPELL_LESSER_SPELL_BREACH;
    }

    if (nSpell == -1 && gsC2GetEffectBalance(oTarget) > Random(4))
    {
        if (GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION)) nSpell = SPELL_MORDENKAINENS_DISJUNCTION;
        else if (GetHasSpell(SPELL_GREATER_DISPELLING))   nSpell = SPELL_GREATER_DISPELLING;
        else if (GetHasSpell(SPELL_DISPEL_MAGIC))         nSpell = SPELL_DISPEL_MAGIC;
        else if (GetHasSpell(SPELL_LESSER_DISPEL))        nSpell = SPELL_LESSER_DISPEL;
    }

    return nSpell != -1 && gsCBCastSpellAtObject(nSpell, oTarget);
}
//----------------------------------------------------------------
int gsCBTalentEvadeDarkness()
{
    int nSpell = -1;

    if (gsC2GetHasEffect(EFFECT_TYPE_DARKNESS) &&
        ! (gsC2GetHasEffect(EFFECT_TYPE_TRUESEEING) ||
           gsC2GetHasEffect(EFFECT_TYPE_ULTRAVISION)))
    {
        if (GetHasSpell(SPELL_TRUE_SEEING))                    nSpell = SPELL_TRUE_SEEING;
        else if (GetHasSpell(SPELL_DARKVISION))                nSpell = SPELL_DARKVISION;

        if (nSpell != -1 && gsCBCastSpellAtObject(nSpell))     return TRUE;

        if (GetHasSpell(SPELL_LESSER_DISPEL))                  nSpell = SPELL_LESSER_DISPEL;
        else if (GetHasSpell(SPELL_DISPEL_MAGIC))              nSpell = SPELL_DISPEL_MAGIC;
        else if (GetHasSpell(SPELL_GREATER_DISPELLING))        nSpell = SPELL_GREATER_DISPELLING;
        else if (GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION)) nSpell = SPELL_MORDENKAINENS_DISJUNCTION;

        if (nSpell != -1)
        {
            ActionCastSpellAtLocation(nSpell, GetLocation(OBJECT_SELF));
            return TRUE;
        }

        ActionMoveAwayFromLocation(GetLocation(OBJECT_SELF), TRUE, 10.0);
        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
void gsCBRequestReinforcement()
{
    DeleteLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT");

    int nValue = -gsCBGetForceBalance();

    if (nValue > 0)
    {
        if (Random(100) > 75)
        {
            switch (Random(2))
            {
            case 0: PlayVoiceChat(VOICE_CHAT_GROUP);   break;
            case 1: PlayVoiceChat(VOICE_CHAT_GUARDME); break;
            //case 2: PlayVoiceChat(VOICE_CHAT_HELP);
            }
        }

        SetLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT", nValue);
        SpeakString("GS_AI_REQUEST_REINFORCEMENT", TALKVOLUME_SILENT_TALK);
    }
}
//----------------------------------------------------------------
void gsCBSetReinforcementRequestedBy(object oObject)
{
    int nValue = GetLocalInt(oObject, "GS_CB_REINFORCEMENT");

    if (nValue > GetLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT") &&
        nValue > GetLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTED"))
    {
        SetLocalObject(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTER", oObject);
        SetLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTED", nValue);
    }
}
//----------------------------------------------------------------
int gsCBReinforce()
{
    object oObject = GetLocalObject(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTER");
    int nValue     =GetLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTED");

    DeleteLocalObject(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTER");
    DeleteLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTED");

// add check for the object being reinforced is in combat
    if (GetIsObjectValid(oObject) &&
        nValue > 0 && GetIsInCombat(oObject) &&
        GetDistanceToObject(oObject) > 10.0)
    {
        object oTarget = gsCBGetLastAttackTarget(oObject);

        if (GetIsObjectValid(oTarget))
        {
            gsCBSetAttackTarget(oTarget);
            nValue -= FloatToInt(GetChallengeRating(OBJECT_SELF) * 10.0);
            if (nValue > 0) SetLocalInt(oObject, "GS_CB_REINFORCEMENT", nValue);
            else            DeleteLocalInt(oObject, "GS_CB_REINFORCEMENT");
            return TRUE;
        }
    }

    return FALSE;
}


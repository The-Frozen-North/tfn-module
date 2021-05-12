/*

    Henchman Inventory And Battle AI

    This file contains miscellaneous functions used by
    many scripts.

*/

// void main() {    }

#include "nw_i0_generic"
#include "x0_i0_voice"
#include "inc_hai_strings"
#include "inc_hai_options"
#include "inc_hai_conv"



// This constant somewhat matches taking a henchmen hit dice and converting to CR rating
const float HENCH_HITDICE_TO_CR = 0.7;

// general effects on self
const int HENCH_HAS_ETHEREAL_EFFECT       = 0x001;
const int HENCH_HAS_CONCEALMENT_EFFECT    = 0x002;
const int HENCH_HAS_INVISIBILITY_EFFECT   = 0x004;
const int HENCH_HAS_SANTUARY_EFFECT       = 0x008;
const int HENCH_HAS_DAZED_EFFECT          = 0x010;
const int HENCH_HAS_CONFUSED_EFFECT       = 0x020;
const int HENCH_HAS_CHARMED_EFFECT        = 0x040;
const int HENCH_HAS_POLYMORPH_EFFECT      = 0x080;
const int HENCH_HAS_HASTE_EFFECT          = 0x100;
const int HENCH_HAS_TIMESTOP_EFFECT       = 0x200;


const string sHenchSummonedFamiliar = "HenchSummonedFamiliar";
const string sHenchSummonedAniComp = "HenchSummonedAniComp";
const string sHenchPseudoSummon = "HenchPseudoSummon";


const string sHenchDontAttackFlag = "DoNotAttack";
const string sHenchScoutingFlag = "Scouting";
const string sHenchScoutTarget = "ScoutTarget";
const string sHenchRunningAway = "RunningAway";


const int HENCH_HEAL_SELF_UNKNOWN   = 0;
const int HENCH_HEAL_SELF_CANT      = 1;
const int HENCH_HEAL_SELF_WAIT      = 2;
const int HENCH_HEAL_SELF_IN_PROG   = 3;
const string HENCH_HEAL_SELF_STATE  = "HenchHealSelfState";


// As MyPrintString, but to screen instead of log
void Jug_Debug(string sString);

// returns TRUE if any one of the two effect types are present
int GetHasAnyEffect2(int nEffectType1, int nEffectType2, object oTarget = OBJECT_SELF);

// returns TRUE if the target is disabled
int GetIsDisabled(object oTarget);

// returns TRUE if the target is disabled or has another effect
int GetIsDisabled1(int nOtherEffect, object oTarget);

// returns TRUE if the target is disabled or has another effect
int GetIsDisabled2(int nOtherEffect1, int nOtherEffect2, object oTarget);

// returns TRUE if racial type is a humanoid
int GetIsHumanoid(int nRacial);

// returns TRUE if creature can use items from their inventory
int GetCreatureUseItems(object oCreature);

// returns TRUE if the item property is present in any one of the equipped items
int GetCreatureHasItemProperty(int nItemProperty, object oCreature = OBJECT_SELF);

// set array access for objects
void SetObjectArray(object oSource, string sName, int iElem, object oElem);

// get array access for objects
object GetObjectArray(object oSource, string sName, int iElem);

// set array access for ints
void SetIntArray(object oSource, string sName, int iElem, int iState);

// get array access for ints
int GetIntArray(object oSource, string sName, int iElem);

// set array access for floats
void SetFloatArray(object oSource, string sName, int iElem, float fVal);

// get array access for floats
float GetFloatArray(object oSource, string sName, int iElem);

// returns TRUE if object1 and object are on opposite sides of door
int IsOnOppositeSideOfDoor(object oDoor, object obj1, object obj2);

// stores the last spell cast (no timeout)
void HenchSetLastGenericSpellCast(int nSpell);

// returns the highest level master of oAssociate
// returns OBJECT_INVALID if no master
object GetRealMaster(object oAssociate = OBJECT_SELF);

// returns the highest level master of oAssociate
// returns OBJECT_SELF if no master
object GetTopMaster(object oAssociate = OBJECT_SELF);

// converts a prestige class into the best matching primary class
int HenchConvertClass(int nClass, object oCharacter);

// returns the class type that best represents oCharacter
int HenchDetermineClassToUse(object oCharacter = OBJECT_SELF);

// Cleans all temporary values used during combat
void CleanCombatVars();



// As MyPrintString, but to screen instead of log
void Jug_Debug(string sString)
{
    SendMessageToPC(GetFirstPC(), sString);
}


int GetHasAnyEffect2(int nEffectType1, int nEffectType2, object oTarget = OBJECT_SELF)
{
    effect eCheck = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eCheck))
    {
        int nTestEffect = GetEffectType(eCheck);
        if(nTestEffect == nEffectType1)
        {
             return TRUE;
        }
        if(nTestEffect == nEffectType2)
        {
             return TRUE;
        }
        eCheck = GetNextEffect(oTarget);
    }
    return FALSE;
}


int GetIsDisabled(object oTarget)
{
    effect eCheck = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eCheck))
    {
        switch (GetEffectType(eCheck))
        {
        case EFFECT_TYPE_PARALYZE:
        case EFFECT_TYPE_STUNNED:
        case EFFECT_TYPE_FRIGHTENED:
        case EFFECT_TYPE_SLEEP:
        case EFFECT_TYPE_DAZED:
        case EFFECT_TYPE_CONFUSED:
        case EFFECT_TYPE_TURNED:
        case EFFECT_TYPE_PETRIFY:
            return TRUE;
        }

        eCheck = GetNextEffect(oTarget);
    }
    return FALSE;
}


int GetIsDisabled1(int nOtherEffect, object oTarget)
{
    effect eCheck = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eCheck))
    {
        int nTestEffect = GetEffectType(eCheck);
        switch (nTestEffect)
        {
        case EFFECT_TYPE_PARALYZE:
        case EFFECT_TYPE_STUNNED:
        case EFFECT_TYPE_FRIGHTENED:
        case EFFECT_TYPE_SLEEP:
        case EFFECT_TYPE_DAZED:
        case EFFECT_TYPE_CONFUSED:
        case EFFECT_TYPE_TURNED:
        case EFFECT_TYPE_PETRIFY:
            return TRUE;
        }
        if (nTestEffect == nOtherEffect)
        {
            return TRUE;
        }
        eCheck = GetNextEffect(oTarget);
    }
    return FALSE;
}


int GetIsDisabled2(int nOtherEffect1, int nOtherEffect2, object oTarget)
{
    effect eCheck = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eCheck))
    {
        int nTestEffect = GetEffectType(eCheck);
        switch (nTestEffect)
        {
        case EFFECT_TYPE_PARALYZE:
        case EFFECT_TYPE_STUNNED:
        case EFFECT_TYPE_FRIGHTENED:
        case EFFECT_TYPE_SLEEP:
        case EFFECT_TYPE_DAZED:
        case EFFECT_TYPE_CONFUSED:
        case EFFECT_TYPE_TURNED:
        case EFFECT_TYPE_PETRIFY:
            return TRUE;
        }
        if (nTestEffect == nOtherEffect1)
        {
            return TRUE;
        }
        if (nTestEffect == nOtherEffect2)
        {
            return TRUE;
        }
        eCheck = GetNextEffect(oTarget);
    }
    return FALSE;
}


int GetIsHumanoid(int nRacial)
{
    return
        (nRacial == RACIAL_TYPE_DWARF) ||
        (nRacial == RACIAL_TYPE_ELF) ||
        (nRacial == RACIAL_TYPE_GNOME) ||
        (nRacial == RACIAL_TYPE_HUMANOID_GOBLINOID) ||
        (nRacial == RACIAL_TYPE_HALFLING) ||
        (nRacial == RACIAL_TYPE_HUMAN) ||
        (nRacial == RACIAL_TYPE_HALFELF) ||
        (nRacial == RACIAL_TYPE_HALFORC) ||
        (nRacial == RACIAL_TYPE_HUMANOID_MONSTROUS) ||
        (nRacial == RACIAL_TYPE_HUMANOID_ORC) ||
        (nRacial == RACIAL_TYPE_HUMANOID_REPTILIAN);
}


int GetCreatureUseItems(object oCreature)
{
    if (GetIsPlayableRacialType(oCreature))
    {
        return TRUE;
    }
    int nRace = GetRacialType(oCreature);
    if ((nRace >= RACIAL_TYPE_HUMANOID_GOBLINOID && nRace <= RACIAL_TYPE_HUMANOID_REPTILIAN) ||
        nRace == RACIAL_TYPE_FEY || nRace == RACIAL_TYPE_GIANT)
    {
        return TRUE;
    }
    int nAppearanceType = GetAppearanceType(oCreature);
    if (nRace == RACIAL_TYPE_UNDEAD)
    {
        return nAppearanceType != APPEARANCE_TYPE_DRACOLICH &&
            nAppearanceType != APPEARANCE_TYPE_SKELETAL_DEVOURER &&
            nAppearanceType != APPEARANCE_TYPE_ALLIP;
    }
    if (nAppearanceType >= APPEARANCE_TYPE_DWARF && nAppearanceType <= APPEARANCE_TYPE_HUMAN)
    {
        return TRUE;
    }
    if (nRace == RACIAL_TYPE_ABERRATION)
    {
        return nAppearanceType == APPEARANCE_TYPE_MINDFLAYER ||
            nAppearanceType == APPEARANCE_TYPE_MINDFLAYER_2 ||
            nAppearanceType == APPEARANCE_TYPE_MINDFLAYER_ALHOON ||
            nAppearanceType == APPEARANCE_TYPE_DRIDER ||
            nAppearanceType == APPEARANCE_TYPE_DRIDER_CHIEF ||
            nAppearanceType == APPEARANCE_TYPE_DRIDER_FEMALE ||
            GetCreatureUseItemsOverride(oCreature);
    }
    if (nRace == RACIAL_TYPE_OUTSIDER)
    {
        return nAppearanceType == APPEARANCE_TYPE_SUCCUBUS ||
            nAppearanceType == APPEARANCE_TYPE_AZER_MALE ||
            nAppearanceType == APPEARANCE_TYPE_AZER_FEMALE ||
            nAppearanceType == APPEARANCE_TYPE_RAKSHASA_TIGER_FEMALE ||
            nAppearanceType == APPEARANCE_TYPE_RAKSHASA_TIGER_FEMALE ||
            GetCreatureUseItemsOverride(oCreature);
    }
    return GetCreatureUseItemsOverride(oCreature);
}


int GetCreatureHasItemProperty(int nItemProperty, object oCreature = OBJECT_SELF)
{
    int i;
    for (i = 0; i < NUM_INVENTORY_SLOTS; i++)
    {
        object oItem = GetItemInSlot(i, oCreature);
        if(GetItemHasItemProperty(oItem, nItemProperty))
        {
            return TRUE;
        }
    }
    return FALSE;
}


void SetObjectArray(object oSource, string sName, int iElem, object oElem)
{
    string sFull = sName+IntToString(iElem);
    SetLocalObject(oSource,sFull,oElem);
}

object GetObjectArray(object oSource, string sName, int iElem)
{
    string sFull = sName+IntToString(iElem);
    return GetLocalObject(oSource,sFull);
}

void SetIntArray(object oSource, string sName, int iElem, int iState)
{
    string sFull = sName+IntToString(iElem);
    SetLocalInt(oSource,sFull,iState);
}

int GetIntArray(object oSource, string sName, int iElem)
{
    string sFull = sName+IntToString(iElem);
    return GetLocalInt(oSource,sFull);
}

void SetFloatArray(object oSource, string sName, int iElem, float fVal)
{
    string sFull = sName+IntToString(iElem);
    SetLocalFloat(oSource,sFull,fVal);
}

float GetFloatArray(object oSource, string sName, int iElem)
{
    string sFull = sName+IntToString(iElem);
    return GetLocalFloat(oSource,sFull);
}

int IsOnOppositeSideOfDoor(object oDoor, object obj1, object obj2)
{
    float fDoorAngle = GetFacing(oDoor);

    vector vDoor = GetPositionFromLocation(GetLocation(oDoor));
    vector v1 = GetPositionFromLocation(GetLocation(obj1));
    vector v2 = GetPositionFromLocation(GetLocation(obj2));

    float fAngle1 = VectorToAngle(v1 - vDoor);
    float fAngle2 = VectorToAngle(v2 - vDoor);

    fAngle1 -= fDoorAngle;
    fAngle2 -= fDoorAngle;
    if (fAngle1 < 0.0)
    {
        fAngle1 += 360.0;
    }
    if (fAngle2 < 0.0)
    {
        fAngle2 += 360.0;
    }

    int bSide1 = fAngle1 < 90.0 || fAngle1 > 270.0;
    int bSide2 = fAngle2 < 90.0 || fAngle2 > 270.0;

    return bSide1 != bSide2;
}


void HenchSetLastGenericSpellCast(int nSpell)
{
    SetLocalInt(OBJECT_SELF, "NW_GENERIC_LAST_SPELL", nSpell);
}


//69MEH69 GetRealMaster Code
object GetRealMaster(object oAssociate = OBJECT_SELF)
{
    object oMaster = GetMaster(oAssociate);
    if (GetIsObjectValid(oMaster))
    {
        while (GetIsObjectValid(GetMaster(oMaster)))
        {
            oMaster = GetMaster(oMaster);
        }
    }
    return oMaster;
}


object GetTopMaster(object oAssociate = OBJECT_SELF)
{
    object oRetVal = oAssociate;
    object oMaster = GetMaster(oAssociate);
    while (GetIsObjectValid(oMaster))
    {
        oRetVal = oMaster;
        oMaster = GetMaster(oMaster);
    }
    return oRetVal;
}


object GetTopAssociate(object oAssociate = OBJECT_SELF)
{
    object oRetVal = oAssociate;
    object oMaster = GetMaster(oAssociate);
    if (GetIsObjectValid(oMaster))
    {
        while (GetIsObjectValid(GetMaster(oMaster)))
        {
            oRetVal = oMaster;
            oMaster = GetMaster(oMaster);
        }
    }
    return oRetVal;
}


int HenchConvertClass(int nClass, object oCharacter)
{
    switch(nClass)
    {
        case CLASS_TYPE_SHADOWDANCER:
        case CLASS_TYPE_ASSASSIN:
            return CLASS_TYPE_ROGUE;
        case CLASS_TYPE_HARPER:
        case CLASS_TYPE_ARCANE_ARCHER:
        case CLASS_TYPE_DRAGON_DISCIPLE:
            return CLASS_TYPE_BARD;
        case CLASS_TYPE_SHIFTER:
            return CLASS_TYPE_DRUID;
        case CLASS_TYPE_PALE_MASTER:
            return GetClassByPosition(1, oCharacter);
    }
    return nClass;
}


int HenchDetermineClassToUse(object oCharacter = OBJECT_SELF)
{
    int nClass;
    int nTotal = GetHitDice(oCharacter);
    if (nTotal < 1)
    {
        nTotal = 1;
    }

    int nClassLevel1 = GetLevelByPosition(1, oCharacter);
    int nClass1 =  GetClassByPosition(1, oCharacter);
    // quick exit
    if (nClassLevel1 >= nTotal)
    {
        return nClass1;
    }

    int nClassLevel2 = GetLevelByPosition(2, oCharacter);
    int nClass2 = GetClassByPosition(2, oCharacter);
    int nClassLevel3 = GetLevelByPosition(3, oCharacter);
    int nClass3 = GetClassByPosition(3, oCharacter);

    // blackguard over everthing else
    if (nClass1 == CLASS_TYPE_BLACKGUARD || nClass2 == CLASS_TYPE_BLACKGUARD ||
        nClass3 == CLASS_TYPE_BLACKGUARD)
    {
        return CLASS_TYPE_BLACKGUARD;
    }
    if (nClass1 == CLASS_TYPE_DIVINE_CHAMPION || nClass2 == CLASS_TYPE_DIVINE_CHAMPION ||
        nClass3 == CLASS_TYPE_DIVINE_CHAMPION)
    {
        return CLASS_TYPE_DIVINE_CHAMPION;
    }
    if (nClass1 == CLASS_TYPE_WEAPON_MASTER || nClass2 == CLASS_TYPE_WEAPON_MASTER ||
        nClass3 == CLASS_TYPE_WEAPON_MASTER)
    {
        return CLASS_TYPE_WEAPON_MASTER;
    }
    if (nClass1 == CLASS_TYPE_DWARVEN_DEFENDER || nClass2 == CLASS_TYPE_DWARVEN_DEFENDER ||
        nClass3 == CLASS_TYPE_DWARVEN_DEFENDER)
    {
        return CLASS_TYPE_DWARVEN_DEFENDER;
    }
    // adjust classes to remove prestige
    nClass1 = HenchConvertClass(nClass1, oCharacter);
    nClass2 = HenchConvertClass(nClass2, oCharacter);
    nClass3 = HenchConvertClass(nClass3, oCharacter);
    if (nClass1 == nClass2)
    {
        nClassLevel1 += nClassLevel2;
        nClassLevel2 = 0;
    }
    if (nClass1 == nClass3)
    {
        nClassLevel1 += nClassLevel3;
        nClassLevel3 = 0;
    }
    if (nClass2 == nClass3)
    {
        nClassLevel2 += nClassLevel3;
        nClassLevel3 = 0;
    }
    // find top class
    int nMaxClassLevel = nClassLevel1 >= nClassLevel2 ? nClassLevel1 : nClassLevel2;
    nMaxClassLevel = nMaxClassLevel >= nClassLevel3 ? nMaxClassLevel : nClassLevel3;
    // filter out classes less than two levels below the max
    if (nMaxClassLevel - 1 > nClassLevel1)
    {
        nClassLevel1 = 0;
    }
    if (nMaxClassLevel - 1 > nClassLevel2)
    {
        nClassLevel2 = 0;
    }
    if (nMaxClassLevel - 1 > nClassLevel3)
    {
        nClassLevel3 = 0;
    }
    nTotal = nClassLevel1 + nClassLevel2 + nClassLevel3;
    int nPickClass = Random(nTotal);
    nPickClass -= nClassLevel1;
    if (nPickClass < 0)
    {
        return nClass1;
    }
    nPickClass -= nClassLevel2;
    if (nPickClass < 0)
    {
        return nClass2;
    }
    return nClass3;
}


int CheckStealth()
{
    int nStealthCheck = GetLocalInt(OBJECT_SELF, "canStealth");
    if (nStealthCheck == 0)
    {
        nStealthCheck = ((GetSkillRank(SKILL_HIDE, OBJECT_SELF, TRUE) > 0) ||
            (GetSkillRank(SKILL_MOVE_SILENTLY, OBJECT_SELF, TRUE) > 0)) ? 1 : 2;
        SetLocalInt(OBJECT_SELF, "canStealth", nStealthCheck);
    }
    return nStealthCheck == 1;
}


void SetCombatMode(int nCombatMode = -1)
{
    int index;
    for (index = ACTION_MODE_PARRY; index <= ACTION_MODE_DIRTY_FIGHTING; index ++)
    {
        int bEnable = nCombatMode == index;
        if (GetActionMode(OBJECT_SELF, index) != bEnable)
        {
            if (bEnable)
            {
                ActionDoCommand(SetActionMode(OBJECT_SELF, index, TRUE));
            }
            else
            {
                SetActionMode(OBJECT_SELF, index, bEnable);
            }
        }
    }
}


const string sHenchLastAttackLocation = "HENCH_LAST_ATTACK_LOC";

void UseCombatAttack(object oTarget, int nFeatID = -1, int nCombatMode = -1)
{
    SetCombatMode(nCombatMode);
    if (nFeatID < 0)
    {
        ActionAttack(oTarget);
    }
    else
    {
        ActionUseFeat(nFeatID, oTarget);
    }
    SetLocalLocation(OBJECT_SELF, sHenchLastAttackLocation, GetLocation(OBJECT_SELF));
//const string sHenchLastAttackLocation = "HENCH_LAST_ATTACK_LOC";

}


const string henchCombatRoundStr = "tkCombatRoundCount";
const string henchLastDraBrStr = "tkLastDragonBreath";
const string henchLastDispelStr = "tkLastDispel";
const string henchLastDomStr = "tkLastDominate";
const string henchLastTurnStr = "tkLastTurning";
const string henchSpellKnownFlagsStr = "HenchSpellKnownFlags";
const string henchNoAttackSpStr = "tkNoAttackSpellTalents";
const string henchNoEnhanceSpStr = "tkNoEnhanceSpellTalents";
const string henchNoCondSpStr = "tkNoConditionalSpellTalents";
const string henchNoPotionStr = "tkNoPotions";
const string henchBuffCountStr = "HenchCurBuffCount";
const string henchHealCountStr = "HenchCurHealCount";
const string sHenchLastTarget = "LastTarget";
const string sHenchShouldIAttackMessageGiven = "HenchShouldIAttackMessageGiven";


const int HENCH_MAIN_SPELL_SERIES   = 0x1;
const int HENCH_CURE_COND_SPELL     = 0x2;

int GetSpellUnknownFlag(int flag)
{
    return GetLocalInt(OBJECT_SELF, henchSpellKnownFlagsStr) & flag;
}


void SetSpellUnknownFlag(int flag)
{
    SetLocalInt(OBJECT_SELF, henchSpellKnownFlagsStr, GetLocalInt(OBJECT_SELF, henchSpellKnownFlagsStr) | flag);
}


void CleanCombatVars()
{
    DeleteLocalInt(OBJECT_SELF, henchCombatRoundStr);
    DeleteLocalInt(OBJECT_SELF, henchLastDraBrStr);
    DeleteLocalInt(OBJECT_SELF, henchLastDispelStr);
    DeleteLocalInt(OBJECT_SELF, henchLastDomStr);
    DeleteLocalInt(OBJECT_SELF, henchLastTurnStr);
    DeleteLocalInt(OBJECT_SELF, henchSpellKnownFlagsStr);
    DeleteLocalInt(OBJECT_SELF, henchNoAttackSpStr);
    DeleteLocalInt(OBJECT_SELF, henchNoEnhanceSpStr);
    DeleteLocalInt(OBJECT_SELF, henchNoCondSpStr);
    DeleteLocalInt(OBJECT_SELF, henchNoPotionStr);
    DeleteLocalInt(OBJECT_SELF, "CloseRangeEnhanced");
    DeleteLocalObject(OBJECT_SELF, sHenchLastTarget);
    DeleteLocalLocation(OBJECT_SELF, sHenchLastAttackLocation);
    DeleteLocalInt(OBJECT_SELF, sHenchShouldIAttackMessageGiven);
}


void ReportUnseenAllies()
{
    location testTargetLoc = GetLocation(OBJECT_SELF);
    object oAllyTest = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, testTargetLoc, TRUE, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oAllyTest))
    {
        if (!GetObjectSeen(oAllyTest) && GetIsPC(GetTopMaster(oAllyTest)))
        {
            SpeakString(sHenchCantSeeTarget + GetName(oAllyTest));
        }
        oAllyTest = GetNextObjectInShape(SHAPE_SPHERE, 20.0, testTargetLoc, TRUE, OBJECT_TYPE_CREATURE);
    }
}


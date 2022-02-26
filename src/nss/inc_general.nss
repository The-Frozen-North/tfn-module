#include "inc_sql"
#include "nwnx_creature"
#include "nwnx_effect"

const float MORALE_RADIUS = 30.0;
const float REMAINS_DECAY = 120.0;

// Makes the killer play a voice sometimes. Won't work if the killer is a PC or if the killer was not hostile.
void KillTaunt(object oKiller, object oKilled);

// Copies the item to an existing object's inventory. Does not copy if target does not exist.
// Will copy vars, and return the new item.
object CopyItemToExistingTarget(object oItem, object oTarget);

object CopyItemToExistingTarget(object oItem, object oTarget)
{
    if (GetIsObjectValid(oTarget))
    {
        return CopyItem(oItem, oTarget, TRUE);
    }
    else
    {
        return OBJECT_INVALID;
    }
}

void KillTaunt(object oKiller, object oKilled)
{
    if (GetIsPC(oKiller)) return;

    if (!GetIsReactionTypeHostile(oKilled, oKiller)) return;

    int nRandom = d4();

    float fDelay = 1.25;

    switch (nRandom)
    {
       case 1: DelayCommand(fDelay, PlayVoiceChat(VOICE_CHAT_THREATEN, oKiller)); break;
       case 2: DelayCommand(fDelay, PlayVoiceChat(VOICE_CHAT_LAUGH, oKiller)); break;
       case 3: DelayCommand(fDelay, PlayVoiceChat(VOICE_CHAT_CHEER, oKiller)); break;
    }
}

void RemoveDeathEffectPenalty(object oCreature)
{
    effect eEffect = GetFirstEffect(oCreature);

// Remove all penalty effects
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectTag(eEffect) == "death_penalty")
            RemoveEffect(oCreature, eEffect);

        eEffect = GetNextEffect(oCreature);
    }
}

int GetTimesRevived(object oCreature)
{
    int nTimesDied = 0;

    if (GetIsPC(oCreature))
    {
        nTimesDied = SQLocalsPlayer_GetInt(oCreature, "times_died");
    }
    else
    {
        nTimesDied = GetLocalInt(oCreature, "times_died");
    }

    return nTimesDied;
}

void DetermineDeathEffectPenalty(object oCreature, int nCurrentHP = 0)
{
    effect eEffect = GetFirstEffect(oCreature);

    RemoveDeathEffectPenalty(oCreature);

    int nTimesDied = GetTimesRevived(oCreature);

// Don't do anything else if they hadn't actually died
    if (nTimesDied == 0)
        return;

    effect ePenalty = SupernaturalEffect(EffectAbilityDecrease(ABILITY_CONSTITUTION, nTimesDied*(GetAbilityScore(oCreature, ABILITY_CONSTITUTION, TRUE)/4)));
    TagEffect(ePenalty, "death_penalty");

    if (nCurrentHP == 0)
        nCurrentHP = GetCurrentHitPoints(oCreature);

// Restore all HP because con loss can cause them to die
    SetCurrentHitPoints(oCreature, GetMaxHitPoints(oCreature));

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePenalty, oCreature);

    SetCurrentHitPoints(oCreature, nCurrentHP);
}

int IsCreatureRevivable(object oCreature)
{
    int nTimesDied = GetTimesRevived(oCreature);

    if (nTimesDied >= 4)
    {
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

void SendMessageToAllPCs(string sMessage)
{
    object oPC = GetFirstPC();

    while (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, sMessage);
        oPC = GetNextPC();
    }
}

void DoMoraleCry(object oCreature)
{
     if (GetIsDead(oCreature)) return;
     if (GetLocalInt(oCreature, "morale_cried") == 1) return;

     SetLocalInt(oCreature, "morale_cried", 1);

     switch (d6())
     {
         case 1: PlayVoiceChat(VOICE_CHAT_HELP, oCreature); break;
         case 2: PlayVoiceChat(VOICE_CHAT_FLEE, oCreature); break;
         case 3: PlayVoiceChat(VOICE_CHAT_NEARDEATH, oCreature); break;
         case 4:
            if (GetCurrentHitPoints(oCreature) <= GetMaxHitPoints(oCreature)/2)
                PlayVoiceChat(VOICE_CHAT_HEALME, oCreature);
         break;
     }

     DelayCommand(30.0, DeleteLocalInt(oCreature, "morale_cried"));
}

void DoMoraleCheck(object oCreature, int nDC = 10)
{
    if (GetIsDead(oCreature)) return;
    if (GetIsPC(oCreature)) return;
    if (GetLocalInt(oCreature, "morale_checked") == 1) return;

    switch (GetRacialType(oCreature))
    {
        case RACIAL_TYPE_UNDEAD:
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_OOZE:
            return;
        break;
    }

    SetLocalInt(oCreature, "morale_checked", 1);

    location lLocation = GetLocation(oCreature);
    int nFriendlies = 0;
    int nEnemies = 0;
    float fRadius = MORALE_RADIUS;

    object oNearbyCreature = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oNearbyCreature))
    {
        if (oNearbyCreature != oCreature && !GetIsDead(oCreature))
        {
            if (GetLocalInt(oNearbyCreature, "herbivore") == 1 || GetClassByPosition(1, oNearbyCreature) == CLASS_TYPE_COMMONER)
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), oCreature, IntToFloat(d3(2)));
                DelayCommand(IntToFloat(d10())/10.0, DoMoraleCry(oCreature));
            }
            else if (GetIsFriend(oNearbyCreature, oCreature))
            {
                nFriendlies = nFriendlies + 2;
            }
            else if (GetIsEnemy(oNearbyCreature, oCreature))
            {
                nEnemies = nEnemies + 2;
            }
        }
        oNearbyCreature = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    }

// these things will always morale cry
    if (GetLocalInt(oCreature, "herbivore") == 1 || GetClassByPosition(1, oCreature) == CLASS_TYPE_COMMONER)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), oCreature, IntToFloat(d3(2)));
        DelayCommand(IntToFloat(d10())/10.0, DoMoraleCry(oCreature));
        return;
    }

    int nDifference = nEnemies - nFriendlies;

// if they have at least 3 allies over the player, never run
    if (nDifference <= -6) return;

    nDC = nDC + nDifference - GetHitDice(oCreature);

    if (nDC < 1) nDC = 1;

    if (WillSave(oCreature, nDC, SAVING_THROW_TYPE_FEAR) == 0)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), oCreature, IntToFloat(d3(2)));
        DelayCommand(IntToFloat(d10())/10.0, DoMoraleCry(oCreature));
    }

    DelayCommand(5.0, DeleteLocalInt(oCreature, "morale_checked"));
}

void DoMoraleCheckSphere(object oCreature, int nDC = 10, float fRadius = MORALE_RADIUS)
{
    location lLocation = GetLocation(oCreature);

    object oNearbyCreature = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oNearbyCreature))
    {
        if (oNearbyCreature != oCreature && !GetIsDead(oNearbyCreature) && GetIsFriend(oCreature, oNearbyCreature)) DoMoraleCheck(oNearbyCreature, nDC);

        oNearbyCreature = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    }
}

void PlayNonMeleePainSound(object oDamager)
{
    if (GetIsDead(OBJECT_SELF)) return;

    int nWeaponDamage = GetDamageDealtByType(DAMAGE_TYPE_BASE_WEAPON);

    int bRanged = GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oDamager));

    if (bRanged || nWeaponDamage == -1)
    {
        switch (d6())
        {
            case 1: PlayVoiceChat(VOICE_CHAT_PAIN1); break;
            case 2: PlayVoiceChat(VOICE_CHAT_PAIN2); break;
            case 3: PlayVoiceChat(VOICE_CHAT_PAIN3); break;
        }
    }
}

void PrepareForElementalDeath(string sScript, object oCreature)
{
    NWNX_Creature_OverrideDamageLevel(oCreature, 5);
    NWNX_Creature_SetNoPermanentDeath(OBJECT_SELF, FALSE);

    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");

    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, sScript);
}

void DoSpasm(object oCreature)
{
    PlayVoiceChat(13+d3(), oCreature);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_HIT_ELECTRICAL, FALSE, 0.3*IntToFloat(GetCreatureSize(oCreature))), oCreature);
}

void RotAway(object oCreature)
{
    SetObjectVisualTransform(oCreature, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, GetPosition(oCreature).z-10.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR, 30.0);
    DestroyObject(oCreature, 10.0);
}

int Gibs(object oCreature, int bForce = FALSE)
{
    int nHP = GetCurrentHitPoints(oCreature);

    if (GetCreatureSize(oCreature) == CREATURE_SIZE_HUGE) return FALSE;
    if (!bForce && !(nHP <= -11 && nHP <= -(GetMaxHitPoints(oCreature)/2))) return FALSE;
    if (GetLocalInt(oCreature, "gibbed") == 1) return FALSE;

    int nAppearanceType = GetAppearanceType(oCreature);

    string sBlood = Get2DAString("appearance", "BLOODCOLR", GetAppearanceType(oCreature));

    location lLocation = GetLocation(oCreature);

    int nGib;
    if (sBlood == "R")
    {
        nGib = VFX_COM_CHUNK_RED_MEDIUM;

        PlaySound("bf_med_insect");
    }
    else if (sBlood == "Y")
    {
        nGib = VFX_COM_CHUNK_YELLOW_MEDIUM;
        PlaySound("bf_med_insect");
    }
    else if (sBlood == "G")
    {
        nGib = VFX_COM_CHUNK_GREEN_MEDIUM;
        PlaySound("bf_med_insect");
    }
    else if (sBlood == "W")
    {
        nGib = VFX_COM_CHUNK_BONE_MEDIUM;
        PlaySound("bf_med_bone");
    }
    else
    {
        return FALSE;
    }

    if (!GetIsPC(oCreature))
    {
        SetObjectVisualTransform(oCreature, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -500.0);
        SetObjectVisualTransform(oCreature, OBJECT_VISUAL_TRANSFORM_SCALE, 0.01);
    }

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(nGib), lLocation);

    return TRUE;
}

int GibsNPC(object oCreature)
{
    int iCold = GetDamageDealtByType(DAMAGE_TYPE_COLD);
    int iAcid = GetDamageDealtByType(DAMAGE_TYPE_ACID);
    int iElectric = GetDamageDealtByType(DAMAGE_TYPE_ELECTRICAL);
    int iFire = GetDamageDealtByType(DAMAGE_TYPE_FIRE);
    int iNegative = GetDamageDealtByType(DAMAGE_TYPE_NEGATIVE);
    int iDivine = GetDamageDealtByType(DAMAGE_TYPE_DIVINE);
    int iPositive = GetDamageDealtByType(DAMAGE_TYPE_POSITIVE);
    int iPhysical = GetDamageDealtByType(DAMAGE_TYPE_PIERCING)+GetDamageDealtByType(DAMAGE_TYPE_BLUDGEONING)+GetDamageDealtByType(DAMAGE_TYPE_SLASHING);
    int iMagic = GetDamageDealtByType(DAMAGE_TYPE_MAGICAL);

    object oModule = GetModule();
    location lLocation = GetLocation(oCreature);
    int nSize = GetCreatureSize(oCreature);
    float fSize = IntToFloat(nSize);

    int nMaxHP = GetMaxHitPoints(oCreature);

    int bNoElementalDeath = d4() == 1;

    if (!bNoElementalDeath && (iCold > 0) && (iCold >= Random(nMaxHP)) && (nSize < CREATURE_SIZE_HUGE) && (iCold > iAcid) && (iCold > iElectric) && (iCold > iFire) && (iCold > iNegative) && (iCold > iDivine) && (iCold > iPositive) && (iCold > iMagic))
    {
        NWNX_Creature_SetSoundset(oCreature, 9999);
        PrepareForElementalDeath("death_cold", oCreature);

        DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oCreature));
        DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_ICESKIN), oCreature));
        DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION), oCreature));
        DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectCutsceneImmobilize(), oCreature));
        DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectParalyze(), oCreature));
        DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectCutsceneParalyze(), oCreature));
        DelayCommand(IntToFloat(d4(2)), ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(TRUE, FALSE), oCreature));

        return TRUE;
    }
    else if (!bNoElementalDeath && (iAcid > 0) && (iAcid >= Random(nMaxHP)) && (nSize < CREATURE_SIZE_HUGE) && (iAcid > iCold) && (iAcid > iElectric) && (iAcid > iFire) && (iAcid > iNegative) && (iAcid > iDivine) && (iAcid > iPositive) && (iAcid > iMagic))
    {
        object oCloud = CreateObject(OBJECT_TYPE_PLACEABLE, "_cloud_acid", lLocation);
        object oRemains = CreateObject(OBJECT_TYPE_PLACEABLE, "_remains_acid", lLocation);
        SetObjectVisualTransform(oRemains, OBJECT_VISUAL_TRANSFORM_SCALE, 0.3*fSize);
        SetObjectVisualTransform(oCloud, OBJECT_VISUAL_TRANSFORM_SCALE, 0.2*fSize);
        AssignCommand(oRemains, SetFacing(IntToFloat(Random(360))));

        AssignCommand(oModule, DelayCommand(0.1, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_ACID_S, FALSE, 0.3*fSize), lLocation)));
        AssignCommand(oModule, DelayCommand(REMAINS_DECAY/2.0, DestroyObject(oCloud)));
        AssignCommand(oModule, DelayCommand(REMAINS_DECAY, DestroyObject(oRemains)));

        DelayCommand(3.0, RotAway(oCreature));

        SetLocalInt(oCreature, "gibbed", 1);
        return TRUE;
    }
    else if (!bNoElementalDeath && (iElectric > 0) && (iElectric >= Random(nMaxHP)) && (nSize < CREATURE_SIZE_HUGE) && (iElectric > iCold) && (iElectric > iAcid) && (iElectric > iFire) && (iElectric > iNegative) && (iElectric > iDivine) && (iElectric > iPositive) && (iElectric > iMagic))
    {
        PrepareForElementalDeath("death_electric", oCreature);

        DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oCreature));
        DelayCommand(0.15, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectCutsceneImmobilize(), oCreature));
        //DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectParalyze(), oCreature));
        //DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectCutsceneParalyze(), oCreature));
        DelayCommand(0.17, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION), oCreature, 0.01));
        DelayCommand(0.2, AssignCommand(oCreature, ActionPlayAnimation(ANIMATION_LOOPING_SPASM, 2.0, 15.0)));
        DelayCommand(0.3, AssignCommand(oCreature, ActionPlayAnimation(ANIMATION_LOOPING_SPASM, 2.0, 15.0)));
        DelayCommand(0.4, AssignCommand(oCreature, ActionPlayAnimation(ANIMATION_LOOPING_SPASM, 2.0, 15.0)));
        DelayCommand(2.0+IntToFloat(d2(1)), ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(TRUE, FALSE), oCreature));

        AssignCommand(oModule, DelayCommand(0.6+(IntToFloat(d10(5))*0.01), DoSpasm(oCreature)));
        AssignCommand(oModule, DelayCommand(1.0+(IntToFloat(d10(5))*0.01), DoSpasm(oCreature)));
        AssignCommand(oModule, DelayCommand(1.4+(IntToFloat(d10(5))*0.01), DoSpasm(oCreature)));
        AssignCommand(oModule, DelayCommand(1.8+(IntToFloat(d10(5))*0.01), DoSpasm(oCreature)));
        AssignCommand(oModule, DelayCommand(2.2+(IntToFloat(d10(5))*0.01), DoSpasm(oCreature)));

        return TRUE;
    }
    else if (!bNoElementalDeath && (iFire > 0) && (iFire >= Random(nMaxHP)) && (nSize < CREATURE_SIZE_HUGE) && (iFire > iCold) && (iFire > iElectric) && (iFire > iAcid) && (iFire > iNegative) && (iFire > iDivine) && (iFire > iPositive) && (iFire > iMagic))
    {
        object oRemains = CreateObject(OBJECT_TYPE_PLACEABLE, "_remains_fire"+IntToString(nSize), lLocation);
        AssignCommand(oRemains, SetFacing(IntToFloat(Random(360))));

        AssignCommand(oModule, DelayCommand(0.1, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FLAME_M, FALSE, 0.3*fSize), lLocation)));
        AssignCommand(oModule, DelayCommand(REMAINS_DECAY/2.0, DestroyObject(oRemains)));

        if (!Gibs(oCreature))
        {
            SetObjectVisualTransform(oCreature, OBJECT_VISUAL_TRANSFORM_SCALE, 0.01);
            SetObjectVisualTransform(oCreature, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -500.0);
        }

        SetLocalInt(oCreature, "gibbed", 1);
        return TRUE;
    }
    else if (Gibs(oCreature))
    {
// Prevent gibs from happening more than once in the case of many APR.
        SetLocalInt(oCreature, "gibbed", 1);
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

// This function determines the AC from the armor given
int GetBaseArmorAC(object oArmor);
int GetBaseArmorAC(object oArmor)
{
  return
  StringToInt
  (
    Get2DAString
    (
      "parts_chest",
      "ACBONUS",
      GetItemAppearance(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_TORSO)
    )
  );
}

//void main(){}

#include "nwnx_creature"
//#include "inc_debug"

// returns true if the creature is mounted
// checks appearance type for determination
int GetIsMounted(object oPC);
int GetIsMounted(object oPC)
{
    int nAppearance = GetAppearanceType(oPC);
    if (nAppearance >= 482 && nAppearance <= 495)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

int GetRidingSpellFailure(object oPC)
{
    int nSpellFailure = 30;
    int nRideSpellBonus = GetSkillRank(SKILL_RIDE, oPC) / 5;
    nSpellFailure = nSpellFailure - (10 * nRideSpellBonus);

    return nSpellFailure;
}

// applies horse effects when mounted
void DetermineHorseEffects(object oPC);
void DetermineHorseEffects(object oPC)
{
    if (GetIsDead(oPC)) return;

    /*
    if (GetIsPC(oPC))
    {
        SendDebugMessage("movement rate factor "+FloatToString(NWNX_Creature_GetMovementRateFactor(oPC)));
        SendDebugMessage("movement rate "+IntToString(GetMovementRate(oPC)));
    }
    */

// always remove the effect, it can be applied again if mounted
    effect eEffect = GetFirstEffect(oPC);
    while(GetIsEffectValid(eEffect))
    {
        if(GetEffectTag(eEffect) == "horse_effects")
            RemoveEffect(oPC, eEffect);

        eEffect = GetNextEffect(oPC);
    }

   int nRide = GetSkillRank(SKILL_RIDE, oPC);
   int nSpeedBonus = 70 + nRide;
   if (nSpeedBonus > 99)
        nSpeedBonus = 99;

// don't continue if not mounted
    if (!GetIsMounted(oPC))
    {
        /*
        float fMovementCap = 1.5;
        int nMonkSpeed = GetLevelByClass(CLASS_TYPE_MONK, oPC) / 3;
        if (nMonkSpeed > 0)
        {
            fMovementCap = fMovementCap + (IntToFloat(nMonkSpeed) / 10.0);
        }
        else if (GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC))
        {
            fMovementCap = fMovementCap + 0.1;
        }

        NWNX_Creature_SetMovementRateFactorCap(oPC, fMovementCap);
        */

        // reset to default movement cap
        NWNX_Creature_SetMovementRateFactorCap(oPC, -1.0);
        return;
    }
    else
    {
        NWNX_Creature_SetMovementRate(oPC, 5);
        NWNX_Creature_SetMovementRateFactorCap(oPC, 1.0 + (IntToFloat(nSpeedBonus) / 100.0));
    }

    int nACPenalty = 2;
    int nACBonus = 0;
    int nSpellFailure = GetRidingSpellFailure(oPC);

// remove any AC bonus from tumble
    int nTumbleBonus = GetSkillRank(SKILL_TUMBLE, oPC, TRUE) / 5;
    if (nTumbleBonus > 0)
        nACPenalty = nACPenalty + nTumbleBonus;

// determine AC bonus from riding skill if they have the feat
    if (GetHasFeat(FEAT_MOUNTED_COMBAT, oPC))
        nACBonus = (nRide + d20()) / 5;

    effect eLink = EffectLinkEffects(EffectACDecrease(nACPenalty), EffectMovementSpeedIncrease(nSpeedBonus));

// determine ab penalties
    int nABPenalty = 1;
    if (GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC)))
    {
       nABPenalty = 4;

       if (GetHasFeat(FEAT_MOUNTED_ARCHERY, oPC))
            nABPenalty = 2;
    }
    eLink = EffectLinkEffects(EffectAttackDecrease(nABPenalty), eLink);

// no tumblin' on a mount
    eLink = EffectLinkEffects(EffectSkillDecrease(SKILL_TUMBLE, 50), eLink);

    if (nACBonus > 0)
        eLink = EffectLinkEffects(EffectACIncrease(nACBonus), eLink);

    if (nSpellFailure > 0)
        eLink = EffectLinkEffects(EffectSpellFailure(nSpellFailure), eLink);

    eLink = TagEffect(SupernaturalEffect(eLink), "horse_effects");
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oPC);
}

// dismounts creature
void RemoveMount(object oPC);
void RemoveMount(object oPC)
{
// only play sound and visuals if already mounted
    if (GetIsMounted(oPC))
    {
        PlaySound("c_horse_slct");
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1), GetLocation(oPC));
    }

    switch (GetRacialType(oPC))
    {
        case RACIAL_TYPE_DWARF: SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_DWARF); break;
        case RACIAL_TYPE_ELF: SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_ELF); break;
        case RACIAL_TYPE_GNOME: SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_GNOME); break;
        case RACIAL_TYPE_HALFLING: SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_HALFLING); break;
        case RACIAL_TYPE_HALFELF: SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_HALF_ELF); break;
        case RACIAL_TYPE_HALFORC: SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_HALF_ORC); break;
        case RACIAL_TYPE_HUMAN: SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_HUMAN); break;
    }

    int nPheno = GetPhenoType(oPC);
    if (nPheno == 0 || nPheno == 3) {SetPhenoType(0, oPC);}
    else if (nPheno == 5 || nPheno == 2) {SetPhenoType(2, oPC);}

    SetCreatureTailType(0, oPC);

    SetFootstepType(FOOTSTEP_TYPE_DEFAULT, oPC);
    DetermineHorseEffects(oPC);
}

void ApplyMount(object oPC, int nHorse = 0)
{

// use the current tail if one isn't provided (cases where we are just re-applying)
    if (nHorse == 0) nHorse = GetCreatureTailType(oPC);

// check valid horse
    if (!(nHorse >= 15 && nHorse <= 80)) return;

    if (GetLocalInt(GetArea(oPC), "horse") != 1)
    {
        FloatingTextStringOnCreature("*You cannot mount a horse in this location.*", oPC, FALSE);
        return;
    }

// males are one higher appearance.2da
    int nGender = 0;
    if (GetGender(oPC) == GENDER_MALE) nGender = 1;

    int nAppearanceType = GetAppearanceType(oPC);

// only play sound and visuals if not already mounted
    if (!GetIsMounted(oPC))
    {
        PlaySound("c_horse_bat"+IntToString(d2()));
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1), GetLocation(oPC));
        //AssignCommand(oPC, PlaySound("c_horse_bat"+IntToString(d2())));
    }

    switch (GetRacialType(oPC))
    {
        case RACIAL_TYPE_DWARF: SetCreatureAppearanceType(oPC, 482+nGender); break;
        case RACIAL_TYPE_ELF: SetCreatureAppearanceType(oPC, 484+nGender); break;
        case RACIAL_TYPE_GNOME: SetCreatureAppearanceType(oPC, 486+nGender); break;
        case RACIAL_TYPE_HALFLING: SetCreatureAppearanceType(oPC, 488+nGender); break;
        case RACIAL_TYPE_HALFELF: SetCreatureAppearanceType(oPC, 490+nGender); break;
        case RACIAL_TYPE_HALFORC: SetCreatureAppearanceType(oPC, 492+nGender); break;
        case RACIAL_TYPE_HUMAN: SetCreatureAppearanceType(oPC, 494+nGender); break;
    }

    int nPheno = GetPhenoType(oPC);
    if (nPheno == 0 || nPheno == 3)
    {
        SetPhenoType(3, oPC);
    }
    else if (nPheno == 5 || nPheno == 2)
    {
        SetPhenoType(5, oPC);
    }

    if (nHorse >= 15 && nHorse <= 80) SetCreatureTailType(nHorse, oPC);

    SetFootstepType(FOOTSTEP_TYPE_DEFAULT, oPC);

    SendMessageToPC(oPC, "Riding Applies: Skill Riding Check: "+IntToString(GetSkillRank(SKILL_RIDE, oPC) / 5)+" Spell Failure: "+IntToString(GetRidingSpellFailure(oPC))+"%");
    DetermineHorseEffects(oPC);
}

void ValidateMount(object oPC)
{
    if (GetIsMounted(oPC) && GetLocalInt(GetArea(oPC), "horse") != 1)
    {
        RemoveMount(oPC);
        return;
    }
}

//void main(){}

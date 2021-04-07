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
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_2), GetLocation(oPC));
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

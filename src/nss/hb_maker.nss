// The Maker (demilich) HB script
// Deals with bone golem animation

#include "inc_ai_combat"

object DestroyBonepileAndReturnLastBone(object oParent, float fDelay)
{
    object oBone;
    int i = 1;
    do
    {
        oBone = GetLocalObject(oParent, "bonecomponent" + IntToString(i));
        SetPlotFlag(oBone, 0);
        DestroyObject(oBone, fDelay);
        i++;
    } while (GetIsObjectValid(oBone));
    DestroyObject(oParent, fDelay);
    object oSparks = GetLocalObject(oParent, "sparkvfx");
    SetPlotFlag(oSparks, 0);
    DestroyObject(oSparks, fDelay);
    oBone = GetLocalObject(oParent, "bonecomponent"+IntToString(i-2));
    return oBone;
}

void MakeGolemCreature(location lLoc)
{
    object oGolem = CreateObject(OBJECT_TYPE_CREATURE, "maker_bonegolem", lLoc, FALSE, "maker_bonegolem");
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, 100)), oGolem);
    object oArea = GetAreaFromLocation(lLoc);
    json jGolems = GetLocalJson(oArea, "maker_golems");
    jGolems = JsonArrayInsert(jGolems, JsonString(ObjectToString(oGolem)));
    SetLocalJson(oArea, "maker_golems", jGolems);
    AssignCommand(oGolem, DelayCommand(2.0, gsCBDetermineCombatRound(gsCBGetAttackTarget())));
}

void MakeANewGolem()
{
    // This is wrapped in DelayCommand, killing the maker between the two firing could be bad
    if (GetIsDead(OBJECT_SELF))
    {
        return;
    }
    // Find closest bonepile!
    object oArea = GetObjectByTag("ud_maker4");
    float fDist = 9999.0;
    object oClosest;
    int i;
    int nNumBonepiles = GetLocalInt(oArea, "num_bonepiles");
    for (i=1; i<=nNumBonepiles; i++)
    {
        object oBonepile = GetLocalObject(oArea, "maker_bonepile" + IntToString(i));
        if (GetIsObjectValid(oBonepile))
        {
            float fThisDist = GetDistanceBetween(oBonepile, OBJECT_SELF);
            if (fThisDist < fDist)
            {
                oClosest = oBonepile;
                fDist = fThisDist;
            }
        }
    }
    if (GetIsObjectValid(oClosest))
    {
        location lGolem = GetLocation(oClosest);
        object oTopBone = DestroyBonepileAndReturnLastBone(oClosest, 1.0);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_EVIL, OBJECT_SELF, BODY_NODE_CHEST), oTopBone, 1.0);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_PWKILL, FALSE, 0.25), GetLocation(oClosest));
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD, FALSE, 1.5), GetLocation(oClosest));
        DelayCommand(1.1, MakeGolemCreature(lGolem));
    }
}

void main()
{
    if (!GetIsInCombat() || GetIsDead(OBJECT_SELF))
    {
        return;
    }
    int nDR = 0;
    int nHP = GetCurrentHitPoints();
    int nLastHP = GetLocalInt(OBJECT_SELF, "last_hp");
    if (nLastHP == 0)
        nLastHP = GetMaxHitPoints();
    int nLastDR = GetLocalInt(OBJECT_SELF, "last_dr");
    effect eTest = GetFirstEffect(OBJECT_SELF);
    while (GetIsEffectValid(eTest))
    {
        if (GetEffectType(eTest) == EFFECT_TYPE_DAMAGE_RESISTANCE)
        {
            nDR += GetEffectInteger(eTest, 2);
        }
        eTest = GetNextEffect(OBJECT_SELF);
    }
    SetLocalInt(OBJECT_SELF, "last_hp", nHP);
    SetLocalInt(OBJECT_SELF, "last_dr", nDR);
    int nHPDelta = nLastHP - nHP;
    if (nHPDelta <= 0) { nHPDelta = 0; }
    int nDRDelta = nLastDR - nDR;
    if (nDRDelta <= 0) { nDRDelta = 0; }
    
    //SpeakString("HP delta " + IntToString(nHPDelta) + " DR delta " + IntToString(nDRDelta) + ", current values " + IntToString(nHP) + " " + IntToString(nDR));

    // This is deliberately built to make doing damage
    // to the maker rapidly cause him to be more inclined to make golems

    // It should, hopefully, make parties that struggle to damage him
    // (and have to survive his own stuff for longer)
    // have an easier time of things than they would otherwise
    // if golem creation were simply hp threshold or time based

    // Actual HP damage counts for more
    // Dispelling premonition/stoneskin will count as a massive damage spike...
    int nEHPDelta = nHPDelta*2 + nDRDelta;
    

    int nGolemPoints = FloatToInt(pow(IntToFloat(nEHPDelta), 1.4));
    int nOldGolemPoints = GetLocalInt(OBJECT_SELF, "golem_points");
    nGolemPoints += nOldGolemPoints;
    nGolemPoints += 4;
    //SpeakString("Golem points: " + IntToString(nGolemPoints));
    float fDelay = 0.0;
    while (nGolemPoints > 400)
    {
        DelayCommand(fDelay, MakeANewGolem());
        fDelay += 2.0;
        nGolemPoints -= 400;
    }
    SetLocalInt(OBJECT_SELF, "golem_points", nGolemPoints);
}

#include "inc_ai_combat"
#include "nwnx_creature"


string tmVectorToString(vector vVec)
{
    string sOut = "Vector(" + FloatToString(vVec.x) + ", " + FloatToString(vVec.y) +  "," + FloatToString(vVec.z) + ")";
    return sOut;
}

// Maker's bone golem heartbeat script
// It looks for dead things of its own tag, and will tether together, slide into each other and make a new one

void MakeNewGolem(object oOne, object oTwo, location lMid)
{
    object oGolem = CreateObject(OBJECT_TYPE_CREATURE, "maker_bonegolem", lMid, FALSE, "maker_bonegolem");
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, 100)), oGolem);
    object oArea = GetAreaFromLocation(lMid);
    json jGolems = GetLocalJson(oArea, "maker_golems");
    jGolems = JsonArrayInsert(jGolems, JsonString(ObjectToString(oGolem)));
    DestroyObject(oOne);
    DestroyObject(oTwo);
    // Remove old ones from array
    if (GetIsObjectValid(oOne))
    {
        json jResponse = JsonFind(jGolems, JsonString(ObjectToString(oOne)));
        if (jResponse != JsonNull())
        {
            int nIndex = JsonGetInt(jResponse);
            jGolems = JsonArrayDel(jGolems, nIndex);
        }
    }
    if (GetIsObjectValid(oTwo))
    {
        json jResponse = JsonFind(jGolems, JsonString(ObjectToString(oTwo)));
        if (jResponse != JsonNull())
        {
            int nIndex = JsonGetInt(jResponse);
            jGolems = JsonArrayDel(jGolems, nIndex);
        }
    }
    
    SetLocalJson(oArea, "maker_golems", jGolems);
    AssignCommand(oGolem, DelayCommand(2.0, gsCBDetermineCombatRound(gsCBGetAttackTarget())));
}

void main()
{
    if (GetLocalInt(OBJECT_SELF, "tethering"))
    {
        return;
    }
    object oMaker = GetObjectByTag("maker_demilich");
    if (!GetIsObjectValid(oMaker) || GetIsDead(oMaker))
    {
        return;
    }
    // Look for another dead one
    int n=0;
    object oOther;
    do
    {
        oOther = GetNearestObjectByTag(GetTag(OBJECT_SELF), OBJECT_SELF, n);
        if (GetIsDead(oOther) && GetIsObjectValid(oOther) && oOther != OBJECT_SELF)
        {
            if (!GetLocalInt(oOther, "tethering"))
            {
                SetLocalInt(OBJECT_SELF, "tethering", 1);
                SetLocalInt(oOther, "tethering", 1);
                // We can make more of ourselves!
                vector vMid = (GetPosition(OBJECT_SELF) + GetPosition(oOther))/2.0;
                vMid = NWNX_Creature_ComputeSafeLocation(OBJECT_SELF, vMid);
                location lMid = Location(GetArea(OBJECT_SELF), vMid, 0.0);
                
                //ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_FIREBALL), lMid);
                
                float fDist = GetDistanceBetweenLocations(GetLocation(OBJECT_SELF), lMid);
                vector vTranslate = vMid - GetPosition(OBJECT_SELF);
                
                float fTime = fDist/5.0;
                
                // This would be pretty simple, but the visual transforms are applied apparently as if your facing was 90
                // which means vTranslate needs rotating clockwise by 90-GetFacing(OBJECT_SELF) degrees
                
                vector vTranslate2 = Vector();
                float fFacing = 90.0-GetFacing(OBJECT_SELF);
                vTranslate2.x = vTranslate.x*cos(fFacing) - vTranslate.y*sin(fFacing);
                vTranslate2.y = vTranslate.x*sin(fFacing) + vTranslate.y*cos(fFacing);
                vTranslate2.z = vTranslate.z;
                
                SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X, vTranslate2.x, OBJECT_VISUAL_TRANSFORM_LERP_QUADRATIC, fTime);
                SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, vTranslate2.y, OBJECT_VISUAL_TRANSFORM_LERP_QUADRATIC, fTime);
                SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, vTranslate2.z, OBJECT_VISUAL_TRANSFORM_LERP_QUADRATIC, fTime);
                
                //SpeakString("I am at " + tmVectorToString(GetPosition(OBJECT_SELF)) + " and trying to go to " + tmVectorToString(vMid) + ", angle of rotation = " + FloatToString(fFacing) + ", result = " + tmVectorToString(vTranslate2));
                
                vTranslate = vMid - GetPosition(oOther);
                vTranslate2 = Vector();
                fFacing = 90.0-GetFacing(oOther);
                vTranslate2.x = vTranslate.x*cos(fFacing) - vTranslate.y*sin(fFacing);
                vTranslate2.y = vTranslate.x*sin(fFacing) + vTranslate.y*cos(fFacing);
                vTranslate2.z = vTranslate.z;
                
                SetObjectVisualTransform(oOther, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X, vTranslate2.x, OBJECT_VISUAL_TRANSFORM_LERP_QUADRATIC, fTime);
                SetObjectVisualTransform(oOther, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, vTranslate2.y, OBJECT_VISUAL_TRANSFORM_LERP_QUADRATIC, fTime);
                SetObjectVisualTransform(oOther, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, vTranslate2.z, OBJECT_VISUAL_TRANSFORM_LERP_QUADRATIC, fTime);
                
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_EVIL, OBJECT_SELF, BODY_NODE_CHEST), oOther, fTime);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBeam(VFX_BEAM_EVIL, oOther, BODY_NODE_CHEST), OBJECT_SELF, fTime);
                
                DelayCommand(fTime, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1, FALSE), lMid));
                DelayCommand(fTime+0.3, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD, FALSE, 1.5), lMid));
                DelayCommand(fTime+0.3, MakeNewGolem(OBJECT_SELF, oOther, lMid));
                return;
            }
        }
        n++;
    } while (GetIsObjectValid(oOther));
}
// maker 2 lever hb (detect hidden object)
// This is assigned when a PC enters the area so can remove itself
#include "nwnx_visibility"

void main()
{
    int nPCInArea = 0;
    object oTest = GetFirstPC();
    object oArea = GetArea(OBJECT_SELF);
    while (GetIsObjectValid(oTest))
    {
        if (GetArea(oTest) == oArea)
        {
            nPCInArea = 1;
            break;
        }
        oTest = GetNextPC();
    }
    if (!nPCInArea)
    {
        int nCount = GetLocalInt(OBJECT_SELF, "no_pc_count");
        SetLocalInt(OBJECT_SELF, "no_pc_count", nCount+1);
        if (nCount > 50)
        {
            DeleteLocalInt(OBJECT_SELF, "no_pc_count");
            SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "");
        }
        
        return;
    }
    DeleteLocalInt(OBJECT_SELF, "no_pc_count");
        
    int nDC = GetLocalInt(OBJECT_SELF, "dc");
    float fRadius = 10.0;
    location lSelf = GetLocation(OBJECT_SELF);
    oTest = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lSelf);
    while (GetIsObjectValid(oTest))
    {
        if (!GetIsDead(oTest) && (GetIsPC(oTest) || GetIsPC(GetMaster(oTest))))
        {
            //ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_FIREBALL), GetLocation(oTest));
            int nSkill = GetSkillRank(SKILL_SEARCH, oTest);
            if (GetIsInCombat(oTest))
            {
                nSkill -= 10;
            }
            if (GetActionMode(oTest, ACTION_MODE_DETECT))
            {
                nSkill += 10;
            }
            if (GetDistanceBetween(oTest, OBJECT_SELF) < 5.0)
            {
                nSkill += 5;
            }
            if (nSkill + d20() >= nDC)
            {
                // NPCs will say something, for PCs it's up to them to make a point of it
                if (!GetIsPC(oTest))
                {
                    PlayVoiceChat(VOICE_CHAT_LOOKHERE, oTest);
                }
                else
                {
                    FloatingTextStringOnCreature("You spot a hidden lever behind one of the pillars.", oTest, FALSE);
                }
                SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "");
                NWNX_Visibility_SetVisibilityOverride(OBJECT_INVALID, OBJECT_SELF, NWNX_VISIBILITY_DEFAULT);
                return;
            }
        }
        oTest = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lSelf);
    }
}

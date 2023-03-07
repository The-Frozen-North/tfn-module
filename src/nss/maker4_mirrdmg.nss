#include "nwnx_object"

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    int nIndex = GetLocalInt(OBJECT_SELF, "mirror_index");
    if (!GetLocalInt(oArea, "hitmirror"+IntToString(nIndex)))
    {
        SetLocalInt(oArea, "hitmirror"+IntToString(nIndex), 1);
        effect eTest = GetFirstEffect(OBJECT_SELF);
        while (GetIsEffectValid(eTest))
        {
            while (GetIsEffectValid(eTest))
            {
                DelayCommand(0.0, RemoveEffect(OBJECT_SELF, eTest));
                eTest = GetNextEffect(OBJECT_SELF);
            }
        }
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_BLINDDEAF), OBJECT_SELF);
    }
    NWNX_Object_SetCurrentHitPoints(OBJECT_SELF, 10000);
}
#include "inc_general"

void main()
{
    location lLocation = GetLocation(OBJECT_SELF);
    float fSize = IntToFloat(GetCreatureSize(OBJECT_SELF));
    object oModule = GetModule();

    object oIce = CreateObject(OBJECT_TYPE_PLACEABLE, "_dth_cold", lLocation);
    object oRemains = CreateObject(OBJECT_TYPE_PLACEABLE, "_remains_cold", lLocation);
    SetObjectVisualTransform(oRemains, OBJECT_VISUAL_TRANSFORM_SCALE, 0.2*fSize);
    SetObjectVisualTransform(oIce, OBJECT_VISUAL_TRANSFORM_SCALE, 0.3*fSize);
    AssignCommand(oRemains, SetFacing(IntToFloat(Random(360))));

    AssignCommand(oModule, DelayCommand(0.1, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FROST_L, FALSE, 0.3*fSize), lLocation)));
    AssignCommand(oModule, DelayCommand(0.2, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(1), oIce)));
    AssignCommand(oModule, DelayCommand(REMAINS_DECAY, DestroyObject(oRemains)));

    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_SCALE, 0.01);
    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -500.0);

    DestroyObject(OBJECT_SELF);
}

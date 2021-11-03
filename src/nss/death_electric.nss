#include "inc_general"

void main()
{
    location lLocation = GetLocation(OBJECT_SELF);
    float fSize = IntToFloat(GetCreatureSize(OBJECT_SELF));
    object oModule = GetModule();

    object oCloud = CreateObject(OBJECT_TYPE_PLACEABLE, "_cloud_electri", lLocation);
    object oRemains = CreateObject(OBJECT_TYPE_PLACEABLE, "_remains_electri", lLocation);
    SetObjectVisualTransform(oRemains, OBJECT_VISUAL_TRANSFORM_SCALE, 0.5*fSize);
    SetObjectVisualTransform(oCloud, OBJECT_VISUAL_TRANSFORM_SCALE, 0.6*fSize);
    AssignCommand(oRemains, SetFacing(IntToFloat(Random(360))));

    AssignCommand(oModule, DelayCommand(0.1, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_LIGHTNING_S, FALSE, 0.3*fSize), lLocation)));

    AssignCommand(oModule, DelayCommand(REMAINS_DECAY/2.0, DestroyObject(oCloud)));
    AssignCommand(oModule, DelayCommand(REMAINS_DECAY, DestroyObject(oRemains)));

    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -500.0);

    DestroyObject(OBJECT_SELF);
}

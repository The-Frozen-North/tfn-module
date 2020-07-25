//::///////////////////////////////////////////////
//:: Caltrops
//:: x0_s3_caltrop
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*

    Creates a permanent field of caltrops that will disappear
    after 25 points of damage have been dished out.
    (1 point per creature per round)

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 10, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- caltrops didn't done any damage last round when the damage counter reached 25
- previous solution could left invisible placeable in area
> serious rewrite, now the default AOE heartbeat is replaced by scripted heartbeat
on placeable which executes a script on AOE (so it will work always reliably)
*/

void main()
{
    //Declare major variables including Area of Effect Object
    effect eAOE = EffectAreaOfEffect(AOE_PER_CUSTOM_AOE, "x0_s3_calen", "", "");
    location lTarget = GetSpellTargetLocation();

    //effect eImpact = EffectVisualEffect(257);
    //ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, lTarget);

    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eAOE, lTarget);
    object oVisual = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_invisobj", lTarget);
    effect eFieldOfSharp = EffectVisualEffect(VFX_DUR_CALTROPS);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eFieldOfSharp, oVisual);
    int nTh = 1;
    object oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lTarget, nTh);
    while(oAOE != OBJECT_INVALID)
    {
        if(GetTag(oAOE) == "VFX_CUSTOM" && GetLocalObject(oAOE, "X0_L_IMPACT") == OBJECT_INVALID)
        {
        //got it
        break;
        }
        oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lTarget, ++nTh);
    }
    SetLocalObject(oVisual, "AOE", oAOE);
    SetLocalObject(oAOE, "X0_L_IMPACT", oVisual);
    DelayCommand(6.0, ExecuteScript("x0_s3_calhb", oVisual));
}

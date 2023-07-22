// #include "inc_ai_combat"
//#include "x0_i0_position"

void main()
{
    float fRadius = 25.0;

    location lLocation = GetLocation(OBJECT_SELF);
    
// ballista bolts are fired at a trajectory, the LoS checks are based on geometry so check as if the ballista is 3m higher
    // vector vVector = GetPosition(OBJECT_SELF);
    // vector vAttackVector = Vector(vVector.x, vVector.y, vVector.z + 3.0);

 // attempt to get the first visible target from friendly creatures
    object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation);
    object oCreatureTarget, oTarget;
    while(GetIsObjectValid(oCreature))
    {
        // doesn't cover all luskan troops like high captain forces, oh well
        if(!GetIsDead(oCreature) && GetStringLeft(GetResRef(oCreature), 6) == "luskan" && GetIsInCombat(oCreature))
        {
            // oCreatureTarget = gsCBGetAttackTarget(oCreature);
            oCreatureTarget = GetAttackTarget(oCreature);
            // must be seen by both the creature and ballista
            // if(GetObjectSeen(oCreatureTarget, oCreature) && LineOfSightVector(vAttackVector, GetPosition(oCreatureTarget)))
            
            if(!GetIsDead(oCreatureTarget) && GetObjectSeen(oCreatureTarget, oCreature))
            {
                oTarget = oCreatureTarget;
                break;
            }
        }
        //Get next target in area
        oCreature = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation);
    }

    // currently this makes them backwards, so disable it for now
    //SetFacingPoint(GetPosition(oTarget));
// Ballistas face the wrong way, so turn them
    //SetFacing(GetNormalizedDirection(GetFacing(OBJECT_SELF) - 90.0));

    if (GetLocalInt(OBJECT_SELF, "reload") == 1)
    {
        ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
        DeleteLocalInt(OBJECT_SELF, "reload");
        return;
    }    

// if they don't have a target, do nothing
    if (!GetIsObjectValid(oTarget)) return;

// ballista bolt disappears in this animation
    ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);

    SetLocalInt(OBJECT_SELF, "reload", 1);

// x2_p1_ballista2
    ActionCastSpellAtObject(794, oTarget, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_BALLISTIC);
    PlaySound("cb_sh_catapult");
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), OBJECT_SELF);
}
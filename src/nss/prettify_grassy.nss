#include "inc_prettify"

void main()
{
    ClearPrettifyPlaceableDBForArea(OBJECT_SELF);
	
    // Puddles
    struct PrettifyPlaceableSettings pps = GetDefaultPrettifySettings();
    pps.sResRef = "nw_plc_puddle1";
    pps.fAvoidPlaceableRadius = 2.0;
    pps.nValidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 3;
    pps.fMaximumGroundSlope = 0.05;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder1Radius = 1.0;
    
    pps.nBorder2Surface1 = SURFACEMAT_ABSTRACT_ALL;
    pps.nBorder2Surface2 = SURFACEMAT_ABSTRACT_ALL;
    pps.nBorder2InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder2Radius = 0.5;
    
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "nw_plc_puddle2";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Small Hole
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "x2_plc_hole_s";
    pps.fAvoidPlaceableRadius = 1.5;
    pps.nValidSurface1 = SURFACEMAT_GRASS;
    pps.nTargetDensity = 1;
    pps.fMaximumGroundSlope = 0.1;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder1Radius = 1.0;
    pps.nBorder2Surface1 = SURFACEMAT_GRASS;
    pps.nBorder2Surface2 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder2InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder2Radius = 2.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Foliage that goes all over the grass
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "x3_plc_bush001";
    pps.fAvoidPlaceableRadius = 1.5;
    pps.nValidSurface1 = SURFACEMAT_GRASS;
    pps.nTargetDensity = 1;
    pps.fMaximumGroundSlope = 0.2;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.nBorder2Surface1 = SURFACEMAT_GRASS;
    pps.nBorder2Surface2 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder2InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder2Radius = 2.5;
    pps.fBorder1Radius = 1.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bushlg01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bushmd01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bushsm01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bush11a";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bush11b";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bush11c";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bush11d";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Ferns
    pps.sResRef = "plc_fern";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_fern001";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_fern002";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_fern003";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_fern004";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_fern005";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "plc_grasstuft";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x2_plc_mold";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x0_moss";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_moss004";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_moss005";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower02";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower03";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower04";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower05";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower06";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "plc_shrub";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Weeds
    pps.sResRef = "tm_pl_weed11a";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed11b";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed11ans";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed11bns";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed12a";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed12b";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed12ans";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed12bns";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed13a";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed13b";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed13ans";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed13bns";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed13c";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed14a";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed14b";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed14ans";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed14bns";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed15a";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed15b";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed15c";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed15ans";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_weed15bns";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    
    
    // Pretty flowers
    
    pps.sResRef = "tm_pl_fwrdaisy01";
    pps.fAvoidPlaceableRadius = 2.5;
    pps.fMaximumGroundSlope = 0.1;
    pps.fBorder1Radius = 2.5;
    pps.fBorder2Radius = 3.5;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_fwrpurp01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_fwrred01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_fwryello01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Alt grasses
    
    pps.sResRef = "x3_plc_grass001";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_grass002";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_fwrpurp01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_fwrpurp01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Very large grass placeables
    
    pps.fAvoidPlaceableRadius = 5.0;
    pps.fBorder1Radius = 5.0;
    pps.fBorder1Radius = 6.0;
    pps.sResRef = "x3_plc_grass003";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_moss001";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_moss002";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_moss003";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Trees
    pps.fAvoidPlaceableRadius = 7.0;
    pps.fBorder1Radius = 6.0;
    pps.fBorder2Radius = 6.0;
    pps.sResRef = "plc_tree";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_treeappll1";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "plc_treeautumn";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_treel000";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);

    pps.sResRef = "x3_plc_treel001";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_treel003";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_treel004";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_treel005";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_treel006";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_treel007";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_treel008";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_treel009";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_treel011";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_treel007";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    
    
    // Big bushes - at the edge of nonwalkable terrain that isn't water
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "tm_pl_bushlg01";
    pps.fAvoidPlaceableRadius = 1.5;
    pps.nValidSurface1 = SURFACEMAT_GRASS;
    pps.nTargetDensity = 8;
    pps.fMaximumGroundSlope = 0.2;
    pps.nBorder1Surface1 = SURFACEMAT_GRASS;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE + SURFACEMAT_ABSTRACT_NOTWATER;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    pps.fBorder1Radius = 2.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bushmd01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bushsm01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bush11a";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bush11b";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bush11c";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_bush11d";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower01";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower02";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower03";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower04";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower05";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_flower06";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "plc_shrub";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.fAvoidPlaceableRadius = 2.5;
    pps.nTargetDensity = 3;
    pps.sResRef = "x3_plc_stump002";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_stump003";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    
    // Butterflies
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "plc_butterflies";
    pps.fAvoidPlaceableRadius = 1.5;
    pps.nValidSurface1 = SURFACEMAT_GRASS;
    pps.nTargetDensity = 1;
    pps.fMaximumGroundSlope = 0.2;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder1Radius = 1.0;
    pps.nBorder2Surface1 = SURFACEMAT_GRASS;
    pps.nBorder2Surface2 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder2InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder2Radius = 3.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    
    // Dirt Patches
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "x0_dirtpatch";
    pps.fAvoidPlaceableRadius = 2.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nTargetDensity = 3;
    pps.fMinScale = 0.1;
    pps.fMaxScale = 0.66;
    pps.fMaximumGroundSlope = 0.05;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder1Radius = 1.3;
    pps.nBorder2Surface1 = SURFACEMAT_GRASS;
    pps.nBorder2Surface2 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder2InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder2Radius = 4.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_dirt001";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_dirt002";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Driftwood collects at the edges of deep water
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "nw_plc_driftwd1";
    pps.fAvoidPlaceableRadius = 1.5;
    pps.nValidSurface1 = SURFACEMAT_DEEPWATER;
    pps.nTargetDensity = 2;
    pps.fMaximumGroundSlope = 0.2;
    pps.nBorder1Surface1 = SURFACEMAT_DEEPWATER;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_WALKABLE + SURFACEMAT_ABSTRACT_NOTWATER;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    pps.fBorder1Radius = 2.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "nw_plc_driftwd2";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "nw_plc_driftwd3";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "nw_plc_driftwd4";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x0_reeds";
    pps.nTargetDensity = 8;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Willows grow near water
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "x3_plc_treel018";
    pps.fAvoidPlaceableRadius = 7.0;
    pps.nValidSurface1 = SURFACEMAT_GRASS;
    pps.nTargetDensity = 2;
    pps.fMaximumGroundSlope = 0.2;
    pps.nBorder1Surface1 = SURFACEMAT_DEEPWATER;
    pps.nBorder1Surface2 = SURFACEMAT_GRASS;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    pps.fBorder1Radius = 2.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    
    
    
}
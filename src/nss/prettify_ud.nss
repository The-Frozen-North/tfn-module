#include "inc_prettify"

void main()
{
    ClearPrettifyPlaceableDBForArea(OBJECT_SELF);
    
    /*
    //Yellow lights on any walkable places near any kind of surfacemat boundaries
    struct PrettifyPlaceableSettings pps = GetDefaultPrettifySettings();
    pps.sResRef = "x3_plc_ylightl";
    pps.fAvoidPlaceableRadius = 1.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nTargetDensity = 200;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_ALL;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_ALL;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    pps.fBorder1Radius = 1.5;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Blue lights anywhere that is walkable
    struct PrettifyPlaceableSettings pps2 = GetDefaultPrettifySettings();
    pps2.sResRef = "plc_solblue";
    pps2.fAvoidPlaceableRadius = 1.0;
    pps2.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps2.nTargetDensity = 25;
    PlacePrettifyPlaceable(pps2, OBJECT_SELF);
    */
    
    // plc_rubble - replacetexture plc_rck -> ttu01_floor
    struct PrettifyPlaceableSettings pps = GetDefaultPrettifySettings();
    //pps.sResRef = "plc_rubble";
    //pps.fAvoidPlaceableRadius = 1.0;
    //pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    //pps.nTargetDensity = 20;
    //pps.fMinScale = 0.3;
    //pps.fMaximumGroundSlope = 0.3;
    //pps.sReplaceTexture1From = "plc_rck";
    //pps.sReplaceTexture1To = "ttu01_floor";
    //pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    //pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    //pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    //pps.fBorder1Radius = 1.5;
    //PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Floor Soot 1-3
    // It's too big :(
    //pps = GetDefaultPrettifySettings();
    //pps.sResRef = "tm_pl_flrsoot1";
    //pps.fAvoidPlaceableRadius = 2.0;
    //pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    //pps.nTargetDensity = 3;
    //pps.fMinScale = 0.03;
    //pps.fMaxScale = 0.15;
    //pps.fMaximumGroundSlope = 0.05;
    //pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    //pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    //pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    //pps.fBorder1Radius = 1.0;
    //PlacePrettifyPlaceable(pps, OBJECT_SELF);
    //
    //pps.sResRef = "tm_pl_flrsoot2";
    //PlacePrettifyPlaceable(pps, OBJECT_SELF);
    //
    //pps.sResRef = "tm_pl_flrsoot3";
    //pps.nTargetDensity = 4;
    //PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    
    // Puddles 1 and 2
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "nw_plc_puddle1";
    pps.fAvoidPlaceableRadius = 2.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 3;
    pps.fAvoidDoorRadius = 5.0;
    pps.fMinScale = 0.2;
    pps.fMaxScale = 0.8;
    pps.fMaximumGroundSlope = 0.05;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder1Radius = 1.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "nw_plc_puddle2";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Small Hole
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "x2_plc_hole_s";
    pps.fAvoidPlaceableRadius = 1.5;
    pps.fAvoidDoorRadius = 5.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 2;
    pps.fMinScale = 0.5;
    pps.fMaxScale = 1.2;
    pps.fMaximumGroundSlope = 0.1;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder1Radius = 1.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Bottles: broken, empty (the two kinds on their side)
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "tm_pl_btlbroken";
    pps.fAvoidPlaceableRadius = 1.0;
    pps.fAvoidDoorRadius = 5.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 1;
    pps.fMinScale = 0.8;
    pps.fMaxScale = 1.2;
    pps.fMaximumGroundSlope = 0.3;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder1Radius = 1.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "tm_pl_btlempty";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Various boulders: "boulder", "boulder 1 green standing", "boulder 3 green leaning", "boulder 4 green broken"
    // All want to hug unwalkable edges, they're pretty big to just have in the middle of the pathways
    
    // Texture replace to underdark stone
    
    //pps = GetDefaultPrettifySettings();
    //pps.sResRef = "plc_boulder";
    //pps.fAvoidPlaceableRadius = 1.0;
    //pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    //pps.nTargetDensity = 10;
    //pps.fMinScale = 0.6;
    //pps.fMaxScale = 1.0;
    //pps.fMaximumGroundSlope = 0.3;
    //pps.sReplaceTexture1From = "plc_rck";
    //pps.sReplaceTexture1To = "ttu01_floor";
    //pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    //pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    //pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    //pps.fBorder1Radius = 1.5;
    //PlacePrettifyPlaceable(pps, OBJECT_SELF);
    //    
    //
    //pps.sResRef = "x3_plc_boulder1";
    //pps.sReplaceTexture1From = "tbw01_stone1";
    //pps.sReplaceTexture1To = "ttu01_floor";
    //PlacePrettifyPlaceable(pps, OBJECT_SELF);
    //
    //pps.sResRef = "x3_plc_boulder3";
    //PlacePrettifyPlaceable(pps, OBJECT_SELF);
    //
    //pps.sResRef = "x3_plc_boulder4";
    //PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Crystal
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "x2_plc_crystal";
    pps.fAvoidPlaceableRadius = 2.5;
    pps.fAvoidDoorRadius = 5.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 10;
    pps.fMinScale = 0.3;
    pps.fMaxScale = 1.3;
    pps.fMaximumGroundSlope = 0.3;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    pps.fBorder1Radius = 1.5;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Desert boulder
    //pps = GetDefaultPrettifySettings();
    //pps.sResRef = "x0_desertboulder";
    //pps.fAvoidPlaceableRadius = 1.0;
    //pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    //pps.nTargetDensity = 10;
    //pps.fMinScale = 0.6;
    //pps.fMaxScale = 1.2;
    //pps.fMaximumGroundSlope = 0.3;
    //pps.sReplaceTexture1From = "ttd01_cliff01";
    //pps.sReplaceTexture1To = "ttu01_floor";
    //pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    //pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    //pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    //pps.fBorder1Radius = 1.5;
    //PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Dirt Patches
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "x0_dirtpatch";
    pps.fAvoidPlaceableRadius = 2.0;
    pps.fAvoidDoorRadius = 5.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 3;
    pps.fMinScale = 0.1;
    pps.fMaxScale = 0.66;
    pps.fMaximumGroundSlope = 0.05;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder1Radius = 1.3;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_dirt001";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    pps.sResRef = "x3_plc_dirt002";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Fungus
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "nw_plc_fungus";
    pps.fAvoidPlaceableRadius = 2.0;
    pps.fAvoidDoorRadius = 5.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 35;
    pps.fMinScale = 0.3;
    pps.fMaxScale = 1.3;
    pps.fMaximumGroundSlope = 0.3;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    pps.fBorder1Radius = 1.5;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Mold
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "x2_plc_mold";
    pps.fAvoidPlaceableRadius = 2.0;
    pps.fAvoidDoorRadius = 5.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 8;
    pps.fMinScale = 0.6;
    pps.fMaxScale = 1.0;
    pps.fMaximumGroundSlope = 0.3;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_FORBIDDEN;
    pps.fBorder1Radius = 1.0;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Mushrooms
    // blue
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "tm_pl_shroomblu2";
    pps.fAvoidPlaceableRadius = 3.0;
    pps.fAvoidDoorRadius = 5.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 20;
    pps.fMinScale = 0.3;
    pps.fMaxScale = 1.3;
    pps.fMaximumGroundSlope = 0.3;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    pps.fBorder1Radius = 1.5;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Red
    pps.sResRef = "tm_pl_shroomred1";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Grey
    pps.sResRef = "x2_plc_mushrms";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Grey, not-domed
    pps.sResRef = "x3_plc_mshroom6";
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Rocks
    pps = GetDefaultPrettifySettings();
    pps.sResRef = "nw_plc_rock5";
    pps.fAvoidPlaceableRadius = 2.5;
    pps.fAvoidDoorRadius = 5.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 20;
    pps.fMinScale = 0.6;
    pps.fMaxScale = 1.2;
    pps.fMaximumGroundSlope = 0.3;
    pps.nBorder1Surface1 = SURFACEMAT_ABSTRACT_WALKABLE;
    pps.nBorder1Surface2 = SURFACEMAT_ABSTRACT_NOTWALKABLE;
    pps.nBorder1InfluenceType = PRETTIFY_INFLUENCE_TYPE_REQUIRED;
    pps.fBorder1Radius = 1.5;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Water Drip
    pps = GetDefaultPrettifySettings();
    pps.fAvoidPlaceableRadius = 1.0;
    pps.sResRef = "plc_waterdrip";
    pps.fAvoidPlaceableRadius = 0.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_ALL;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 1;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
    // Shaft of Water
    pps = GetDefaultPrettifySettings();
    pps.fAvoidPlaceableRadius = 2.0;
    pps.sResRef = "x3_plc_swater";
    pps.fAvoidPlaceableRadius = 0.0;
    pps.nValidSurface1 = SURFACEMAT_ABSTRACT_ALL;
    pps.nAvoidSurface1 = SURFACEMAT_STONE;
    pps.nTargetDensity = 1;
    PlacePrettifyPlaceable(pps, OBJECT_SELF);
    
}
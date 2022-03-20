//::///////////////////////////////////////////////
//:: Global Weather System v3.00
//:: weather_inc
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The purpose of this system is to create a
    global weather system that incorporates
    the four seasons of the year into your
    module.

    This is an include file, so if you make
    changes to this script you must recompile
    the scripts which use it.
*/
#include "inc_debug"
#include "nwnx_area"

//------------------------------------------------------------------------------
// Returns a random location within the specified area.
//------------------------------------------------------------------------------
location AreaRandomLocation(object oArea)
{
    location lLoc;
    int nRanX, nRanY, nRanZ;

    nRanX = Random(GetAreaSize(AREA_WIDTH, oArea));
    nRanY = Random(GetAreaSize(AREA_HEIGHT, oArea));
    nRanZ = 0; // Random(MaxAreaSizeZ); ???

    float fX = IntToFloat(nRanX);
    float fY = IntToFloat(nRanY);
    float fZ = IntToFloat(nRanZ);

    vector vVec = Vector(fX, fY, fZ);
    lLoc = Location(oArea, vVec, 0.0);
    return lLoc;
}

// CLIMATE SYSTEM DETERMINATION TYPE
// (Default: TRUE)
// TRUE     = System uses zone tags to determine the climate of the area.
// FALSE    = System uses zone variables to determine the climate of the area.
// Note: Both are set in the toolset under Advanced options of the area
//       properties menu.
const int WEATHER_TAGS = TRUE;

// Toggles - Turn features on/off.
// (default: TRUE). Toggling these on and off will make certain parts of
// the weather system non-functional. None are interdependant so, any of
// them can be on or off at any given time.
// TRUE = On
// FALSE = Off
// WEATHER_SYSTEM       = Toggle the entire system on/off.
// WEATHER_FOG          = Toggle fog effects on/off.
// WEATHER_SKYBOX       = Toggle skybox effects on/off.
// WEATHER_DAMAGE       = Toggle Heat/Cold damage on/off.
// WIND_EFFECTS         = Toggle Wind system on/off.
// LIGHTNING_EFFECTS    = Toggle Lightning visual effects on/off.
// BLIZZARD_EFFECTS     = Toggle Blizard visual effects on/off.
// SANDSTORM_EFFECTS    = Toggle Sandstorm visual effects on/off.
// STORM_THUNDER        = Toggle Thunderstorm system on/off.
// STORM_BLIZZARD       = Toggle Blizzard system on/off.
// STORM_SAND           = Toggle Sandstorm system on/off.
const int WEATHER_SYSTEM = TRUE;
const int WEATHER_FOG = TRUE;
const int WEATHER_SKYBOX = TRUE;
const int WEATHER_DAMAGE = TRUE;
const int WIND_EFFECTS = TRUE;
const int LIGHTNING_EFFECTS = TRUE;
const int BLIZZARD_EFFECTS = TRUE;
const int SANDSTORM_EFFECTS = TRUE;
const int STORM_THUNDER = TRUE;
const int STORM_BLIZZARD = TRUE;
const int STORM_SAND = TRUE;

// The minimum and maximum time between weather system checks.
// Duration times in minutes(real time).
const int nMin = 2;
const int nMax = 10;

// The maximum time between Lightning/Blizzard/Sand etc strikes.
// Duration in seconds.
const int nStrikeTime = 15;

// The maximum time between wind gusts. The Wind system uses a random number
// between 1 and the number you choose here. The higher the number the greater
// the chance of delay. Default: 60
// Duration in seconds.
const int nWindDelay = 60;

// Fog System Constants.
// These are base numbers, and will be added to or subtracted from by the
// script below.
// FOG_DAWN     = Amount of fog that will show up during the dawn hours.
// FOG_DUSK     = Amount of fog that will show up during the evening hours.
// FOG_NIGHT    = Amount of fog that will show up during the night.
// FOG_RAIN     = Amount of fog during rainy weather.
// FOG_PERCENT  = Percent chance that fog will occur as a result of the time
//               of day. The higher the number, the greater the chance that
//               fog will take place during the morning, evening, or night time.
const int FOG_DAWN = 35;
const int FOG_DUSK = 25;
const int FOG_NIGHT = 20;
const int FOG_RAIN = 50;
const int FOG_PERCENT = 15;

// Storm System Constants
// nBaseTStorm = (Default: 15) The percent chance of a thunderstorm occuring if it's raining.
// nBaseBlizzard = (Default: 15) The percent chance of a blizzard occuring if it's snowing.
// nBaseSStorm = (Default: 15) The percent chance of a sandstorm occuring if climate is desert.
const int nBaseTStorm = 30;
const int nBaseBlizzard = 25;
const int nBaseSStorm = 20;

// Do not edit any of the the below constants. They are used by the script
// as place holders.
const int SEASON_WINTER = 1;
const int SEASON_SPRING = 2;
const int SEASON_SUMMER = 3;
const int SEASON_FALL   = 4;

// Variable Constants.
// VAR_STORM =  0) No Storm
//              1) ThunderStorm
//              2) Blizard
//              3) Sandstorm
const string VAR_SEASON_STORE = "SEASON";
const string VAR_STORM = "STORM_STORE";
const string WEATHER_FACTOR = "Weather_Factor";

/*-----------------------------*/
/* Script Functions Start Here */

// Area's that should be excluded from the system.
void WeatherExceptions()
{
    // this is where you add specific areas in that you want to keep
    // the same weather in at all times, for example deserts should
    // be clear and mountains could have snow, etc, etc

    // the GetObjectByTag() function should have the area tag in it
    // you can get this from the properties window of the area

    // examples:
    //SetWeather(GetObjectByTag("AreaDesert"),   WEATHER_CLEAR);
    //SetWeather(GetObjectByTag("AreaBeach"),    WEATHER_RAIN);
    //SetWeather(GetObjectByTag("AreaMountain"), WEATHER_SNOW);
}

// Set the season for the module.
void SetGlobalSeason()
{
    int nMonth = GetCalendarMonth();
    int nSeason;
    object oMod = GetModule();

    // Winter (Months 1-2, & 12)
    if (nMonth < 3 || nMonth == 12)
    {
        nSeason = SEASON_WINTER;
    }
    // Spring (Months 3 - 5)
    else if (nMonth >= 3 && nMonth < 6)
    {
        nSeason = SEASON_SPRING;
    }
    // Summer (Months 6 - 8)
    else if (nMonth >= 6 && nMonth < 9)
    {
        nSeason = SEASON_SUMMER;
    }
    // Fall (Months 9 - 11)
    else if (nMonth >= 9 && nMonth <= 11)
    {
        nSeason = SEASON_FALL;
    }
    SetLocalInt(oMod, VAR_SEASON_STORE, nSeason);
}

// Sandstorm Effect System
void ApplySandStormEffects()
{
    object oSandTgt;
    object oArea;

    if (SANDSTORM_EFFECTS == TRUE) {
        // Cycle through areas to determine if sandstorm visuals should be applied
        oArea = GetFirstArea();
        while (GetIsObjectValid(oArea))
        {
            if (GetLocalInt(oArea, VAR_STORM) == 3)
            {
                effect eVFX = EffectVisualEffect(VFX_IMP_DUST_EXPLOSION);
                location lLoc = AreaRandomLocation(oArea);
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, lLoc, 3.0);
                oSandTgt = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, lLoc, 1);
                // SendMessageToAllDMs("Sandstorm System Fired in: " + GetName(oArea));
            }
        oArea = GetNextArea();
        }
    }
    DelayCommand(IntToFloat(Random(nStrikeTime)), ApplySandStormEffects());
}

// Wind Effect System
void ApplyWindEffects()
{
    object oArea, oWind;

    if (WIND_EFFECTS == TRUE) {
        if (GetLocalInt(oArea, VAR_STORM) == 0)
        {
            // Cycle through areas to determine if wind should be applied
            oArea = GetFirstArea();
            while (GetIsObjectValid(oArea))
            {
                location lLoc = AreaRandomLocation(oArea);
                oWind = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, lLoc, 1);
                int nRanWind = Random(3);
                if (nRanWind == 1)
                    AssignCommand(oWind, PlaySound("as_wt_gustsoft1"));
                else if (nRanWind == 2)
                    AssignCommand(oWind, PlaySound("as_wt_gustgrass1"));
                else if (nRanWind == 3)
                    AssignCommand(oWind, PlaySound("as_wt_guststrng1"));

                oArea = GetNextArea();
            }
        }
    }
    DelayCommand(IntToFloat(Random(nWindDelay)), ApplyWindEffects());
}

// Lightning Effect System
void ApplyLightningEffects()
{
    object oArea;

    if (LIGHTNING_EFFECTS == TRUE) {
        // Cycle through areas to determine if lightning should be applied
        oArea = GetFirstArea();
        while (GetIsObjectValid(oArea))
        {
            if (GetLocalInt(oArea, VAR_STORM) == 1)
            {
                effect eVFX = EffectVisualEffect(VFX_IMP_LIGHTNING_M);
                location lLoc = AreaRandomLocation(oArea);
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, lLoc, 3.0);
                // SendMessageToAllDMs("Lightning System Fired in: " + GetName(oArea));
            }
            oArea = GetNextArea();
        }
    }
    DelayCommand(IntToFloat(Random(nStrikeTime)), ApplyLightningEffects());
}

// Blizzard Effect System
void ApplyBlizzardEffects()
{
    object oArea;

    if (BLIZZARD_EFFECTS == TRUE) {
        // Cycle through areas to determine if blizzard visuals should be applied
        oArea = GetFirstArea();
        while (GetIsObjectValid(oArea))
        {
            if (GetLocalInt(oArea, VAR_STORM) == 2)
            {
                effect eVFX = EffectVisualEffect(VFX_FNF_ICESTORM);
                location lLoc = AreaRandomLocation(oArea);
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, lLoc, 3.0);
                // SendMessageToAllDMs("Blizzard System Fired in: " + GetName(oArea));
            }
            oArea = GetNextArea();
        }
    }
    DelayCommand(IntToFloat(Random(nStrikeTime)), ApplyBlizzardEffects());
}

// Thunderstorm System
void WeatherThunderStorm()
{
    int nStormChance;
    int nTStormChance = 0;
    object oArea;
    object oMod = GetModule();

    switch (GetLocalInt(oMod, VAR_SEASON_STORE))
    {
        case SEASON_WINTER:
            nTStormChance = 1;
            break;
        case SEASON_SUMMER:
            nTStormChance = 5;
            break;
        case SEASON_FALL:
        case SEASON_SPRING:
            nTStormChance = 10;
            break;
    }

    if (STORM_THUNDER == TRUE) {
        oArea = GetFirstArea();
        while (GetIsObjectValid(oArea)) {
            if (GetWeather(oArea) == WEATHER_RAIN) {
                if (WEATHER_TAGS == TRUE)
                {
                    string sStringValue1 = GetStringLeft(GetTag(oArea), 2);
                    string sStringValue2 = GetSubString(GetTag(oArea), 2, 3);
                    if (sStringValue1 == "ZN") { // Area has a climate
                        int iStringValue = StringToInt(sStringValue2);
                        switch (iStringValue) {
                            case 100: // Moderate Climate
                                nTStormChance += 5;
                                break;
                            case 101: // Jungle Climate
                                nTStormChance += 10;
                                break;
                            case 102: // Polar Climate
                                nTStormChance += 1;
                                break;
                            case 103: // Desert Climate
                                nTStormChance = 0;
                                break;
                            case 104: // Highland Climate
                                nTStormChance += 5;
                                break;
                        }
                    }
                } else if (WEATHER_TAGS == FALSE)
                {
                    int nClimateZone = GetLocalInt(oArea, "CLIMATEZONE");
                    if (nClimateZone != 0) { // Area has a climate
                        switch (nClimateZone) {
                            case 100: // Moderate Climate
                                nTStormChance += 5;
                                break;
                            case 101: // Jungle Climate
                                nTStormChance += 10;
                                break;
                            case 102: // Polar Climate
                                nTStormChance += 1;
                                break;
                            case 103: // Desert Climate
                                nTStormChance = 0;
                                break;
                            case 104: // Highland Climate
                                nTStormChance += 5;
                                break;
                        }
                    }
                }
                nStormChance = d100();
                nTStormChance += nBaseTStorm;
                if (nStormChance < nTStormChance) {
                    // Set Local Variable for area.
                    SetLocalInt(oArea, VAR_STORM, 1);
                    // Add in Lightning Effects
                    ApplyLightningEffects();
                    // Add in Wind Effects
                    ApplyWindEffects();
                    // Send Message to DMs
                    // SendMessageToAllDMs("Thunderstorm in: " + GetName(oArea));
                }
            }
        oArea = GetNextArea();
        }
    }
}

// Blizzard System
void WeatherBlizzard()
{
    int nStormChance;
    int nBlizzardChance = 0;
    object oArea;
    object oMod = GetModule();

    switch (GetLocalInt(oMod, VAR_SEASON_STORE))
    {
        case SEASON_WINTER:
            nBlizzardChance = 10;
            break;
        case SEASON_SUMMER:
            nBlizzardChance = 0;
            break;
        case SEASON_FALL:
        case SEASON_SPRING:
            nBlizzardChance = 0;
            break;
    }

    if (STORM_BLIZZARD == TRUE) {
        oArea = GetFirstArea();
        while (GetIsObjectValid(oArea)) {
            if (GetWeather(oArea) == WEATHER_SNOW) {
                if (WEATHER_TAGS == TRUE)
                {
                    string sStringValue1 = GetStringLeft(GetTag(oArea), 2);
                    string sStringValue2 = GetSubString(GetTag(oArea), 2, 3);
                    if (sStringValue1 == "ZN") { // Area has a climate
                        int iStringValue = StringToInt(sStringValue2);
                        switch (iStringValue) {
                            case 100: // Moderate Climate
                                nBlizzardChance += 5;
                                break;
                            case 101: // Jungle Climate
                                nBlizzardChance = 0;
                                break;
                            case 102: // Polar Climate
                                nBlizzardChance += 10;
                                break;
                            case 103: // Desert Climate
                                nBlizzardChance = 0;
                                break;
                            case 104: // Highland Climate
                                nBlizzardChance += 5;
                                break;
                        }
                    }
                } else if (WEATHER_TAGS == FALSE)
                {
                    int nClimateZone = GetLocalInt(oArea, "CLIMATEZONE");
                    if (nClimateZone != 0) { // Area has a climate
                        switch (nClimateZone) {
                            case 100: // Moderate Climate
                                nBlizzardChance += 5;
                                break;
                            case 101: // Jungle Climate
                                nBlizzardChance = 0;
                                break;
                            case 102: // Polar Climate
                                nBlizzardChance += 10;
                                break;
                            case 103: // Desert Climate
                                nBlizzardChance = 0;
                                break;
                            case 104: // Highland Climate
                                nBlizzardChance += 5;
                                break;
                        }
                    }
                }
                nStormChance = d100();
                nBlizzardChance += nBaseBlizzard;
                if (nStormChance < nBlizzardChance) {
                    // Set Local Variable for area.
                    SetLocalInt(oArea, VAR_STORM, 2);
                    // Add in Blizzard Effects
                    ApplyBlizzardEffects();
                    // Add in Wind Effects
                    ApplyWindEffects();
                    // Send Message to DMs
                    // SendMessageToAllDMs("Blizzard in: " + GetName(oArea));
                }
            }
        oArea = GetNextArea();
        }
    }
}

// Sandstorm System
void WeatherSandStorm()
{
    int nStormChance;
    int nSStormChance = 0;
    object oArea;
    object oMod = GetModule();

    switch (GetLocalInt(oMod, VAR_SEASON_STORE))
    {
        case SEASON_WINTER:
            nSStormChance = 0;
            break;
        case SEASON_SUMMER:
            nSStormChance = 10;
            break;
        case SEASON_FALL:
        case SEASON_SPRING:
            nSStormChance = 5;
            break;
    }

    if (STORM_SAND == TRUE) {
        oArea = GetFirstArea();
        while (GetIsObjectValid(oArea)) {
            if (WEATHER_TAGS == TRUE)
            {
                string sZoneTag = GetStringLeft(GetTag(oArea), 5);
                if (sZoneTag == "ZN103") {
                    nStormChance = d100();
                    nSStormChance += 10;
                    nSStormChance += nBaseSStorm;
                    if (nStormChance < nSStormChance) {
                        // Set Local Variable for area.
                        SetLocalInt(oArea, VAR_STORM, 3);
                        // Add in Sandstorm Effects
                        ApplySandStormEffects();
                        // Add in Wind Effects
                        ApplyWindEffects();
                        // Send Message to DMs
                        // SendMessageToAllDMs("Sandstorm in: " + GetName(oArea));
                    }
                }
            } else if (WEATHER_TAGS == FALSE)
            {
                int nClimateZone = GetLocalInt(oArea, "CLIMATEZONE");
                if (nClimateZone == 103) {
                    nStormChance = d100();
                    nSStormChance += 10;
                    nSStormChance += nBaseSStorm;
                    if (nStormChance < nSStormChance) {
                        // Set Local Variable for area.
                        SetLocalInt(oArea, VAR_STORM, 3);
                        // Add in Sandstorm Effects
                        ApplySandStormEffects();
                        // Add in Wind Effects
                        ApplyWindEffects();
                        // Send Message to DMs
                        // SendMessageToAllDMs("Sandstorm in: " + GetName(oArea));
                    }
                }
            }
        oArea = GetNextArea();
        }
    }
}

// Set the global weather.
void SetGlobalWeather()
{
    int nDuration = (nMin + Random(nMax - nMin)) * 10;
    object oMod = GetModule();

    // Global Weather Variables
    int nClearChance, nRainChance, nSnowChance, nLightningChance, nWeather, nSky, nWind;
    // Climate Variables
    int nJungleClear, nJungleRain, nJungleSnow, nJungleSky, nJungleLightning;
    int nModerateClear, nModerateRain, nModerateSnow, nModerateSky, nModerateLightning;
    int nPolarClear, nPolarRain, nPolarSnow, nPolarSky, nPolarLightning;
    int nDesertClear, nDesertRain, nDesertSnow, nDesertSky, nDesertLightning;
    int nHighlandClear, nHighlandRain, nHighlandSnow, nHighlandSky, nHighlandLightning;
    // Climate Weather Variables
    int nJungleWeather, nModerateWeather, nPolarWeather, nDesertWeather, nHighlandWeather;

    int bJungleLightning, bModerateLightning, bPolarLightning, bDesertLightning, bHighlandLightning, bLightning;

    // Determine Season for Module
    SetGlobalSeason();

    // Determine Seasonal Base Modifier. This is the % chance of a given weather pattern.
    // nClearChance, nRainChance, nSnowChance: must add up to 60
    switch (GetLocalInt(oMod, VAR_SEASON_STORE))
    {
        case SEASON_WINTER:
            SendMessageToAllDMs("Season: Winter");
            nClearChance = 5;
            nRainChance =  5;
            nSnowChance =  50;
            nLightningChance = 1;
            break;
        case SEASON_SPRING:
            SendMessageToAllDMs("Season: Spring");
            nClearChance = 20;
            nRainChance =  35;
            nSnowChance =  5;
            nLightningChance = 10;
            break;
        case SEASON_SUMMER:
            SendMessageToAllDMs("Season: Summer");
            nClearChance = 50;
            nRainChance =  10;
            nSnowChance =  0;
            nLightningChance = 5;
            break;
        case SEASON_FALL:
            SendMessageToAllDMs("Season: Fall");
            nClearChance = 40;
            nRainChance =  10;
            nSnowChance =  10;
            nLightningChance = 10;
            break;
    }

    // Set up base % for climates
    // Must add up to 40
        // Moderate - Summer Season
        if (GetLocalInt(oMod, VAR_SEASON_STORE) == SEASON_SUMMER) {
            nModerateClear = nClearChance + 20;
            nModerateRain = nRainChance + nSnowChance + 20;
            nModerateSnow = 0;
        }
        else if (GetLocalInt(oMod, VAR_SEASON_STORE) == SEASON_WINTER) {
            nModerateClear = nClearChance + 20;
            nModerateRain = nRainChance + nSnowChance;
            nModerateSnow = 20;
        }
        // Moderate - Fall/Spring Seasons
        else {
            nModerateClear = nClearChance + 18;
            nModerateRain = nRainChance + 17;
            nModerateSnow = nSnowChance;
        }
        nModerateLightning = nLightningChance + 5;
        // Jungle
        nJungleClear = nClearChance + 10;
        nJungleRain = nRainChance + nSnowChance + 30;
        nJungleSnow = 0;
        nJungleLightning = nLightningChance + 15;
        // Polar
        nPolarClear = nClearChance + 5;
        nPolarRain = nRainChance + 5;
        nPolarSnow = nSnowChance + 30;
        nPolarLightning = nLightningChance + 1;
        // Desert - no base needed. Add in if rain/snow possible in desert.
        // Highland
        nHighlandClear = nClearChance + 5;
        nHighlandRain = nRainChance + 30;
        nHighlandSnow = nSnowChance + 5;
        nHighlandLightning = nLightningChance + 10;

    // Calculate Climate Base percents
        // Moderate
        /*
        nModerateRain += nModerateClear;
        nModerateSnow += nModerateRain;
        // Jungle
        nJungleRain += nJungleClear;
        nJungleSnow += nJungleRain;
        // Polar
        nPolarRain += nPolarClear;
        nPolarSnow += nPolarRain;
        // Desert - no need to calculate. Add in if rain/snow possible in desert.
        nHighlandRain += nHighlandClear;
        nHighlandSnow += nHighlandRain;
        */

    // Determine Random number for all weather paterns to use.
    int nRandom =  d100();

    // Determine Weather/Sky in each climate zone
        // Moderate
        nModerateWeather = WEATHER_CLEAR;
        nModerateSky = SKYBOX_GRASS_CLEAR;
        if (nRandom < nModerateClear) {}
        else if (nRandom < nModerateRain) {
            nModerateWeather = WEATHER_RAIN;
            nModerateSky = SKYBOX_GRASS_STORM;
            if (nRandom < nModerateLightning) bModerateLightning = TRUE;
        }
        else if (nRandom < nModerateSnow) {
            nModerateWeather = WEATHER_SNOW;
            nModerateSky = SKYBOX_WINTER_CLEAR;
        }
        // Jungle
        nJungleWeather = WEATHER_CLEAR;
        nJungleSky = SKYBOX_GRASS_CLEAR;
        if (nRandom < nJungleClear) {}
        else if (nRandom < nJungleRain) {
            nJungleWeather = WEATHER_RAIN;
            nJungleSky = SKYBOX_GRASS_STORM;
            if (nRandom < nJungleLightning) bJungleLightning = TRUE;
        }
        else if (nRandom < nJungleSnow) {
            nJungleWeather = WEATHER_SNOW;
            nJungleSky = SKYBOX_ICY;
        }
        // Polar
        nPolarWeather = WEATHER_CLEAR;
        nPolarSky = SKYBOX_WINTER_CLEAR;
        if (nRandom < nPolarClear) {}
        else if (nRandom < nPolarRain) {
            nPolarWeather = WEATHER_RAIN;
            nPolarSky = SKYBOX_ICY;
            if (nRandom < nPolarLightning) bPolarLightning = TRUE;
        }
        else if (nRandom < nPolarSnow) {
            nPolarWeather = WEATHER_SNOW;
            nPolarSky = SKYBOX_ICY;
        }
        // Desert - no rain/snow
        nDesertWeather = WEATHER_CLEAR;
        nDesertSky = SKYBOX_DESERT_CLEAR;
        // Highland
        nHighlandWeather = WEATHER_CLEAR;
        nHighlandSky = SKYBOX_GRASS_CLEAR;
        if (nRandom < nHighlandClear) {}
        if (nRandom < nHighlandRain) {
            nHighlandWeather = WEATHER_RAIN;
            nHighlandSky = SKYBOX_GRASS_STORM;
            if (nRandom < nHighlandLightning) bHighlandLightning = TRUE;
        }
        else if (nRandom < nHighlandSnow) {
            nHighlandWeather = WEATHER_SNOW;
            nHighlandSky = SKYBOX_ICY;
        }

    // Cycle through all areas setting weather by zone
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        string sClimate = GetLocalString(oArea, "climate");

        // only proceed if there is a climate
        if (sClimate != "" && !GetIsAreaInterior(oArea))
        {
            if (sClimate == "moderate") { // Moderate Climate
                nWeather = nModerateWeather;
                nSky = nModerateSky;
                bLightning = bModerateLightning;
            }
            else if (sClimate == "jungle") { // Jungle Climate
                nWeather =  nJungleWeather;
                nSky = nJungleSky;
                bLightning = bJungleLightning;
            }
            else if (sClimate == "polar") { // Polar Climate
                nWeather = nPolarWeather;
                nSky = nPolarSky;
                bLightning = bPolarLightning;
            }
            else if (sClimate == "desert") { // Desert Climate
                nWeather = nDesertWeather;
                nSky = nDesertSky;
            }
            else if (sClimate == "highland") { // Highland Climate
                nWeather = nHighlandWeather;
                nSky = nHighlandSky;
                bLightning = bHighlandLightning;
            }
            SetWeather(oArea, nWeather);
            SetSkyBox(nSky, oArea);
            // SendMessageToAllDMs("Setting Area: " + GetName(oArea) + " to climate: " +IntToString(nWeather));

            // Fog Effects
            int nFogChance = d100();
            int nFogRnd = d20(); // Random % to add to fog amount.
            int nFogType;
            int nFog;
            if (WEATHER_FOG == TRUE) {
                // For Weather
                if (GetWeather(oArea) == WEATHER_RAIN) {
                    nFogType = FOG_TYPE_ALL;
                    nFog += FOG_RAIN;
                }
                else if (GetWeather(oArea) == WEATHER_CLEAR) {
                    nFogType = FOG_TYPE_ALL;
                    nFog = 0;
                }
                // For time of day
                // This will not occur every time since the script is called at a random time.
                if (nFogChance < FOG_PERCENT) {
                    if (GetIsDawn() == TRUE) {
                        nFogType = FOG_TYPE_SUN;
                        nFog += FOG_DAWN;
                    }
                    else if (GetIsDusk() == TRUE) {
                        nFogType = FOG_TYPE_MOON;
                        nFog += FOG_DUSK;
                    }
                    else if (GetIsNight() == TRUE) {
                        nFogType = FOG_TYPE_MOON;
                        nFog += FOG_NIGHT;
                    }
                    else {
                        nFogType = FOG_TYPE_ALL;
                        nFog = 0;
                    }
                    if (nFog > 0) {
                        nFog += nFogRnd;
                        SetFogAmount(nFogType, nFog, oArea);
                    }
                }
            }

            // Storm System
            // Default area to no storm if resulting weather is clear.
            if (GetWeather(oArea) == WEATHER_RAIN && bLightning)
            {
                NWNX_Area_SetWeatherChance(oArea, NWNX_AREA_WEATHER_CHANCE_LIGHTNING, 50);
            }
            else
            {
                NWNX_Area_SetWeatherChance(oArea, NWNX_AREA_WEATHER_CHANCE_LIGHTNING, 0);
            }
            /*
            if (GetWeather(oArea) == WEATHER_CLEAR)
            {
                SetLocalInt(oArea, VAR_STORM, 0);
            } */
        }
        /*
        else { // Area uses default climate (Moderate)
            nWeather = nModerateWeather;
            nSky = nModerateSky;
            SetWeather(oArea, nWeather);
            if (WEATHER_SKYBOX == TRUE)
                SetSkyBox(nSky,oArea);
            // SendMessageToAllDMs("Area: " + GetName(oArea) + " is using default climate.");
        }*/

        oArea = GetNextArea();
    }

    // Storm System
        // Thunderstorm
        //WeatherThunderStorm();
        // Blizzard
        //WeatherBlizzard();
        // Sandstorm
        //WeatherSandStorm();

    // Process exceptions
    //WeatherExceptions();
    SetLocalInt(oMod, "weather_duration", nDuration);
    SendDebugMessage("The next weather check occurs in: " + IntToString(nDuration)+" heartbeats");
}


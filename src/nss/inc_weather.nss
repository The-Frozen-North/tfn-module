// This library can be used to enable persistent weather for outdoor areas
// in the module. To use, put the en_weather script as the OnEnter script
// for all areas you want to take part of the persistent weather.

// In short, the library defines four different climates that will all share
// the same weather as all other areas with the same climate. The default
// climate is CLIMATE_TEMPERATE but it can be changed by placing a waypoint
// in the area with the tag given as any of the CLIMATE_WPTAG_* constants.

// This library also keeps track of seasons, but for weather it will only
// make areas with the temperate climate snow during winter rather than rain.

//////////////////////////////////////////
// CONSTANTS
//////////////////////////////////////////

const int DEBUG_LOGGING = FALSE;

const int CLIMATE_TEMPERATE = 0;
const int CLIMATE_HUMID = 1;
const int CLIMATE_DRY = 2;
const int CLIMATE_COLD = 3;

const string CLIMATE_WPTAG_TEMPERATE = "WP_CLIMATE_TEMPERATE";
const string CLIMATE_WPTAG_HUMID = "WP_CLIMATE_HUMID";
const string CLIMATE_WPTAG_DRY = "WP_CLIMATE_DRY";
const string CLIMATE_WPTAG_COLD = "WP_CLIMATE_COLD";

const string CLIMATE_NAME_TEMPERATE = "Temperate";
const string CLIMATE_NAME_HUMID = "Humid";
const string CLIMATE_NAME_DRY = "Dry";
const string CLIMATE_NAME_COLD = "Cold";

const int SEASON_NONE = 0;
const int SEASON_WINTER = 1;
const int SEASON_SPRING = 2;
const int SEASON_SUMMER = 3;
const int SEASON_AUTUMN = 4;

const int WEATHER_CHANCE_UNCHANGED = 50;
const int WEATHER_CHANCE_TEMPERATE_CLEAR = 60;
const int WEATHER_CHANCE_TEMPERATE_PRECIPITATION = 40;
const int WEATHER_CHANCE_HUMID_CLEAR = 30;
const int WEATHER_CHANCE_HUMID_PRECIPITATION = 70;
const int WEATHER_CHANCE_DRY_CLEAR = 100;
const int WEATHER_CHANCE_DRY_PRECIPITATION = 0;
const int WEATHER_CHANCE_COLD_CLEAR = 50;
const int WEATHER_CHANCE_COLD_PRECIPITATION = 50;

// These variables are set on the module, one variable for each climate.
// The name of the climate is appended to the variable name.
const string WEATHER_VAR_CURRENT_OVERRIDE_SEASON = "WeatherCurrentOverrideSeason";
const string WEATHER_VAR_CURRENT_WEATHER = "CurrentWeather";
const string WEATHER_VAR_LAST_UPDATE_HOUR = "LastWeatherUpdateHour";
const string WEATHER_VAR_LAST_UPDATE_SEASON = "LastWeatherUpdateSeason";
const string WEATHER_VAR_WEATHER_INITIALIZED = "WeatherInitialized";


//////////////////////////////////////////
// PUBLIC FUNCTION DEFINITIONS
//////////////////////////////////////////

// Check whether the weather should be updated in the area.
// Call on this function every time a player enters a outdoor area you wish
// to have persistent weather in.
void DoWeatherCheckForArea(object area = OBJECT_SELF);

// Get the climate in the area. This is by default CLIMATE_TEMPERATE.
// You can change the climate of an area by placing a waypoint with
// the tag specified by any of the CLIMATE_WPTAG_* constants.
// So if you want a humid area, place a waypoint with the tag WP_CLIMATE_HUMID.
int GetClimateInArea(object area);

// Get the current weather in an area with the specified climate.
// Returns one of the WEATHER_* constants.
// Will return WEATHER_CLEAR if no player has entered an area with this
// climate yet (in which case the weather has not been determined). This
// does not mean the weather would actually be clear if someone went there.
int GetCurrentWeatherInClimate(int climate);

// Get the current season as one of the SEASON_* constants.
// Winter = Month 12, 1, 2.
// Spring = Month 3, 4, 5.
// Summer = Month 6, 7, 8.
// Autumn = Month 9, 10, 11.
int GetCurrentSeason();

// Set the season to use instead of going by the current month.
// Call this with SEASON_NONE to restore it back to using months for seasons.
// NOTE: the new season will not take effect in an area until
// DoWeatherCheckForArea has been called again on that area.
void OverrideSeason(int season);

//////////////////////////////////////////
// PRIVATE FUNCTION IMPLEMENTATIONS
//////////////////////////////////////////

void LogDebug(string message)
{
    if (DEBUG_LOGGING)
    {
        WriteTimestampedLogEntry(message);
        SendMessageToPC(GetFirstPC(), message);
    }
}

string GetClimateName(int climate)
{
    switch (climate)
    {
        case CLIMATE_TEMPERATE: return CLIMATE_NAME_TEMPERATE;
        case CLIMATE_HUMID: return CLIMATE_NAME_HUMID;
        case CLIMATE_DRY: return CLIMATE_NAME_DRY;
        case CLIMATE_COLD: return CLIMATE_NAME_COLD;
    }

    return CLIMATE_NAME_TEMPERATE;
}

void SetClimateVariable(int climate, string variable, int value)
{
    SetLocalInt(GetModule(), variable + GetClimateName(climate), value);
}

int GetClimateVariable(int climate, string variable)
{
    return GetLocalInt(GetModule(), variable + GetClimateName(climate));
}

int GetClearChance(int climate)
{
    switch (climate)
    {
        case CLIMATE_TEMPERATE: return WEATHER_CHANCE_TEMPERATE_CLEAR;
        case CLIMATE_HUMID: return WEATHER_CHANCE_HUMID_CLEAR;
        case CLIMATE_DRY: return WEATHER_CHANCE_DRY_CLEAR;
        case CLIMATE_COLD: return WEATHER_CHANCE_COLD_CLEAR;
    }

    return WEATHER_CHANCE_TEMPERATE_CLEAR;
}

int GetPrecipitationChance(int climate)
{
    switch (climate)
    {
        case CLIMATE_TEMPERATE: return WEATHER_CHANCE_TEMPERATE_PRECIPITATION;
        case CLIMATE_HUMID: return WEATHER_CHANCE_HUMID_PRECIPITATION;
        case CLIMATE_DRY: return WEATHER_CHANCE_DRY_PRECIPITATION;
        case CLIMATE_COLD: return WEATHER_CHANCE_COLD_PRECIPITATION;
    }

    return WEATHER_CHANCE_TEMPERATE_PRECIPITATION;
}

int GetPrecipitationWeather(int climate, int season)
{
    if (climate == CLIMATE_TEMPERATE && season == SEASON_WINTER)
        return WEATHER_SNOW;
    if (climate == CLIMATE_COLD)
        return WEATHER_SNOW;
    return WEATHER_RAIN;
}

int ShouldClimateWeatherCheckBeMade(int climate)
{
    int lastUpdateSeason = GetClimateVariable(climate, WEATHER_VAR_LAST_UPDATE_SEASON);
    int lastUpdateHour = GetClimateVariable(climate, WEATHER_VAR_LAST_UPDATE_HOUR);
    int currentHour = GetTimeHour();
    int currentSeason = GetCurrentSeason();

    return lastUpdateHour != currentHour || lastUpdateSeason != currentSeason;
}

int GetNextWeatherForClimate(int currentWeather, int climate, int season)
{
    int initialized = GetClimateVariable(climate, WEATHER_VAR_WEATHER_INITIALIZED);
    int roll = Random(100);
    if (initialized && roll < WEATHER_CHANCE_UNCHANGED)
    {
        LogDebug("    Weather unchanged: Roll " + IntToString(roll) + " < " + IntToString(WEATHER_CHANCE_UNCHANGED));
        return currentWeather;
    }

    int newWeather;
    int clearChance = GetClearChance(climate);
    int precipitationChance = GetPrecipitationChance(climate);
    roll = Random(100);
    if (roll < clearChance)
    {
        newWeather = WEATHER_CLEAR;
        LogDebug("    Weather clear: Roll " + IntToString(roll) + " < " + IntToString(clearChance));
    }
    else if (roll < clearChance + precipitationChance)
    {
        newWeather = GetPrecipitationWeather(climate, season);
        LogDebug("    Weather precipitation: Roll " + IntToString(roll) + " >= " + IntToString(clearChance) + " and < " + IntToString(clearChance + precipitationChance));
    }
    else
    {
        newWeather = WEATHER_CLEAR;
        LogDebug("    Weather clear due to failure: Roll " + IntToString(roll));
    }

    return newWeather;
}

//////////////////////////////////////////
// PUBLIC FUNCTION IMPLEMENTATIONS
//////////////////////////////////////////

void DoWeatherCheckForArea(object area = OBJECT_SELF)
{
    int climate = GetClimateInArea(area);
    int weather = GetClimateVariable(climate, WEATHER_VAR_CURRENT_WEATHER);
    int season = GetCurrentSeason();

    LogDebug("DoWeatherCheckForArea: Name " + GetName(area) + " ResRef " + GetResRef(area));
    LogDebug("Climate: " + IntToString(climate));
    LogDebug("Current weather in climate: " + IntToString(weather));

    LogDebug("Last hour climate was updated: " + IntToString(GetClimateVariable(climate, WEATHER_VAR_LAST_UPDATE_HOUR)));
    LogDebug("Current hour: " + IntToString(GetTimeHour()));

    // Check whether we should update the current weather in the climate.
    if (ShouldClimateWeatherCheckBeMade(climate))
    {
        LogDebug("Checking for updated weather.");
        LogDebug("Season: " + IntToString(season));

        weather = GetNextWeatherForClimate(weather, climate, season);

        LogDebug("New climate weather: " + IntToString(weather));
    }

    // Check whether the weather in this area is different from the weather
    // in this area.
    int weatherInArea = GetWeather(area);
    if (weatherInArea != weather)
    {
        SetWeather(area, weather);
    }

    // Update the current weather for the climate.
    SetClimateVariable(climate, WEATHER_VAR_CURRENT_WEATHER, weather);
    SetClimateVariable(climate, WEATHER_VAR_LAST_UPDATE_HOUR, GetTimeHour());
    SetClimateVariable(climate, WEATHER_VAR_LAST_UPDATE_SEASON, season);
    SetClimateVariable(climate, WEATHER_VAR_WEATHER_INITIALIZED, TRUE);
}

int GetClimateInArea(object area)
{
    object obj = GetFirstObjectInArea(area);
    while (GetIsObjectValid(obj))
    {
        string tag = GetTag(obj);
        if (tag == CLIMATE_WPTAG_TEMPERATE) return CLIMATE_TEMPERATE;
        if (tag == CLIMATE_WPTAG_HUMID) return CLIMATE_HUMID;
        if (tag == CLIMATE_WPTAG_DRY) return CLIMATE_DRY;
        if (tag == CLIMATE_WPTAG_COLD) return CLIMATE_COLD;
        obj = GetNextObjectInArea(area);
    }

    return CLIMATE_TEMPERATE;
}

int GetCurrentSeason()
{
    int override = GetLocalInt(GetModule(), WEATHER_VAR_CURRENT_OVERRIDE_SEASON);
    if (override != SEASON_NONE)
        return override;

    int month = GetCalendarMonth();
    if (month == 12 || month == 1  || month == 2 ) return SEASON_WINTER;
    if (month == 3  || month == 4  || month == 5 ) return SEASON_SPRING;
    if (month == 6  || month == 7  || month == 8 ) return SEASON_SUMMER;
    if (month == 9  || month == 10 || month == 11) return SEASON_AUTUMN;
    return SEASON_NONE;
}

void OverrideSeason(int season)
{
    SetLocalInt(GetModule(), WEATHER_VAR_CURRENT_OVERRIDE_SEASON, season);
}

// For compiling standalone.
//void main() {}


/* TIME Library by Gigaschatten */

// Warning: using this library effectively is hard.  It's a very common source
// of engine bugs, so use with care.

//void main() {}

const int GS_TI_DAYTIME_NONE    =  0;
const int GS_TI_DAYTIME_DAY     =  1;
const int GS_TI_DAYTIME_NIGHT   =  2;
const int GS_TI_DAYTIME_CURRENT = -1;

//return actual timestamp
int gsTIGetActualTimestamp();
//return timestamp of given date
int gsTIGetTimestamp(int nYear, int nMonth = 0, int nDay = 0, int nHour = 0, int nMinute = 0, int nSecond = 0);
//retun year from nTimestamp
int gsTIGetYear(int nTimestamp);
//return month from nTimestamp
int gsTIGetMonth(int nTimestamp);
//return day from nTimestamp
int gsTIGetDay(int nTimestamp);
//return hour from nTimestamp
int gsTIGetHour(int nTimestamp);
//return minute from nTimestamp
int gsTIGetMinute(int nTimestamp);
//return second from nTimestamp
int gsTIGetSecond(int nTimestamp = 0);
//return game timestamp derived from realtime nTimestamp
int gsTIGetGameTimestamp(int nTimestamp = 0);
//return real timestamp derived from gametime nTimestamp
int gsTIGetRealTimestamp(int nTimestamp = 0);
//return standardized actual game minute (0 to 59)
int gsTIGetActualGameMinute();
//set game time to nTimestamp
void gsTISetTime(int nTimestamp);
//return current day time
int gsTIGetCurrentDayTime();
//return day time of oObject
int gsTIGetDayTime(object oObject = OBJECT_SELF);
//set nDayTime of oObject
void gsTISetDayTime(object oObject = OBJECT_SELF, int nDayTime = GS_TI_DAYTIME_CURRENT);
//return timestamp rounded to hour from nTimestamp
int gsTIGetFullHour(int nTimestamp);

int gsTIGetActualTimestamp()
{
    return gsTIGetTimestamp(GetCalendarYear(),
                            GetCalendarMonth() - 1,
                            GetCalendarDay() - 1,
                            GetTimeHour(),
                            gsTIGetActualGameMinute());
}
//----------------------------------------------------------------
int gsTIGetTimestamp(int nYear, int nMonth = 0, int nDay = 0, int nHour = 0, int nMinute = 0, int nSecond = 0)
{
    if (nYear) nYear -= GetLocalInt(GetModule(), "GS_YEAR");

    return 29030400 * nYear +
            2419200 * nMonth +
              86400 * nDay +
               3600 * nHour +
                 60 * nMinute +
                      nSecond;
}
//----------------------------------------------------------------
int gsTIGetYear(int nTimestamp)
{
    return GetLocalInt(GetModule(), "GS_YEAR") + nTimestamp / 29030400;
}
//----------------------------------------------------------------
int gsTIGetMonth(int nTimestamp)
{
    return nTimestamp % 29030400 / 2419200 + 1;
}
//----------------------------------------------------------------
int gsTIGetDay(int nTimestamp)
{
    return nTimestamp % 2419200 / 86400 + 1;
}
//----------------------------------------------------------------
int gsTIGetHour(int nTimestamp)
{
    return nTimestamp % 86400 / 3600;
}
//----------------------------------------------------------------
int gsTIGetMinute(int nTimestamp)
{
    return nTimestamp % 3600 / 60;
}
//----------------------------------------------------------------
int gsTIGetSecond(int nTimestamp = 0)
{
    return nTimestamp % 60;
}
//----------------------------------------------------------------
int gsTIGetGameTimestamp(int nTimestamp = 0)
{
    float fFloat = HoursToSeconds(1) / 3600.0;

    return FloatToInt(IntToFloat(nTimestamp) / fFloat);
}
//----------------------------------------------------------------
int gsTIGetRealTimestamp(int nTimestamp = 0)
{
    float fFloat = HoursToSeconds(1) / 3600.0;

    return FloatToInt(IntToFloat(nTimestamp) * fFloat);
}
//----------------------------------------------------------------
int gsTIGetActualGameMinute()
{
    float fFloat = 3600.0 / HoursToSeconds(1);

    return FloatToInt((IntToFloat(GetTimeMinute()) + IntToFloat(GetTimeSecond()) / 60) * fFloat);
}
//----------------------------------------------------------------
void gsTISetTime(int nTimestamp)
{
    SetTime(gsTIGetHour(nTimestamp), gsTIGetMinute(nTimestamp), gsTIGetSecond(nTimestamp), 0);
    SetCalendar(gsTIGetYear(nTimestamp), gsTIGetMonth(nTimestamp), gsTIGetDay(nTimestamp));

    SetLocalInt(OBJECT_SELF, "GS_TIMESTAMP", gsTIGetActualTimestamp());
}
//----------------------------------------------------------------
int gsTIGetCurrentDayTime()
{
    return GetIsDay() || GetIsDusk() ? GS_TI_DAYTIME_DAY : GS_TI_DAYTIME_NIGHT;
}
//----------------------------------------------------------------
int gsTIGetDayTime(object oObject = OBJECT_SELF)
{
    return GetLocalInt(oObject, "GS_TI_DAYTIME");
}
//----------------------------------------------------------------
void gsTISetDayTime(object oObject = OBJECT_SELF, int nDayTime = GS_TI_DAYTIME_CURRENT)
{
    if (nDayTime == GS_TI_DAYTIME_CURRENT) nDayTime = gsTIGetCurrentDayTime();
    SetLocalInt(oObject, "GS_TI_DAYTIME", nDayTime);
}
//----------------------------------------------------------------
int gsTIGetFullHour(int nTimestamp)
{
    int nNth = nTimestamp % 3600;
    if (nNth / 60 >= 15) return nTimestamp - nNth + 3600;
    else                 return nTimestamp - nNth;
}


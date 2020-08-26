// -----------------------------------------------------------------------------
//    File: util_i_strings.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds utility functions for manipulating strings.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< GetSubStringCount >---
// ---< util_i_strings >---
// Returns the number of occurrences of sSubString within sString.
int GetSubStringCount(string sString, string sSubString);

// ---< FindSubStringN >---
// ---< util_i_strings >---
// Returns the position of the nNth occurrence of sSubString within sString. If 
// the substring was not found at least nNth + 1 times, returns -1.
int FindSubStringN(string sString, string sSubString, int nNth = 0);

// ---< TrimStringLeft >---
// ---< util_i_strings >---
// Trims any characters in sRemove from the left side of sString.
string TrimStringLeft(string sString, string sRemove = " ");

// ---< TrimStringRight >---
// ---< util_i_strings >---
// Trims any characters in sRemove from the right side of sString.
string TrimStringRight(string sString, string sRemove = " ");

// ---< TrimString >---
// ---< util_i_strings >---
// Trims any characters in sRemove from the left and right side of sString. This 
// can be used to remove leading and trailing whitespace.
string TrimString(string sString, string sRemove = " ");

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

int GetSubStringCount(string sString, string sSubString)
{
    if (sString == "" || sSubString == "")
        return 0;

    int nLength = GetStringLength(sSubString);
    int nCount, nPos = FindSubString(sString, sSubString);

    while (nPos != -1)
    {
        nCount++;
        nPos = FindSubString(sString, sSubString, nPos + nLength);
    }

    return nCount;
}

int FindSubStringN(string sString, string sSubString, int nNth = 0)
{
    if (nNth < 0 || sString == "" || sSubString == "")
        return -1;

    int nLength = GetStringLength(sSubString);
    int nPos = FindSubString(sString, sSubString);

    while (--nNth >= 0 && nPos != -1)
        nPos = FindSubString(sString, sSubString, nPos + nLength);

    return nPos;
}

string GetStringSlice(string sString, int nStart, int nEnd = -1)
{
    int nLength = GetStringLength(sString);
    if (nEnd < 0 || nEnd > nLength)
        nEnd = nLength;

    if (nStart < 0 || nStart >= nLength || nStart >= nEnd)
        return "";

    return GetSubString(sString, nStart, nEnd - nStart);
}

string TrimStringLeft(string sString, string sRemove = " ")
{
    while (FindSubString(sRemove, GetStringLeft(sString, 1)) != -1)
        sString = GetStringRight(sString, GetStringLength(sString) - 1);

    return sString;
}

string TrimStringRight(string sString, string sRemove = " ")
{
    while (FindSubString(sRemove, GetStringRight(sString, 1)) != -1)
        sString = GetStringLeft(sString, GetStringLength(sString) - 1);

    return sString;
}

string TrimString(string sString, string sRemove = " ")
{
    return TrimStringRight(TrimStringLeft(sString, sRemove), sRemove);
}

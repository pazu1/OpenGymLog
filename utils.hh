#ifndef UTILS_HH
#define UTILS_HH

float epleyFormula(float w, int r)
{
    float res = (float)w*(1.f+(r/30.f));
    return res;
}

#endif // UTILS_HH

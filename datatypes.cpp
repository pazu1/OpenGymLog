#include "datatypes.hh"

Exercise::Exercise(QObject *parent)
{
}

SingleSet::SingleSet(Exercise* ex, float weight, int reps):
    m_ex(ex),
    m_weight(weight),
    m_reps(reps)
{
}


Workout::Workout(QObject *parent)
{
}

int Workout::getSetCount(QString by_exercise_name)
{
    return 1;
}

SingleSet *Workout::getSetAt(int index)
{
    return nullptr;
}

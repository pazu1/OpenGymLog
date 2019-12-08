#include "datatypes.hh"

Exercise::Exercise(QObject *parent)
{
}

SingleSet::SingleSet(QObject *parent)
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

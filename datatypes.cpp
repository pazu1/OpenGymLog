#include "datatypes.hh"

Exercise::Exercise(QObject *parent)
{
}

SingleSet::SingleSet(QObject *parent)
{
}

SingleSet::SingleSet(Exercise* ex, float weight, int reps):
    m_ex(ex),
    m_weight(weight),
    m_reps(reps)
{
    m_amount = 1;
}


Workout::Workout(QObject *parent)
{
}

void Workout::addSet(SingleSet *to_add)
{
    for (SingleSet* found : getSets())
    {
        if (found->getWeight() == to_add->getWeight() && found->getReps() == to_add->getReps() \
                && found->getExercise()->getName() == to_add->getExercise()->getName())
        {
            found->incrementAmount();
            return;
        }

    }
    m_sets.push_back(to_add);
}

int Workout::getSetCount()
{
    return int(m_sets.size());
}

SingleSet *Workout::getSetAt(int index)
{
    return getSets()[index];
}

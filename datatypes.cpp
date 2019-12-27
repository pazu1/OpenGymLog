#include "datatypes.hh"

#include <QDebug>
#include <QQmlEngine>

Exercise::Exercise(QObject *parent)
{
}

Exercise::Exercise(QString name, QString category):
    m_name(name),
    m_body_part(category)
{
}

SingleSet::SingleSet(QObject *parent)
{
}

SingleSet::SingleSet(Exercise* ex, float weight, int reps, int amount):
    m_ex(ex),
    m_weight(weight),
    m_reps(reps),
	m_amount(amount)
{
}

int SingleSet::decreaseAmount()
{
    if (m_amount == 1)
        m_amount = 0;
    else m_amount--;
    return m_amount;
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

int Workout::getSetCount(bool exclude_zero_sets)
{
    if (exclude_zero_sets)
    {
        int count = 0;
        for (SingleSet* s: m_sets)
        {
            if (s->getAmount() != 0)
                count++;
        }
        return count;
    }
    return m_sets.size();
}

SingleSet* Workout::getSetAt(int index)
{
    SingleSet* found = m_sets.at(index);
    if (found == nullptr)
    {
        return nullptr;
    }
    QString st = found->getExercise()->getName();
    QQmlEngine::setObjectOwnership(found, QQmlEngine::CppOwnership);
    return found;
}

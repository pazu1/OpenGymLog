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

Workout::Workout(QObject *parent)
{
}

Workout::~Workout()
{
    for (SingleSet* s : m_sets)
        delete s;
}

void Workout::addSet(SingleSet *to_add)
{
    m_sets.push_back(to_add);
}

int Workout::getSetCount(bool exclude_zero_sets)
{
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

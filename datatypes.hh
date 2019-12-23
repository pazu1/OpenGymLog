#ifndef EXERCISE_HH
#define EXERCISE_HH

#include <QMetaType>
#include <QObject>
#include <QDate>

using namespace std;

class Exercise : public QObject
{
    Q_OBJECT
public:
    Exercise(QObject *parent = nullptr);
    Exercise(QString name, QString category);
    Q_INVOKABLE QString getName() {return m_name;}
    Q_INVOKABLE QString getBodyPart(){return m_body_part;}
    Q_INVOKABLE void setName(QString na) {m_name = na;}
    Q_INVOKABLE void setBodyPart(QString bp){m_body_part = bp;}

private:
    QString m_name;
    QString m_body_part;
};


class SingleSet : public QObject
{
    Q_OBJECT
public:
    SingleSet(QObject *parent = nullptr);
    SingleSet(Exercise* ex, float weight, int reps, int amount = 1);
    Q_INVOKABLE Exercise* getExercise(){return m_ex;}
    Q_INVOKABLE float getWeight(){return m_weight;}
    Q_INVOKABLE int getReps(){return m_reps;}
    Q_INVOKABLE int getAmount() {return m_amount;}
    int decreaseAmount();
    void incrementAmount(){m_amount++;}

private:
    Exercise* m_ex;
    float m_weight;
    int m_reps;
    int m_amount; // eg. for 5x10 at same weight this value is 5
};

class Workout : public QObject
{
    Q_OBJECT
public:
    explicit Workout(QObject *parent = nullptr);
    void addSet(SingleSet* to_add);
    vector<SingleSet*> getSets(){return m_sets;}

    Q_INVOKABLE int getSetCount();
    Q_INVOKABLE SingleSet* getSetAt(int index);
private:
    vector<SingleSet*> m_sets;
};

#endif // EXERCISE_HH

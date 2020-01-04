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
    Q_INVOKABLE bool isToBeDeleted(){return is_garbage;}
    void orderForDeletion(){is_garbage = true;}

private:
    Exercise* m_ex;
    float m_weight;
    int m_reps;
    int m_amount; // redundant
    bool is_garbage = false;
};

class Workout : public QObject
{
    Q_OBJECT
public:
    explicit Workout(QObject *parent = nullptr);
    virtual ~Workout();
    void addSet(SingleSet* to_add);
    vector<SingleSet*> getSets(){return m_sets;}

    Q_INVOKABLE int getSetCount(bool exclude_zero_sets = false);
    Q_INVOKABLE SingleSet* getSetAt(int index);
private:
    vector<SingleSet*> m_sets;
};

#endif // EXERCISE_HH

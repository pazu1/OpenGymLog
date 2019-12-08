#ifndef EXERCISE_HH
#define EXERCISE_HH

#include <QMetaType>
#include <QObject>
#include <QDate>


class Exercise : public QObject
{
    Q_OBJECT
public:
    explicit Exercise(QObject *parent = nullptr);
    Q_INVOKABLE QString getName() {return m_name;}
    Q_INVOKABLE QString getBodyPart(){return m_body_part;}
    Q_INVOKABLE void setName(QString na) {m_name = na;}
    Q_INVOKABLE void setBodyPart(QString bp){m_body_part = bp;}

private:
    QString m_name;
    QString m_body_part;

signals:

public slots:
};


class SingleSet : public QObject
{
    Q_OBJECT
public:
    explicit SingleSet(QObject *parent = nullptr);
    Q_INVOKABLE Exercise* getExercise(){return m_ex;}
    Q_INVOKABLE float getWeight(){return m_weight;}
    Q_INVOKABLE int getReps(){return m_reps;}
private:
    Exercise* m_ex;
    float m_weight;
    int m_reps;
};

class Workout : public QObject
{
    Q_OBJECT
public:
    explicit Workout(QObject *parent = nullptr);
    Q_INVOKABLE int getSetCount(QString by_exercise_name = "");
    Q_INVOKABLE SingleSet *getSetAt(int index);
private:
    QDate m_date;
    QList<SingleSet*> m_sets;
};


#endif // EXERCISE_HH


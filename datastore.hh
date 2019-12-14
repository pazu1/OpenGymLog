#ifndef DATASTORE_H
#define DATASTORE_H

#include "datatypes.hh"

#include <QObject>
#include <QString>

#include <map>
#include <memory>

using namespace std;


class DataStore : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDate selectedDate READ selectedDate WRITE setSelectedDate NOTIFY selectedDateChanged)

public:
    explicit DataStore(QObject *parent = nullptr);
    bool createDeviceExerciseDB();
    QDate selectedDate() {return m_selected_date;}
    void setSelectedDate(QDate date);
    Q_INVOKABLE void scrollDate(int amount);
    Q_INVOKABLE int qInvokeExample(QString str);
    Q_INVOKABLE Exercise* getExerciseAt(int pos) const;
    Q_INVOKABLE int getExerciseAmount() const;
    Q_INVOKABLE void addSingleSet(QDate date, QString ex_name, float weight, int reps);

signals:
    void selectedDateChanged();

private:
    void loadExerciseDB();
    Exercise* getExerciseByName(QString name);


    // Write m_workouts into JSON
    bool writeSaveData();

    int m_count = 0;
    QString msg;

    map<QDate,Workout*> m_workouts;
    QList<Exercise*> m_excercise_DB;
    QString m_device_path;
    QDate m_selected_date;
};

#endif // DATASTORE_H

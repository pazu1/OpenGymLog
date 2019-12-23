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
    QDate selectedDate();
    void setSelectedDate(QDate date);
    Q_INVOKABLE void scrollDate(int amount);
    Q_INVOKABLE Exercise* getExerciseAt(int pos) const;
    Q_INVOKABLE Workout* getWorkout(QDate day) const;
    Q_INVOKABLE int getExerciseAmount() const;
    Q_INVOKABLE void addSingleSet(QDate date, QString ex_name, float weight, int reps);
    Q_INVOKABLE QString getDevicePath();
    Q_INVOKABLE void deleteSet(SingleSet* to_delete);

signals:
    void selectedDateChanged();

private:
    void loadExerciseDB();
    Exercise* getExerciseByName(QString name);

    // Write m_workouts to a JSON file on device
    bool writeSaveData();
    // Populate m_workouts with data saved on the device
    bool readSaveData();

    map<QDate,Workout*> m_workouts;
    QList<Exercise*> m_excercise_DB;
    QString m_device_path;
    QDate m_selected_date;
};

#endif // DATASTORE_H

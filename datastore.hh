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

public:
    explicit DataStore(QObject *parent = nullptr);
    QString message() {return msg;}
    void setMessage(QString str);
    bool createDeviceExerciseDB();
    Q_INVOKABLE int qInvokeExample(QString str);
    Q_INVOKABLE Exercise* getExerciseAt(int pos) const;
    Q_INVOKABLE int getExerciseAmount() const;
    Q_INVOKABLE void addSingleSet(QString ex_name, float weight, int reps);

signals:
    void messageChanged(); // lets all QML components know, that message was changed
                           // they will call message() to READ

public slots:
    void callMeFromQml();

private:
    void loadExerciseDB();
    Exercise* getExerciseByName(QString name);

    int m_count = 0;
    QString msg;

    map<QDate,Workout*> m_workouts;
    QList<Exercise*> m_excercise_DB;
    QString m_device_path;
};

#endif // DATASTORE_H

#ifndef DATASTORE_H
#define DATASTORE_H

#include "datatypes.hh"

#include <QObject>
#include <QString>

#include <map>
#include <memory>

using namespace std;

struct SingleSet
{
    Q_GADGET
    unsigned int reps;
    float weight;
};

/**
 * @brief SetsAcross
 * Includes one exercise and associated sets.
 */
struct SetsAcross
{
    Q_GADGET
    Exercise exercise;
    std::vector<SingleSet> sets;
};

class DataStore : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString message READ message WRITE setMessage NOTIFY messageChanged)

public:
    explicit DataStore(QObject *parent = nullptr);
    QString message() {return msg;}
    void setMessage(QString str);
    bool createDeviceExerciseDB();
    Q_INVOKABLE int qInvokeExample(QString str);
    Q_INVOKABLE Exercise* getExerciseAt(int pos);
    Q_INVOKABLE int getExerciseAmount() const;
    Q_INVOKABLE Exercise* getTestEx();

signals:
    void messageChanged(); // lets all QML components know, that message was changed
                           // they will call message() to READ

public slots:
    void callMeFromQml();

private:
    void loadExerciseDB();

    int m_count = 0;
    QString msg;

    //std::map<QDate,std::vector<SetsAcross>> m_workout_days;
    QList<Exercise*> m_excercise_DB;
    QString m_device_path;
};

#endif // DATASTORE_H

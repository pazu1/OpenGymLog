#include "datastore.hh"
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>

DataStore::DataStore(QObject *parent) : QObject(parent)
{
    m_device_path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    // Create path
    QDir dir;
    if (!dir.exists(m_device_path))
    {
        qDebug() << "Path does not exist. Creating...";
        if (dir.mkpath(m_device_path))
            qDebug() << "Path created";
    }

    createDeviceExerciseDB();
    loadExerciseDB();
}

void DataStore::setMessage(QString str)
{
    msg = str;
    emit messageChanged();
}

bool DataStore::createDeviceExerciseDB()
{

    QFile device_file(m_device_path + "/AGLExerciseData.json");

    if (device_file.exists()) // && device_file contains all loc exercises
        return false;

    QFile loc_file(":/json_files/exercises.json");
    loc_file.open(QIODevice::ReadOnly | QIODevice::Text);
    QString loc_text = loc_file.readAll();
    loc_file.close();

    /*
    QJsonDocument loc_doc = QJsonDocument::fromJson(loc_text.toUtf8());
    QJsonObject loc_exercises_obj = loc_doc.object();

    QJsonValue test = loc_exercises_obj.value("Chin Up");
    qDebug() << test["Category"].toString();*/

    device_file.open(QIODevice::ReadWrite);
    device_file.write(loc_text.toUtf8());
    device_file.close();

    return true;
}

int DataStore::qInvokeExample(QString str)
{
    qDebug() << str.toLatin1();
    return m_count;
}

Exercise* DataStore::getExerciseAt(int pos) const
{
    if (pos < m_excercise_DB.length())
        return m_excercise_DB.at(pos);
    return nullptr;
}

int DataStore::getExerciseAmount() const
{
    return m_excercise_DB.size();
}

void DataStore::addSingleSet(QString ex_name, float weight, int reps)
{
    SingleSet* new_set = new SingleSet(getExerciseByName(ex_name),weight,reps);
    QDate current = QDate::currentDate();

    if (!m_workouts.count(current))
        m_workouts[current] = new Workout();
    m_workouts[current]->addSet(new_set);
}

void DataStore::callMeFromQml()
{
    m_count++;
    setMessage(QString::number(m_count)+" hits");
}

void DataStore::loadExerciseDB()
{
    QFile device_DB(m_device_path + "/AGLExerciseData.json");
    device_DB.open(QIODevice::ReadOnly | QIODevice::Text);
    QString text_DB = device_DB.readAll();
    device_DB.close();
    QJsonObject obj_DB = QJsonDocument::fromJson(text_DB.toUtf8()).object();
    foreach(const QString& key, obj_DB.keys())
    {
        QJsonValue value = obj_DB.value(key);
        Exercise* e = new Exercise();
        e->setName(key);
        e->setBodyPart(value["Category"].toString());
        m_excercise_DB.append(e);
    }

}

Exercise *DataStore::getExerciseByName(QString name)
{
    for (Exercise* e : m_excercise_DB)
    {
        if (e->getName() == name)
        {
            return e;
        }
    }
    return nullptr;
}

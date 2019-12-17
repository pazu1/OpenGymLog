#include "datastore.hh"
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QQmlEngine>

DataStore::DataStore(QObject *parent) : QObject(parent)
{
    m_selected_date = QDate::currentDate();
    m_device_path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    // Create path
    QDir dir;
    if (!dir.exists(m_device_path))
    {
        qDebug() << "Path "+m_device_path+" does not exist. Creating...";
        if (dir.mkpath(m_device_path))
            qDebug() << "Path created";
        else qDebug() << "Error in creating path";
    }

    createDeviceExerciseDB();
    loadExerciseDB();
    writeSaveData(); // TODO: Don't call here
    readSaveData();
}

void DataStore::setSelectedDate(QDate date)
{
    m_selected_date = date;
    emit selectedDateChanged();
}

void DataStore::scrollDate(int amount)
{
    m_selected_date = m_selected_date.addDays(amount);
    emit selectedDateChanged();
}

bool DataStore::createDeviceExerciseDB()
{
    QFile device_file(m_device_path + "/OGLExerciseData.json");

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

Exercise* DataStore::getExerciseAt(int pos) const
{
    if (pos < m_excercise_DB.length())
    {
        Exercise* found =  m_excercise_DB.at(pos);
        QQmlEngine::setObjectOwnership(found, QQmlEngine::CppOwnership);
        return found;
    }
    return nullptr;
}

Workout *DataStore::getWorkout(QDate day) const
{
    if ( m_workouts.find(day) != m_workouts.end())
    {
        Workout* found = m_workouts.at(day);
        QQmlEngine::setObjectOwnership(found, QQmlEngine::CppOwnership);
        return found;
    }
    return nullptr;
}

int DataStore::getExerciseAmount() const
{
    return m_excercise_DB.size();
}

void DataStore::addSingleSet(QDate date, QString ex_name, float weight, int reps)
{
    SingleSet* new_set = new SingleSet(getExerciseByName(ex_name),weight,reps);

    if (!m_workouts.count(date))
        m_workouts[date] = new Workout();

    m_workouts[date]->addSet(new_set);
    writeSaveData();
}

QString DataStore::getDevicePath()
{
    return m_device_path;
}

void DataStore::loadExerciseDB()
{
    QFile device_DB(m_device_path + "/OGLExerciseData.json");
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
            QQmlEngine::setObjectOwnership(e, QQmlEngine::CppOwnership);
            return e;
        }
    }
    return nullptr;
}

bool DataStore::writeSaveData()
{
    QFile save_file(m_device_path + "/OGLSaveData.json");
    QJsonObject save_obj;

    for (pair<QDate, Workout*> n : m_workouts)
    {
        QString date_str = n.first.toString();

        QJsonArray sets;
        for (SingleSet* s : n.second->getSets())
        {
            QJsonObject set_obj;
            set_obj.insert("Exercise", s->getExercise()->getName());
            set_obj.insert("Weight", s->getWeight());
            set_obj.insert("Reps", s->getReps());
            set_obj.insert("Amount", s->getAmount());
            sets.append(set_obj);
        }
        save_obj.insert(date_str,sets);
        //qDebug() <<save_obj[date_str].toArray().first().toObject()["Exercise"].toString();
        //qDebug() <<QString::number(save_obj[date_str].toArray().first().toObject()["Weight"].toDouble());

    }
    QJsonDocument save_doc(save_obj);
    if (save_doc.isNull())
        return false;
    save_file.open(QFile::WriteOnly);
    save_file.write(save_doc.toJson());
    save_file.close();
    return true;
}

bool DataStore::readSaveData()
{
    return true;
}

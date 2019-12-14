#include "datastore.hh"
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

DataStore::DataStore(QObject *parent) : QObject(parent)
{
    m_device_path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    // Create path
    QDir dir;
    if (!dir.exists(m_device_path))
    {
        qDebug() << "Path "+m_device_path+" does not exist. Creating...";
        if (dir.mkpath(m_device_path))
            qDebug() << "Path created";
    }

    createDeviceExerciseDB();
    loadExerciseDB();
    writeSaveData();

    m_selected_date = QDate::currentDate();
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

void DataStore::addSingleSet(QDate date, QString ex_name, float weight, int reps)
{
    SingleSet* new_set = new SingleSet(getExerciseByName(ex_name),weight,reps);

    if (!m_workouts.count(date))
        m_workouts[date] = new Workout();

    m_workouts[date]->addSet(new_set);
    writeSaveData();
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
            return e;
        }
    }
    return nullptr;
}

bool DataStore::writeSaveData()
{
    QFile save_file(m_device_path + "/OGLSaveData.json");
    QJsonObject save_obj;

    /*
    if (save_file.exists())
    {
        qDebug() << "File exists";
        save_file.open(QIODevice::ReadOnly | QIODevice::Text);
        QString save_txt = save_file.readAll();
        QJsonDocument save_doc = QJsonDocument::fromJson(save_txt.toUtf8());
        save_obj = save_doc.object();
        save_file.close();
    } */
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
        qDebug() <<save_obj[date_str].toArray().first().toObject()["Exercise"].toString();
        qDebug() <<QString::number(save_obj[date_str].toArray().first().toObject()["Weight"].toDouble());

    }
}

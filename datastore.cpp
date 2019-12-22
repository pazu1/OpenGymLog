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
    if (!readSaveData())
		qDebug() << "Error: could not read save data";
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

    device_file.open(QIODevice::ReadWrite);
    device_file.write(loc_text.toUtf8());
    device_file.close();

    return true;
}

QDate DataStore::selectedDate()
{
    return m_selected_date;
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

void DataStore::deleteObject(SingleSet *to_delete)
{
    int decreased;
    if (to_delete->getAmount() == 1)
        decreased = 0;
    else
        decreased = to_delete->getAmount()-1;
    to_delete->setAmount(decreased);
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
        qint64 j_date = n.first.toJulianDay();
        QJsonArray sets;
        for (SingleSet* s : n.second->getSets())
        {
            QJsonObject set_obj;
            if (s->getAmount() == 0) // Set with an amount of 0 means it has been deleted.
                continue;            // No need to save it.
            set_obj.insert("Exercise", s->getExercise()->getName());
            set_obj.insert("Weight", s->getWeight());
            set_obj.insert("Reps", s->getReps());
            set_obj.insert("Amount", s->getAmount());
            sets.append(set_obj);
        }
        if (sets.size() == 0) // Don't save days with no content.
            continue;
        save_obj.insert(QString::number(j_date),sets);
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
	QFile save_file(m_device_path + "/OGLSaveData.json");
	if (!save_file.exists())
		return false;
	save_file.open(QIODevice::ReadOnly | QIODevice::Text);
	QString text_DB = save_file.readAll();
	save_file.close();
	QJsonObject save_obj = QJsonDocument::fromJson(text_DB.toUtf8()).object();

	foreach(const QString & key, save_obj.keys())
	{
		QDate f_date = QDate::fromJulianDay(key.toInt());
		QJsonArray f_array = save_obj.value(key).toArray();
        if (f_date.isNull())
			return false;
		Workout* f_workout = new Workout();
		for (QJsonValue element : f_array)
		{
			QJsonObject f_obj = element.toObject();

			SingleSet* f_set = new SingleSet(getExerciseByName(f_obj["Exercise"].toString()),
				(float)f_obj["Weight"].toDouble(),
				f_obj["Reps"].toInt(),
				f_obj["Amount"].toInt());

			f_workout->addSet(f_set);
		}
		m_workouts[f_date] = f_workout;
	}

    return true;
}

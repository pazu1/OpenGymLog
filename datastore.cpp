#include "datastore.hh"
#include "utils.hh"
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
    qDebug() << "Save path: "+m_device_path;
    if (!dir.exists(m_device_path))
    {
        qDebug() << "Path does not exist. Creating...";
        if (dir.mkpath(m_device_path))
            qDebug() << "Path created";
        else qDebug() << "Error in creating path";
    }

    createDeviceExerciseDB();
    loadExerciseDB();
    if (!readSaveData())
        qDebug() << "Error: could not read save data";
}

DataStore::~DataStore()
{
    for (pair<QDate,Workout*> p : m_workouts)
        delete p.second;

    for (Exercise* e : m_excercise_DB)
        delete e;
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

bool DataStore::addSingleSet(QDate date, QString ex_name, float weight, int reps)
{
    if (reps == 0 || QString::number(weight) == "nan")
        return false;
    SingleSet* new_set = new SingleSet(getExerciseByName(ex_name),weight,reps);

    if (!m_workouts.count(date))
        m_workouts[date] = new Workout();

    m_workouts[date]->addSet(new_set);
    writeSaveData();
    return true;
}

bool DataStore::addExercise(QString name, QString category)
{
    if (name.length() == 0 || category.length() == 0 || databaseContains(name))
        return false;
    Exercise* created_ex = new Exercise(name,category);
    m_excercise_DB.push_back(created_ex);
    return writeExerciseDB();
}

QString DataStore::getDevicePath() const
{
    return m_device_path;
}

void DataStore::deleteSet(SingleSet* to_delete)
{
    to_delete->orderForDeletion();
    for (pair<QDate, Workout*> n : m_workouts)
    {
        std::vector<SingleSet*> sets = n.second->getSets();
        for (SingleSet* s : sets)
        {
            if (s == to_delete)
            {
                n.second->getSets().pop_back();
                // let QML garbage collection handle the deletion
                QQmlEngine::setObjectOwnership(s, QQmlEngine::JavaScriptOwnership);
            }
        }
    }
    writeSaveData();
}

QStringList DataStore::getCategories() const
{
    QStringList f_categories;
    for (Exercise* e : m_excercise_DB)
    {
        if (!f_categories.contains(e->getBodyPart(), Qt::CaseInsensitive))
            f_categories.push_back(e->getBodyPart());
    }
    return f_categories;
}

QVariantList DataStore::getEstOneRepMaxes(QString ex) const
{
    QVariantList maxes;
    for (pair<QDate, Workout*> n : m_workouts)
    {
        float f_highest = 0.f;
        // Find highest Est1RM for this day
        for (SingleSet* s : n.second->getSets())
        {
            if (s->getExercise()->getName() == ex && !s->isToBeDeleted())
            {
                float estMax = epleyFormula(s->getWeight(),s->getReps());
                if (estMax > f_highest)
                {
                    if (f_highest > 0.f)
                        maxes.removeLast();
                    f_highest = estMax;
                    maxes.push_back(estMax);
                }
            }
        }

    }
    return maxes;
}


QVariantList DataStore::getDaysOfExercise(QString ex, bool as_integers) const
{
    QVariantList days;
    for (pair<QDate, Workout*> n : m_workouts)
    {
        for (SingleSet* s : n.second->getSets())
        {
            if (s->getExercise()->getName() == ex)
            {
                if (!days.contains(n.first))
                    days.push_back(n.first);
            }
        }
    }
    if (days.isEmpty())
        return days;
    if (!as_integers)
        return days;
    // Find the distance of each day from the first instance of exercise
    QVariantList day_numbers;
    QDate first_day = days.first().toDate();
    for (QVariant v: days)
    {
        QDate d = v.toDate();
        qint64 amount = first_day.daysTo(d);
        day_numbers.push_back(amount);
    }
    return day_numbers;
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

bool DataStore::writeExerciseDB()
{
    QJsonObject db_json;

    for (Exercise* e : m_excercise_DB)
    {
        QJsonObject json_ex_params;
        json_ex_params.insert("Category", e->getBodyPart());
        json_ex_params.insert("Type", "WeightReps"); // TODO: implement e->getType()
        db_json.insert(e->getName(), json_ex_params);
    }

    QJsonDocument save_doc(db_json);
    if (save_doc.isNull())
        return false;
    QFile db_file(m_device_path + "/OGLExerciseData.json");
    db_file.open(QIODevice::WriteOnly);
    db_file.write(save_doc.toJson());
    db_file.close();
    return true;
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

bool DataStore::databaseContains(QString name)
{
    for (Exercise* e : m_excercise_DB)
    {
        if (e->getName().toUpper() == name.toUpper())
            return true;
    }
    return false;
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
            if (s->isToBeDeleted())
                continue;
            set_obj.insert("Exercise", s->getExercise()->getName());
            set_obj.insert("Weight", s->getWeight());
            set_obj.insert("Reps", s->getReps());
            sets.append(set_obj);
        }
        if (sets.size() == 0) // Don't save days with no content.
            continue;
        save_obj.insert(QString::number(j_date),sets);
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
            Exercise* f_ex = getExerciseByName(f_obj["Exercise"].toString());
            if (!f_ex)
                continue;

            SingleSet* f_set = new SingleSet(f_ex,
                (float)f_obj["Weight"].toDouble(),
                f_obj["Reps"].toInt());

			f_workout->addSet(f_set);
		}
        m_workouts[f_date] = f_workout;
	}

    return true;
}

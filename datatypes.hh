#ifndef EXERCISE_HH
#define EXERCISE_HH

#include <QMetaType>
#include <QObject>


class Exercise : public QObject
{
    Q_OBJECT
public:
    explicit Exercise(QObject *parent = nullptr);
    Exercise(const Exercise&){}
    ~Exercise(){}
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


Q_DECLARE_METATYPE(Exercise)

#endif // EXERCISE_HH


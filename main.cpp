#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickView>

#include "datastore.hh"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;
    DataStore dt;

    QQmlContext* context = engine.rootContext();

    context->setContextProperty("dataStore", &dt);
    qmlRegisterType<Exercise>("com.pz.exercise",1,0,"Exercise");
    qmlRegisterType<SingleSet>("com.pz.singleset",1,0,"SingleSet");
    qmlRegisterType<Workout>("com.pz.workout",1,0,"Workout");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);



    return app.exec();
}

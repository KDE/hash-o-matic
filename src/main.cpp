/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
*/

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QApplication>
#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>

#include "about.h"
#include "clipboard.h"
#include "config-hashvalidator.h"
#include "hashhelper.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("hashvalidator");
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setApplicationName(QStringLiteral("HashValidator"));

    KAboutData aboutData(
        // The program name used internally.
        QStringLiteral("hashvalidator"),
        // A displayable program name string.
        i18nc("@title", "Hash Validator"),
        QStringLiteral(HASHVALIDATOR_VERSION_STRING),
        // Short description of what the app does.
        i18n("Check hashes for your files"),
        // The license this code is released under.
        KAboutLicense::GPL,
        // Copyright Statement.
        i18n("(c) KDE Community 2021"));
    aboutData.addAuthor(i18nc("@info:credit", "Carl Schwan"),
                        i18nc("@info:credit", "Maintainer"),
                        QStringLiteral("carl@carlschwan.eu"),
                        QStringLiteral("https://carlschwan.eu"));
    KAboutData::setApplicationData(aboutData);
    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.hashvalidator")));

    QCommandLineParser parser;
    aboutData.setupCommandLine(&parser);
    parser.process(app);
    aboutData.processCommandLine(&parser);

    QQmlApplicationEngine engine;

    Clipboard clipboard;
    qmlRegisterSingletonInstance("org.kde.hashvalidator", 1, 0, "Clipboard", &clipboard);
    qmlRegisterType<HashHelper>("org.kde.hashvalidator", 1, 0, "HashHelper");
    qmlRegisterSingletonInstance("org.kde.hashvalidator", 1, 0, "AboutType", new AboutType());

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}

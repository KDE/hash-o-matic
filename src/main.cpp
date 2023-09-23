// SPDX-License-Identifier: LGPL-2.1-or-later
// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>

#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>
#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif
#include <QCommandLineParser>
#include <QDir>
#include <QFont>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QUrl>
#include <QtQml>

#ifdef HAVE_WINDOWSYSTEM
#include <KConfigGroup>
#include <KSharedConfig>
#include <KWindowConfig>
#include <KWindowSystem>
#include <QQuickWindow>
#endif

#ifdef HAVE_KDBUSADDONS
#include <KDBusService>
#endif

#ifdef Q_OS_WINDOWS
#include <Windows.h>
#endif

#include "clipboard.h"
#include "config-hashomatic.h"
#include "controller.h"
#include "hashhelper.h"

#ifdef HAVE_WINDOWSYSTEM
static void raiseWindow(QWindow *window)
{
    if (KWindowSystem::isPlatformWayland()) {
        KWindowSystem::setCurrentXdgActivationToken(qEnvironmentVariable("XDG_ACTIVATION_TOKEN"));
    } else {
        window->raise();
    }
}
#endif

#ifdef Q_OS_ANDROID
Q_DECL_EXPORT
#endif
int main(int argc, char *argv[])
{
    QNetworkProxyFactory::setUseSystemConfiguration(true);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("org.kde.breeze"));
#else
    QIcon::setFallbackThemeName(QStringLiteral("breeze"));
#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif
    // Default to org.kde.desktop style unless the user forces another style
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }
#endif

#ifdef Q_OS_WINDOWS
    if (AttachConsole(ATTACH_PARENT_PROCESS)) {
        freopen("CONOUT$", "w", stdout);
        freopen("CONOUT$", "w", stderr);
    }

    QApplication::setStyle(QStringLiteral("breeze"));
    auto font = app.font();
    font.setPointSize(10);
    app.setFont(font);
#endif

    KLocalizedString::setApplicationDomain("hashomatic");
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setApplicationName(QStringLiteral("Hash-o-Matic"));

    KAboutData aboutData(
        // The program name used internally.
        QStringLiteral("hashomatic"),
        // A displayable program name string.
        i18nc("@title", "Hash-o-matic"),
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
    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.hashomatic")));

    QCommandLineParser parser;
    parser.setApplicationDescription(i18n("Generate hashes for file"));
    parser.addPositionalArgument(QStringLiteral("url"), i18n("Local file url"));
    aboutData.setupCommandLine(&parser);
    parser.process(app);
    aboutData.processCommandLine(&parser);

    QQmlApplicationEngine engine;
    Controller controller;
    Clipboard clipboard;
    qmlRegisterSingletonInstance("org.kde.hashomatic", 1, 0, "Clipboard", &clipboard);
    qmlRegisterType<HashHelper>("org.kde.hashomatic", 1, 0, "HashHelper");
    qmlRegisterSingletonInstance("org.kde.hashomatic", 1, 0, "Controller", &controller);

#ifdef HAVE_KDBUSADDONS
    KDBusService service(KDBusService::Unique);
    service.connect(&service, &KDBusService::activateRequested, &controller, [&controller](const QStringList &arguments, const QString &workingDirectory) {
        Q_UNUSED(workingDirectory);
        if (arguments.isEmpty()) {
            return;
        }
        auto args = arguments;
        args.removeFirst();
        if (args.count() > 0) {
            controller.setInitialFile(QUrl::fromUserInput(args.at(0), workingDirectory, QUrl::AssumeLocalFile));
        }
    });
#endif

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    if (parser.positionalArguments().length() > 0) {
        const auto args = parser.positionalArguments();
        controller.setInitialFile(QUrl::fromUserInput(args[0], QDir::currentPath(), QUrl::AssumeLocalFile));
    }

#ifdef HAVE_KDBUSADDONS
    QObject::connect(&service, &KDBusService::activateRequested, &engine, [&engine](const QStringList & /*arguments*/, const QString & /*workingDirectory*/) {
        const auto rootObjects = engine.rootObjects();
        for (auto obj : rootObjects) {
            auto view = qobject_cast<QQuickWindow *>(obj);
            if (view) {
                view->show();
                raiseWindow(view);
                return;
            }
        }
    });
#endif

#ifdef HAVE_WINDOWSYSTEM
    const auto rootObjects = engine.rootObjects();
    for (auto obj : rootObjects) {
        auto view = qobject_cast<QQuickWindow *>(obj);
        if (view) {
            KConfig dataResource(QStringLiteral("data"), KConfig::SimpleConfig, QStandardPaths::AppDataLocation);
            KConfigGroup windowGroup(&dataResource, "Window");
            KWindowConfig::restoreWindowSize(view, windowGroup);
            KWindowConfig::restoreWindowPosition(view, windowGroup);
            break;
        }
    }
#endif

    return app.exec();
}

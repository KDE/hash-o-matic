// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "controller.h"

#ifdef HAVE_WINDOWSYSTEM
#include <KConfigGroup>
#include <KSharedConfig>
#include <KWindowConfig>
#include <QQuickWindow>
#endif

void Controller::saveWindowGeometry(QQuickWindow *window)
{
#ifdef HAVE_WINDOWSYSTEM
    KConfig dataResource(QStringLiteral("data"), KConfig::SimpleConfig, QStandardPaths::AppDataLocation);
    KConfigGroup windowGroup(&dataResource, QStringLiteral("Window"));
    KWindowConfig::saveWindowPosition(window, windowGroup);
    KWindowConfig::saveWindowSize(window, windowGroup);
    dataResource.sync();
#endif
}

QUrl Controller::initialFile() const
{
    return m_initialFile;
}

void Controller::setInitialFile(const QUrl &initialFile)
{
    if (initialFile == m_initialFile) {
        return;
    }
    m_initialFile = initialFile;
    Q_EMIT initialFileChanged();
}

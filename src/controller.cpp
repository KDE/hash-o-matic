// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include "controller.h"

#include <KConfigGroup>
#include <KSharedConfig>
#include <KWindowConfig>
#include <QQuickWindow>

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

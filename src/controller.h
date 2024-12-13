// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QObject>
#include <QQuickWindow>
#include <QUrl>
#include <QtQml/qqmlregistration.h>

class Controller : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QUrl initialFile READ initialFile WRITE setInitialFile NOTIFY initialFileChanged)

public:
    QUrl initialFile() const;
    void setInitialFile(const QUrl &initialFile);

Q_SIGNALS:
    void initialFileChanged();

private:
    QUrl m_initialFile;
};

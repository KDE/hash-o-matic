// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QObject>
#include <QUrl>

class QQuickWindow;

class Controller : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl initialFile READ initialFile WRITE setInitialFile NOTIFY initialFileChanged)

public:
    QUrl initialFile() const;
    void setInitialFile(const QUrl &initialFile);
    Q_INVOKABLE void saveWindowGeometry(QQuickWindow *window);

Q_SIGNALS:
    void initialFileChanged();

private:
    QUrl m_initialFile;
};

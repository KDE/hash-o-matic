// SPDX-FileCopyrightText: 2023 g10 Code GmbH
// SPDX-FileContributor: Carl Schwan <carl.schwan@gnupg.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QObject>
#include <QWindow>
#include <QtQml/qqmlregistration.h>

class UrlHandler : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit UrlHandler(QObject *parent = nullptr);
    Q_INVOKABLE bool handleClick(const QUrl &url, QWindow *window);

private:
    bool foundSMIMEData(const QString &aUrl, QString &displayName, QString &libName, QString &keyId);
};

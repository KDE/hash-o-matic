// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class QClipboard;

/**
 * Clipboard proxy
 */
class Clipboard : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Clipboard(QObject *parent = nullptr);
    Q_INVOKABLE void saveText(QString message);

private:
    QClipboard *m_clipboard;
};

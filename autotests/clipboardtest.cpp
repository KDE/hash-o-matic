// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include <QClipboard>
#include <QtTest/QtTest>

#include "clipboard.h"

class ClipboardTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testClipboard()
    {
        Clipboard clipboard;
        clipboard.saveText(QStringLiteral("TEXT"));

        QClipboard *systemClipboard = QGuiApplication::clipboard();
        QCOMPARE(systemClipboard->text(), QStringLiteral("TEXT"));
    }
};

QTEST_MAIN(ClipboardTest)
#include "clipboardtest.moc"
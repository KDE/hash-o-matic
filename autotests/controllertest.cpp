// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include <QtTest/QtTest>
#include <QtTest/qtestcase.h>

#include "controller.h"

class ControllerTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testControllerInitialFile()
    {
        Controller controller;
        controller.setInitialFile(QUrl::fromLocalFile(QStringLiteral("Hello")));
        QCOMPARE(controller.initialFile(), QUrl::fromLocalFile(QStringLiteral("Hello")));
    }
};

QTEST_GUILESS_MAIN(ControllerTest)
#include "controllertest.moc"

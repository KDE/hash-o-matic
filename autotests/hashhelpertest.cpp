
// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include <QtTest/QtTest>

#include "hashhelper.h"

class HashHelperTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testCheckSum()
    {
        HashHelper hashHelper;
        const auto url = QUrl::fromLocalFile(QStringLiteral(DATA_DIR) + QStringLiteral("/lorem.txt"));
        hashHelper.setFile(url);
        QCOMPARE(hashHelper.file(), url);

        QCOMPARE(hashHelper.minetypeIcon(), QStringLiteral("text-plain"));
        QCOMPARE(hashHelper.fileName(), QStringLiteral("lorem.txt"));
        QCOMPARE(hashHelper.md5sum(), QStringLiteral("2616533d28e2d51d42fc7ce94538aeef"));
        QCOMPARE(hashHelper.sha1sum(), QStringLiteral("04868f9523219367127a01189e3975eef9245b0c"));
        QCOMPARE(hashHelper.sha256sum(), QStringLiteral("e31185799b8aae3b4df68a7f4489dc0ca8fb3cd2a175961a447401db6411d2e8"));
    }
};

QTEST_GUILESS_MAIN(HashHelperTest)
#include "hashhelpertest.moc"

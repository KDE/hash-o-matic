// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QObject>
#include <QUrl>
#include <QMimeDatabase>

class HashHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl file READ file WRITE setFile NOTIFY fileChanged)
    Q_PROPERTY(QString minetypeIcon READ minetypeIcon NOTIFY fileChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileChanged)
    Q_PROPERTY(QString md5sum READ md5sum NOTIFY md5sumChanged)
    Q_PROPERTY(QString sha1sum READ sha1sum NOTIFY sha1sumChanged)
    Q_PROPERTY(QString sha256sum READ sha256sum NOTIFY sha256sumChanged)

public:
    explicit HashHelper(QObject *parent = nullptr);
    ~HashHelper() = default;
    QUrl file() const;
    QString minetypeIcon() const;
    QString fileName() const;
    void setFile(const QUrl &url);
    QString md5sum() const;
    QString sha1sum() const;
    QString sha256sum() const;

Q_SIGNALS:
    void fileChanged();
    void md5sumChanged();
    void sha1sumChanged();
    void sha256sumChanged();
    void errorOccured(const QString &error);

private:
    void computeHash();
    QUrl m_file;
    QString m_md5sum;
    QString m_sha1sum;
    QString m_sha256sum;
    QMimeDatabase m_mineDatabase;
};

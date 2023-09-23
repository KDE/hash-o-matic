// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "hashhelper.h"

#include <KLocalizedString>
#include <QCryptographicHash>
#include <QFile>
#include <QFileInfo>
#include <QProcess>

HashHelper::HashHelper(QObject *parent)
    : QObject(parent)
{
}

QUrl HashHelper::file() const
{
    return m_file;
}

void HashHelper::setFile(const QUrl &url)
{
    if (url == m_file) {
        return;
    }
    QFileInfo info(url.toLocalFile());
    if (info.isDir()) {
        Q_EMIT errorOccured(i18n("Hash-o-matic doesn't support directories."));
        return;
    }
    m_file = url;
    Q_EMIT fileChanged();
    computeHash();
}

QString HashHelper::md5sum() const
{
    return m_md5sum;
}

QString HashHelper::sha1sum() const
{
    return m_sha1sum;
}

QString HashHelper::sha256sum() const
{
    return m_sha256sum;
}

void HashHelper::computeHash()
{
    QFile file(m_file.toLocalFile());
    if (!file.open(QIODevice::ReadOnly | QIODeviceBase::Text)) {
        Q_EMIT errorOccured(i18n("The file doesn't exist or is not readable."));
        m_file = QUrl();
        Q_EMIT fileChanged();
        return;
    }
    const QByteArray data(file.readAll());


    QCryptographicHash hash(QCryptographicHash::Algorithm::Md5);
    hash.addData(data);
    m_md5sum = QString::fromUtf8(hash.result().toHex());
    Q_EMIT md5sumChanged();

    QCryptographicHash hash1(QCryptographicHash::Algorithm::Sha1);
    hash1.addData(data);
    m_sha1sum = QString::fromUtf8(hash1.result().toHex());
    Q_EMIT sha1sumChanged();

    QCryptographicHash hash2(QCryptographicHash::Algorithm::Sha256);
    hash2.addData(data);
    m_sha256sum = QString::fromUtf8(hash2.result().toHex());
    Q_EMIT sha256sumChanged();
}

QString HashHelper::minetypeIcon() const
{
    return m_mineDatabase.mimeTypeForUrl(m_file).iconName();
}

QString HashHelper::fileName() const
{
    return QFileInfo(m_file.toLocalFile()).fileName();
}

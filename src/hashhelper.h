// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QDateTime>
#include <QMimeDatabase>
#include <QObject>
#include <QUrl>

#ifdef HAVE_GPGME
#include <QGpgME/Protocol>
#include <gpgme++/key.h>
#endif

class SignatureInfo
{
    Q_GADGET
    Q_PROPERTY(QByteArray keyId MEMBER keyId CONSTANT)
    Q_PROPERTY(bool keyMissing MEMBER keyMissing CONSTANT)
    Q_PROPERTY(bool keyRevoked MEMBER keyRevoked CONSTANT)
    Q_PROPERTY(bool keyExpired MEMBER keyExpired CONSTANT)
    Q_PROPERTY(bool sigExpired MEMBER sigExpired CONSTANT)
    Q_PROPERTY(bool crlMissing MEMBER crlMissing CONSTANT)
    Q_PROPERTY(bool crlTooOld MEMBER crlTooOld CONSTANT)

    Q_PROPERTY(QString details MEMBER details CONSTANT)
    Q_PROPERTY(QString signers MEMBER signers CONSTANT)
    Q_PROPERTY(bool signatureIsGood MEMBER signatureIsGood CONSTANT)
    Q_PROPERTY(bool isCompliant MEMBER isCompliant CONSTANT)
#ifdef HAVE_GPGME
    Q_PROPERTY(GpgME::Signature::Validity keyTrust MEMBER keyTrust CONSTANT)
#endif

public:
    bool keyRevoked = false;
    bool keyExpired = false;
    bool sigExpired = false;
    bool keyMissing = false;
    bool crlMissing = false;
    bool crlTooOld = false;
    bool isCompliant = false;
    QString compliance;
    QString signers;
    QString details;
    QByteArray keyId;
#ifdef HAVE_GPGME
    GpgME::Signature::Validity keyTrust;
    QGpgME::Protocol *cryptoProto;
#endif

    QStringList signerMailAddresses;
    bool signatureIsGood = false;
};

class HashHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl file READ file WRITE setFile NOTIFY fileChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileChanged)
    Q_PROPERTY(QString minetypeIcon READ minetypeIcon NOTIFY fileChanged)

    Q_PROPERTY(QUrl sigFile READ sigFile WRITE setSigFile NOTIFY sigFileChanged)
    Q_PROPERTY(QString sigFileName READ sigFileName NOTIFY sigFileChanged)
    Q_PROPERTY(QString sigMinetypeIcon READ sigMinetypeIcon NOTIFY sigFileChanged)

    Q_PROPERTY(QString md5sum READ md5sum NOTIFY md5sumChanged)
    Q_PROPERTY(QString sha1sum READ sha1sum NOTIFY sha1sumChanged)
    Q_PROPERTY(QString sha256sum READ sha256sum NOTIFY sha256sumChanged)
    Q_PROPERTY(bool gpgAvailable READ gpgAvailable CONSTANT)
    Q_PROPERTY(bool hasSignature READ hasSignature NOTIFY fileChanged)
    Q_PROPERTY(SignatureInfo signatureInfo READ signatureInfo NOTIFY signatureChanged)

public:
    explicit HashHelper(QObject *parent = nullptr);
    ~HashHelper() = default;

    QUrl file() const;
    void setFile(const QUrl &url);

    QString fileName() const;
    QString minetypeIcon() const;

    QUrl sigFile() const;
    void setSigFile(const QUrl &url);

    QString sigFileName() const;
    QString sigMinetypeIcon() const;

    QString md5sum() const;
    QString sha1sum() const;
    QString sha256sum() const;

    bool gpgAvailable() const;
    bool hasSignature() const;
    SignatureInfo signatureInfo() const;

Q_SIGNALS:
    void fileChanged();
    void sigFileChanged();
    void md5sumChanged();
    void sha1sumChanged();
    void sha256sumChanged();
    void errorOccured(const QString &error);
    void signatureChanged();

private:
    void computeHash();
    void checkSignature(const QByteArray &data);
    QUrl m_file;
    QUrl m_sigFile;
    QString m_md5sum;
    QString m_sha1sum;
    QString m_sha256sum;
    QByteArray m_signature;
    QMimeDatabase m_mineDatabase;
    SignatureInfo m_signatureInfo;
};

// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "hashhelper.h"

#include <KLocalizedString>
#include <QCryptographicHash>
#include <QFile>
#include <QFileInfo>
#include <QProcess>

#ifdef HAVE_GPGME
#include <QGpgME/DN>
#include <QGpgME/KeyListJob>
#include <QGpgME/VerifyDetachedJob>

#include <gpgme++/verificationresult.h>
#include <gpgme.h>

#include <Libkleo/Compliance>
#include <Libkleo/KeyCache>

using namespace QGpgME;
using namespace GpgME;

namespace
{

QString prettifyDN(const char *uid)
{
    return QGpgME::DN(uid).prettyDN();
}

int signatureToStatus(const GpgME::Signature &sig)
{
    switch (sig.status().code()) {
    case GPG_ERR_NO_ERROR:
        return GPGME_SIG_STAT_GOOD;
    case GPG_ERR_BAD_SIGNATURE:
        return GPGME_SIG_STAT_BAD;
    case GPG_ERR_NO_PUBKEY:
        return GPGME_SIG_STAT_NOKEY;
    case GPG_ERR_NO_DATA:
        return GPGME_SIG_STAT_NOSIG;
    case GPG_ERR_SIG_EXPIRED:
        return GPGME_SIG_STAT_GOOD_EXP;
    case GPG_ERR_KEY_EXPIRED:
        return GPGME_SIG_STAT_GOOD_EXPKEY;
    default:
        return GPGME_SIG_STAT_ERROR;
    }
}

QString getDetails(const SignatureInfo &signatureDetails)
{
    QString href;
    if (signatureDetails.cryptoProto) {
        href = QStringLiteral("messageviewer:showCertificate#%1 ### %2 ### %3")
                   .arg(signatureDetails.cryptoProto->displayName(), signatureDetails.cryptoProto->name(), QString::fromLatin1(signatureDetails.keyId));
    }

    QString details;
    if (signatureDetails.keyMissing) {
        if (Kleo::DeVSCompliance::isCompliant() && signatureDetails.isCompliant) {
            details += i18nc("@label",
                             "This file has been signed VS-NfD compliant using the key <a href=\"%1\">%2</a>.",
                             href,
                             QString::fromUtf8(signatureDetails.keyId))
                + QLatin1Char('\n');
        } else {
            details += i18nc("@label", "This file has been signed using the key <a href=\"%1\">%2</a>.", href, QString::fromUtf8(signatureDetails.keyId))
                + QLatin1Char('\n');
        }
        details += i18nc("@label", "The key details are not available.");
    } else {
        if (Kleo::DeVSCompliance::isCompliant() && signatureDetails.isCompliant) {
            details += i18nc("@label", "This file has been signed VS-NfD compliant by %1.", signatureDetails.signers.toHtmlEscaped());
        } else {
            details += i18nc("@label", "This file has been signed by %1.", signatureDetails.signers.toHtmlEscaped());
        }
        if (signatureDetails.keyRevoked) {
            details += QLatin1Char('\n') + i18nc("@label", "The <a href=\"%1\">key</a> was revoked.", href);
        }
        if (signatureDetails.keyExpired) {
            details += QLatin1Char('\n') + i18nc("@label", "The <a href=\"%1\">key</a> was expired.", href);
        }

        if (signatureDetails.keyTrust == GpgME::Signature::Unknown) {
            details += QLatin1Char(' ') + i18nc("@label", "The signature is valid, but the <a href=\"%1\">key</a>'s validity is unknown.", href);
        } else if (signatureDetails.keyTrust == GpgME::Signature::Marginal) {
            details += QLatin1Char(' ') + i18nc("@label", "The signature is valid and the <a href=\"%1\">key</a> is marginally trusted.", href);
        } else if (signatureDetails.keyTrust == GpgME::Signature::Full) {
            details += QLatin1Char(' ') + i18nc("@label", "The signature is valid and the <a href=\"%1\">key</a> is fully trusted.", href);
        } else if (signatureDetails.keyTrust == GpgME::Signature::Ultimate) {
            details += QLatin1Char(' ') + i18nc("@label", "The signature is valid and the <a href=\"%1\">key</a> is ultimately trusted.", href);
        } else {
            details += QLatin1Char(' ') + i18nc("@label", "The signature is valid, but the <a href=\"%1\">key</a> is untrusted.", href);
        }
        if (!signatureDetails.signatureIsGood && !signatureDetails.keyRevoked && !signatureDetails.keyExpired
            && signatureDetails.keyTrust != GpgME::Signature::Unknown) {
            details += QLatin1Char(' ') + i18nc("@label", "The signature is invalid.");
        }
    }
    return details;
}

SignatureInfo extractSignatureInfo(const std::vector<Signature> &signatures, QGpgME::Protocol *cryptoProto)
{
    SignatureInfo signatureInfo;
    if (signatures.size() > 1) {
        qWarning() << "Can't deal with more than one signature";
    }

    for (const auto &signature : signatures) {
        const auto statusCode = signatureToStatus(signature);
        signatureInfo.signatureIsGood = statusCode == GPGME_SIG_STAT_GOOD;

        GpgME::Key key;

        if (!key.keyID()) {
            // Search for the key by its fingerprint so that we can check for
            // trust etc.
            key = Kleo::KeyCache::instance()->findByFingerprint(signature.fingerprint());
            if (key.isNull() && signature.fingerprint()) {
                // try to find a subkey that was used for signing;
                // assumes that the key ID is the last 16 characters of the fingerprint
                const auto fpr = std::string_view{signature.fingerprint()};
                const auto keyID = std::string{fpr, fpr.size() - 16, 16};
                const auto subkeys = Kleo::KeyCache::instance()->findSubkeysByKeyID({keyID});
                if (subkeys.size() > 0) {
                    key = subkeys[0].parent();
                }
            }
            if (key.isNull()) {
                qDebug() << "Found no key or subkey for fingerprint" << signature.fingerprint();
            }
        }

        signatureInfo.keyId = key.keyID();
        if (signatureInfo.keyId.isEmpty()) {
            signatureInfo.keyId = signature.fingerprint();
        }
        signatureInfo.keyMissing = signature.summary() & GpgME::Signature::KeyMissing;
        signatureInfo.keyExpired = signature.summary() & GpgME::Signature::KeyExpired;
        signatureInfo.keyRevoked = signature.summary() & GpgME::Signature::KeyRevoked;
        signatureInfo.sigExpired = signature.summary() & GpgME::Signature::SigExpired;
        signatureInfo.crlMissing = signature.summary() & GpgME::Signature::CrlMissing;
        signatureInfo.crlTooOld = signature.summary() & GpgME::Signature::CrlTooOld;
        signatureInfo.cryptoProto = cryptoProto;

        if (Kleo::DeVSCompliance::isCompliant()) {
            signatureInfo.isCompliant = signature.isDeVs();
            Kleo::DeVSCompliance::name(signature.isDeVs());
        }

        int i = 0;
        for (const auto &userId : key.userIDs()) {
            if (i != 0) {
                signatureInfo.signers += i18nc("list separator", ", ");
            }
            signatureInfo.signers += prettifyDN(userId.id());
            if (userId.email()) {
                QString email = QString::fromUtf8(userId.email());
                if (!email.isEmpty()) {
                    signatureInfo.signers += email;
                }
            }
            i++;
        }
        signatureInfo.keyTrust = signature.validity();
    }
    signatureInfo.details = getDetails(signatureInfo);
    return signatureInfo;
}
}

#endif

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
    if (!info.exists() || info.isDir()) {
        Q_EMIT errorOccured(i18n("Hash-o-matic doesn't support directories."));
        return;
    }
    m_file = url;
    m_signature = QByteArray();

#ifdef HAVE_GPGME
    QString sigPath = url.toLocalFile() + QStringLiteral(".sig");
    if (QFileInfo::exists(sigPath) && !info.isDir()) {
        QFile sig(sigPath);
        if (sig.open(QIODevice::ReadOnly | QIODeviceBase::Text)) {
            const auto content = sig.readAll().trimmed();
            if (content.startsWith("-----BEGIN PGP SIGNATURE")) {
                m_signature = content;
            }
            m_sigFile = QUrl::fromLocalFile(sigPath);
            Q_EMIT sigFileChanged();
        }
    }
#endif

    Q_EMIT fileChanged();
    computeHash();
}

QUrl HashHelper::sigFile() const
{
    return m_sigFile;
}

void HashHelper::setSigFile(const QUrl &url)
{
    if (m_sigFile == url) {
        return;
    }

    QFile sig(url.toLocalFile());
    if (sig.open(QIODevice::ReadOnly | QIODeviceBase::Text)) {
        const auto content = sig.readAll().trimmed();
        if (content.startsWith("-----BEGIN PGP SIGNATURE")) {
            m_signature = content;
            computeHash();
            return;
        }
    }

    Q_EMIT sigFileChanged();
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
#ifdef Q_OS_WINDOWS
    if (!file.open(QIODevice::ReadOnly | QIODeviceBase::Text)) {
#else
    if (!file.open(QIODevice::ReadOnly)) {
#endif
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

    if (hasSignature()) {
        checkSignature(data);
    }
}

bool HashHelper::gpgAvailable() const
{
#ifdef HAVE_GPGME
    return true;
#else
    return false;
#endif
}

void HashHelper::checkSignature(const QByteArray &data)
{
#ifdef HAVE_GPGME
    const auto proto = QGpgME::openpgp();
    auto verifyJob = proto->verifyDetachedJob();
    connect(verifyJob, &VerifyDetachedJob::result, this, [this, proto](const VerificationResult &verificationResult, const QString &, const GpgME::Error &) {
        m_signatureInfo = extractSignatureInfo(verificationResult.signatures(), proto);
        Q_EMIT signatureChanged();
    });

    if (const Error err = verifyJob->start(m_signature, data)) {
        m_signatureInfo = SignatureInfo{};
    }
#endif
}

SignatureInfo HashHelper::signatureInfo() const
{
    return m_signatureInfo;
}

bool HashHelper::hasSignature() const
{
    return !m_signature.isEmpty();
}

QString HashHelper::minetypeIcon() const
{
    return m_mineDatabase.mimeTypeForUrl(m_file).iconName();
}

QString HashHelper::sigMinetypeIcon() const
{
    return m_mineDatabase.mimeTypeForUrl(m_sigFile).iconName();
}

QString HashHelper::fileName() const
{
    return QFileInfo(m_file.toLocalFile()).fileName();
}

QString HashHelper::sigFileName() const
{
    return QFileInfo(m_sigFile.toLocalFile()).fileName();
}

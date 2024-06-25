// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard 1 as FormCard
import org.kde.hashomatic

FormCard.FormCardPage {
    id: root

    title: i18nc("@title", "Verify Hash")

    Kirigami.Icon {
        source: "org.kde.hashomatic"

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        Layout.preferredHeight: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        Layout.topMargin: Kirigami.Units.largeSpacing * 4
    }

    Kirigami.Heading {
        text: hashHelper.gpgAvailable ? i18n("Verify checksums and signatures") : i18n("Verify checksums")
        visible: text.length > 0

        type: Kirigami.Heading.Primary
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        wrapMode: Text.WordWrap

        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
    }

    FormCard.FormHeader {
        Layout.topMargin: Kirigami.Units.largeSpacing * 4
        title: i18nc("@title:group", "File")
    }

    FormCard.FormCard {
        FormCard.FormButtonDelegate {
            icon.name: "document-open-folder"
            text: i18nc("@action:button", "Select file")
            onClicked: fileDialog.open()
        }

        FormCard.FormDelegateSeparator { visible: hashHelper.md5sum.length > 0 }

        FormCard.FormTextDelegate {
            visible: hashHelper.md5sum.length > 0
            text: hashHelper.fileName
            icon.name: hashHelper.minetypeIcon
        }
    }

    FormCard.FormHeader {
        title: i18nc("@title:group", "Checksum Verification")
    }

    FormCard.FormCard {
        FormCard.FormTextFieldDelegate {
            id: hashField
            enabled: hashHelper.file.toString().length  > 0
            label: i18nc("@label", "Checksum")
        }
    }

    FormCard.FormCard {
        id: resultCard
        readonly property int type: {
            if (hashHelper.sha256sum.length === 0 || hashField.text.length === 0) {
                return 1;
            } else if (hashHelper.sha256sum === hashField.text || hashField.text === hashHelper.sha1sum || hashField.text === hashHelper.md5sum) {
                return 0;
            } else {
                return 2;
            }
        }

        Layout.topMargin: Kirigami.Units.gridUnit

        Kirigami.Theme.inherit: false
        Kirigami.Theme.backgroundColor: type === 0 ? Kirigami.Theme.positiveBackgroundColor : Kirigami.Theme.negativeBackgroundColor

        visible: resultCard.type !== 1

        FormCard.FormTextDelegate {
            text: resultCard.type === 0 ? i18n("Checksum match with the file!") : i18n("Checksum doesn't match with the file!")
        }
    }

    FormCard.FormHeader {
        visible: hashHelper.gpgAvailable
        title: i18nc("@title:group", "Signature Verification")
    }

    FormCard.FormCard {
        visible: hashHelper.gpgAvailable
        FormCard.FormButtonDelegate {
            icon.name: "document-open-folder"
            text: i18nc("@action:button", "Select signature file")
            onClicked: fileDialog.open()
            enabled: hashHelper.file.toString().length  > 0
        }

        FormCard.FormDelegateSeparator { visible: hashHelper.sigFile.toString().length > 0 }

        FormCard.FormTextDelegate {
            visible: hashHelper.sigFileName.length  > 0
            text: hashHelper.sigFileName
            icon.name: hashHelper.sigMinetypeIcon
        }
    }

    FormCard.FormCard {
        id: sigResultCard

        Layout.topMargin: Kirigami.Units.gridUnit

        readonly property bool isValid: hashHelper.signatureInfo.keyId
            && !hashHelper.signatureInfo.keyExpired
            && !hashHelper.signatureInfo.keyMissing
            && !hashHelper.signatureInfo.keyRevoked
            && !hashHelper.signatureInfo.sigExpired
            && !hashHelper.signatureInfo.crlMissing
            && !hashHelper.signatureInfo.crlTooOld

        Kirigami.Theme.inherit: false
        Kirigami.Theme.backgroundColor: isValid ? Kirigami.Theme.positiveBackgroundColor : Kirigami.Theme.negativeBackgroundColor

        visible: hashHelper.hasSignature

        FormCard.FormTextDelegate {
            id: details
            text: hashHelper.signatureInfo.details
            textItem.wrapMode: Text.WordWrap
            textItem.elide: Text.ElideNone

            Connections {
                target: details.textItem
                function onLinkActivated(link: string) {
                    UrlHandler.handleClick(link, applicationWindow());
                }
            }
        }
    }

    data: [
        DropArea {
            id: dropAreaFile
            anchors.fill: parent
            parent: root
            onDropped: if (drop.urls.length > 0) {
                hashHelper.file = drop.urls[0];
            } else if (drop.hasText) {
                hashField.text = drop.text;
            }
        },

        QQC2.Popup {
            visible: dropAreaFile.containsDrag
            height: parent ? parent.height -  Kirigami.Units.gridUnit * 2 : 0
            width: parent ? parent.width - Kirigami.Units.gridUnit * 2 : 0
            x: Kirigami.Units.gridUnit
            y: Kirigami.Units.gridUnit
            modal: true
            parent: root.QQC2.Overlay.overlay
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false

            Kirigami.PlaceholderMessage {
                anchors.centerIn: parent
                width: parent.width - (Kirigami.Units.largeSpacing * 4)
                text: i18n("Drag items here to verify them")
            }
        }
    ]
}

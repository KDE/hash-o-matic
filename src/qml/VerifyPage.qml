// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtCore
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.hashomatic

FormCard.FormCardPage {
    id: root

    required property HashHelper helper

    title: i18nc("@title", "Verify Hash")

    Kirigami.Icon {
        source: "org.kde.hashomatic"

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        Layout.preferredHeight: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        Layout.topMargin: Kirigami.Units.largeSpacing * 4
    }

    Kirigami.Heading {
        text: root.helper.gpgAvailable ? i18n("Verify checksums and signatures") : i18n("Verify checksums")
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
        FormCard.FormFileDelegate {
            icon.name: root.helper.file.toString().length > 0 ? root.helper.minetypeIcon : "document-open-folder"
            label: i18nc("@action:button", "Select file")
            currentFolder: StandardPaths.standardLocations(StandardPaths.DownloadsLocation)[0]
            onAccepted: root.helper.file = selectedFile
            fileMode: FileDialog.OpenFile
        }
    }

    FormCard.FormHeader {
        title: i18nc("@title:group", "Checksum Verification")
    }

    FormCard.FormCard {
        FormCard.FormTextFieldDelegate {
            id: hashField
            enabled: root.helper.file.toString().length  > 0
            label: i18nc("@label", "Checksum")
        }
    }

    FormCard.FormCard {
        id: resultCard
        readonly property int type: {
            if (root.helper.sha256sum.length === 0 || hashField.text.length === 0) {
                return 1;
            } else if (root.helper.sha256sum === hashField.text || hashField.text === root.helper.sha1sum || hashField.text === root.helper.md5sum) {
                return 0;
            } else {
                return 2;
            }
        }

        Layout.topMargin: Kirigami.Units.gridUnit

        Kirigami.Theme.inherit: false
        Kirigami.Theme.backgroundColor: type === 0 ? root.Kirigami.Theme.positiveBackgroundColor : root.Kirigami.Theme.negativeBackgroundColor

        visible: resultCard.type !== 1

        FormCard.FormTextDelegate {
            text: resultCard.type === 0 ? i18n("Checksum match with the file!") : i18n("Checksum doesn't match with the file!")
        }
    }

    FormCard.FormHeader {
        visible: root.helper.gpgAvailable
        title: i18nc("@title:group", "Signature Verification")
    }

    FormCard.FormCard {
        visible: root.helper.gpgAvailable
        FormCard.FormFileDelegate {
            icon.name: root.helper.sigFile.toString().length > 0 ? root.helper.sigMinetypeIcon : "document-open-folder"
            label: i18nc("@action:button", "Select signature file")
            enabled: root.helper.file.toString().length  > 0
            currentFolder: StandardPaths.standardLocations(StandardPaths.DownloadsLocation)[0]
            onAccepted: root.helper.sigFile = selectedFile
            fileMode: FileDialog.OpenFile
        }
    }

    FormCard.FormCard {
        id: sigResultCard

        Layout.topMargin: Kirigami.Units.gridUnit

        readonly property bool isValid: root.helper.signatureInfo.keyId
            && !root.helper.signatureInfo.keyExpired
            && !root.helper.signatureInfo.keyMissing
            && !root.helper.signatureInfo.keyRevoked
            && !root.helper.signatureInfo.sigExpired
            && !root.helper.signatureInfo.crlMissing
            && !root.helper.signatureInfo.crlTooOld

        Kirigami.Theme.inherit: false
        Kirigami.Theme.backgroundColor: isValid ? root.Kirigami.Theme.positiveBackgroundColor : root.Kirigami.Theme.negativeBackgroundColor

        visible: root.helper.hasSignature

        FormCard.FormTextDelegate {
            id: details
            text: root.helper.signatureInfo.details
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
                root.helper.file = drop.urls[0];
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

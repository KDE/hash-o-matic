// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard 1 as FormCard
import org.kde.hashomatic
import Qt.labs.platform

FormCard.FormCardPage {
    id: root

    title: i18nc("@title", "Generate Hash")

    Kirigami.Icon {
        source: "org.kde.hashomatic"

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        Layout.preferredHeight: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        Layout.topMargin: Kirigami.Units.largeSpacing * 4
    }

    Kirigami.Heading {
        text: i18n("Display Checksums")

        type: Kirigami.Heading.Primary
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        wrapMode: Text.WordWrap

        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
    }

    FormCard.FormCard {
        Layout.topMargin: Kirigami.Units.largeSpacing * 4

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
        title: i18nc("@title:group", "Hashes")
        visible: hashHelper.md5sum.length > 0
    }

    FormCard.FormCard {
        visible: hashHelper.md5sum.length > 0

        FormCard.FormTextDelegate {
            text: i18nc("Hashing algorithm", "MD5:")
            description: hashHelper.md5sum
            trailing: QQC2.Button {
                text: i18n("Copy hash")
                icon.name: 'edit-copy'
                onClicked: {
                    Clipboard.saveText(hashHelper.md5sum);
                    applicationWindow().showPassiveNotification(i18n("Hash copied into the clipboard"), "short");
                }
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            text: i18nc("Hashing algorithm", "SHA1:")
            description: hashHelper.sha1sum
            trailing: QQC2.Button {
                text: i18n("Copy hash")
                icon.name: 'edit-copy'
                onClicked: {
                    Clipboard.saveText(hashHelper.sha1sum);
                    applicationWindow().showPassiveNotification(i18n("Hash copied into the clipboard"), "short");
                }
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            text: i18nc("Hashing algorithm", "SHA256:")
            description: hashHelper.sha256sum
            trailing: QQC2.Button {
                text: i18n("Copy hash")
                icon.name: 'edit-copy'
                onClicked: {
                    Clipboard.saveText(hashHelper.sha256sum);
                    applicationWindow().showPassiveNotification(i18n("Hash copied into the clipboard"), "short");
                }
            }
        }
    }

    data: [
        DropArea {
            id: dropAreaFile
            parent: root
            anchors.fill: parent
            onDropped: hashHelper.file = drop.urls[0]
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
                text: i18n("Drag items here to share them")
            }
        }
    ]
}

// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtCore
import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.hashomatic

FormCard.FormCardPage {
    id: root

    required property HashHelper helper

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

        FormCard.FormFileDelegate {
            label: i18nc("@action:button", "Select file")
            icon.name: root.helper.file.toString().length > 0 ? root.helper.minetypeIcon : "document-open-folder"
            currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
            onAccepted: root.helper.file = selectedFile
            fileMode: FileDialog.OpenFile
        }
    }

    FormCard.FormHeader {
        title: i18nc("@title:group", "Hashes")
        visible: root.helper.md5sum.length > 0
    }

    FormCard.FormCard {
        visible: root.helper.md5sum.length > 0

        FormCard.FormTextDelegate {
            text: i18nc("Hashing algorithm", "MD5:")
            description: root.helper.md5sum
            trailing: QQC2.Button {
                text: i18n("Copy hash")
                icon.name: 'edit-copy'
                onClicked: {
                    Clipboard.saveText(root.helper.md5sum);
                    applicationWindow().showPassiveNotification(i18n("Hash copied into the clipboard"), "short");
                }
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            text: i18nc("Hashing algorithm", "SHA1:")
            description: root.helper.sha1sum
            trailing: QQC2.Button {
                text: i18n("Copy hash")
                icon.name: 'edit-copy'
                onClicked: {
                    Clipboard.saveText(root.helper.sha1sum);
                    applicationWindow().showPassiveNotification(i18n("Hash copied into the clipboard"), "short");
                }
            }
        }

        FormCard.FormDelegateSeparator {}

        FormCard.FormTextDelegate {
            text: i18nc("Hashing algorithm", "SHA256:")
            description: root.helper.sha256sum
            trailing: QQC2.Button {
                text: i18n("Copy hash")
                icon.name: 'edit-copy'
                onClicked: {
                    Clipboard.saveText(root.helper.sha256sum);
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
            onDropped: root.helper.file = drop.urls[0]
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

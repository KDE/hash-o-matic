// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard 1 as FormCard

FormCard.FormCardPage {
    id: root

    title: i18nc("@title", "Verify Hash")

    Kirigami.PlaceholderMessage {
        icon.name: "org.kde.hashomatic"
        Layout.preferredWidth: parent.width - Kirigami.Units.gridUnit * 4
        Layout.topMargin: Kirigami.Units.gridUnit
        Layout.alignment: Qt.AlignHCenter
        text: i18n("Verify that file match checksum")
    }

    FormCard.FormHeader {
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
        title: i18nc("@title:group", "Verification")
    }

    FormCard.FormCard {
        FormCard.FormTextFieldDelegate {
            id: hashField
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
            text: resultCard.type === 0 ? i18n("They match!") : i18n("They don't match!")
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

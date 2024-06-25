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

    title: i18nc("@title", "Compare files")

    Kirigami.Icon {
        source: "org.kde.hashomatic"

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        Layout.preferredHeight: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        Layout.topMargin: Kirigami.Units.largeSpacing * 4
    }

    Kirigami.Heading {
        text: i18nc("@title", "Compare Two Files")

        type: Kirigami.Heading.Primary
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        wrapMode: Text.WordWrap

        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing
    }

    FormCard.FormHeader {
        Layout.topMargin: Kirigami.Units.largeSpacing * 4
        title: i18nc("@title:group", "File 1")
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
        title: i18nc("@title:group", "File 2")
    }

    FormCard.FormCard {
        FormCard.FormButtonDelegate {
            icon.name: "document-open-folder"
            text: i18nc("@action:button", "Select file")
            onClicked: fileDialog2.open()
        }

        FormCard.FormDelegateSeparator { visible: hashHelper.md5sum.length > 0 }

        FormCard.FormTextDelegate {
            visible: hashHelper2.md5sum.length > 0
            text: hashHelper2.fileName
            icon.name: hashHelper2.minetypeIcon
        }
    }

    FormCard.FormCard {
        id: resultCard
        readonly property int type: {
            if (hashHelper.sha256sum === "" || hashHelper2.sha256sum === "") {
                return 1;
            } else if (hashHelper2.sha256sum === hashHelper.sha256sum) {
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
        HashHelper {
            id: hashHelper2
            onErrorOccured: applicationWindow().showPassiveNotification(error, 'short')
        },

        FileDialog {
            id: fileDialog2
            folder: StandardPaths.writableLocation(StandardPaths.DownloadsLocation)
            onAccepted: hashHelper2.file = currentFile
        },

        DropArea {
            id: dropAreaFile1
            parent: root
            height: parent.height / 2
            width: parent.width
            onDropped: hashHelper.file = drop.urls[0]
        },

        DropArea {
            id: dropAreaFile2
            parent: root
            y: parent.height / 2
            height: parent.height / 2
            width: parent.width
            onDropped: hashHelper2.file = drop.urls[0]
        },

        QQC2.Popup {
            visible: dropAreaFile1.containsDrag || dropAreaFile2.containsDrag
            height: parent ? parent.height -  Kirigami.Units.gridUnit * 2 : 0
            width: parent ? parent.width - Kirigami.Units.gridUnit * 2 : 0
            x: Kirigami.Units.gridUnit
            y: Kirigami.Units.gridUnit
            modal: true
            parent: root.QQC2.Overlay.overlay

            background: Item {}

            contentItem: ColumnLayout {
                spacing: Kirigami.Units.gridUnit
                QQC2.Pane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Kirigami.Theme.colorSet: dropAreaFile1.containsDrag ? Kirigami.Theme.View : Kirigami.Theme.Window
                    Kirigami.Theme.inherit: false
                    Kirigami.PlaceholderMessage {
                        anchors.centerIn: parent
                        width: parent.width - (Kirigami.Units.largeSpacing * 4)
                        text: i18n("Drag file here to compare it")
                        explanation: hashHelper.md5sum.length > 0 ? hashHelper.fileName : ''
                        icon.name: hashHelper.md5sum === "" ? "document-open-folder" : hashHelper.minetypeIcon
                    }
                }
                QQC2.Pane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Kirigami.Theme.colorSet: dropAreaFile2.containsDrag ? Kirigami.Theme.View : Kirigami.Theme.Window
                    Kirigami.Theme.inherit: false
                    Kirigami.PlaceholderMessage {
                        anchors.centerIn: parent
                        width: parent.width - (Kirigami.Units.largeSpacing * 4)
                        text: i18n("Drag file here to compare it")
                        explanation: hashHelper2.md5sum.length > 0 ? hashHelper2.fileName : ''
                        icon.name: hashHelper2.md5sum === "" ? "document-open-folder" : hashHelper2.minetypeIcon
                    }
                }
            }
        }
    ]
}

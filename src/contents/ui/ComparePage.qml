// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
// SPDX-License-Identifier: LGPL-2.1-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.19 as Kirigami
import org.kde.hashvalidator 1.0
import Qt.labs.platform 1.1

Kirigami.Page {
    id: page

    title: i18n("Compare files")

    HashHelper {
        id: hashHelper2
        onErrorOccured: applicationWindow().showPassiveNotification(error, 'short')
    }

    FileDialog {
        id: fileDialog2
        folder: StandardPaths.writableLocation(StandardPaths.DownloadsLocation)
        onAccepted: hashHelper2.file = currentFile
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            QQC2.Label {
                text: i18n("File 1:")
            }
            QQC2.Button {
                icon.name: hashHelper.md5sum === "" ? "document-open-folder" : hashHelper.minetypeIcon
                text: hashHelper.md5sum === "" ? i18nc("@action:button", "Select file") : hashHelper.fileName
                onClicked: fileDialog.open()
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            QQC2.Label {
                text: i18n("File 2:")
            }
            QQC2.Button {
                icon.name: hashHelper2.md5sum === "" ? "document-open-folder" : hashHelper2.minetypeIcon
                text: hashHelper2.md5sum === "" ? i18nc("@action:button", "Select file to compare") : hashHelper2.fileName
                onClicked: fileDialog2.open()
            }
        }

        QQC2.Label {
            Layout.topMargin: Kirigami.Units.gridUnit
            Layout.alignment: Qt.AlignHCenter
            readonly property int type: {
                if (hashHelper.sha256sum === "" || hashHelper2.sha256sum === "") {
                    return 1;
                } else if (hashHelper2.sha256sum === hashHelper.sha256sum) {
                    return 0;
                } else {
                    return 2;
                }
            }
            text: type === 0 ? i18n('They match!') : i18n("They don't match!")
            visible: type !== 1
            color: type === 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
        }
    }
}

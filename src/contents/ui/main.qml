// SPDX-License-Identifier: LGPL-2.1-or-later
// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>

import QtQuick 2.6
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.19 as Kirigami
import org.kde.hashvalidator 1.0
import Qt.labs.platform 1.1

Kirigami.ApplicationWindow {
    id: root

    minimumWidth: Kirigami.Units.gridUnit * 30
    minimumHeight: Kirigami.Units.gridUnit * 20

    property bool wasEmpty: true

    HashHelper {
        id: hashHelper
        onMd5sumChanged: if (wasEmpty && hashHelper.md5sum !== "") {
            wasEmpty = false;
            generateAction.trigger();
        }
        onErrorOccured: applicationWindow().showPassiveNotification(error, 'short')
    }

    FileDialog {
        id: fileDialog
        folder: StandardPaths.writableLocation(StandardPaths.DownloadsLocation)
        onAccepted: hashHelper.file = currentFile
    }

    globalDrawer: Kirigami.GlobalDrawer {
        titleIcon: "applications-graphics"
        isMenu: true
        actions: [
            Kirigami.PagePoolAction {
                text: i18n("About")
                icon.name: "help-about"
                page: 'qrc:AboutPage.qml'
                pagePool: mainPagePool
                checkable: false
                useLayers: true
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    Kirigami.PagePool {
        id: mainPagePool
    }

    footer: Kirigami.NavigationTabBar {
        visible: hashHelper.md5sum !== ""
        actions: [
            Kirigami.PagePoolAction {
                id: generateAction
                text: i18n("Generate")
                icon.name: "password-generate"
                page: "qrc:/GeneratePage.qml"
                pagePool: mainPagePool
            },
            Kirigami.PagePoolAction {
                text: i18n("Compare")
                icon.name: "kompare"
                page: "qrc:/ComparePage.qml"
                pagePool: mainPagePool
            },
            Kirigami.PagePoolAction {
                text: i18n("Verify")
                icon.name: "document-edit-decrypt-verify"
                page: "qrc:/VerifyPage.qml"
                pagePool: mainPagePool
            }
        ]
    }

    pageStack.initialPage: mainPagePool.loadPage('qrc:/WelcomePage.qml')
}

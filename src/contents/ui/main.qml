// SPDX-License-Identifier: LGPL-2.1-or-later
// SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>

import QtQuick 2.6
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.19 as Kirigami
import org.kde.hashomatic 1.0
import Qt.labs.platform 1.1

Kirigami.ApplicationWindow {
    id: root

    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 20

    onClosing: Controller.saveWindowGeometry(root)

    // This timer allows to batch update the window size change to reduce
    // the io load and also work around the fact that x/y/width/height are
    // changed when loading the page and overwrite the saved geometry from
    // the previous session.
    Timer {
        id: saveWindowGeometryTimer
        interval: 1000
        onTriggered: Controller.saveWindowGeometry(root)
    }

    onWidthChanged: saveWindowGeometryTimer.restart()
    onHeightChanged: saveWindowGeometryTimer.restart()
    onXChanged: saveWindowGeometryTimer.restart()
    onYChanged: saveWindowGeometryTimer.restart()

    property bool wasEmpty: true

    Loader {
        active: !Kirigami.Settings.isMobile
        source: Qt.resolvedUrl("qrc:/GlobalMenu.qml")
    }

    HashHelper {
        id: hashHelper
        onMd5sumChanged: if (wasEmpty && hashHelper.md5sum.length > 0) {
            wasEmpty = false;
            generateAction.trigger();
        }
        onErrorOccured: applicationWindow().showPassiveNotification(error, 'short')
    }

    Connections {
        target: Controller
        onInitialFileChanged: hashHelper.file = Controller.initialFile
    }

    FileDialog {
        id: fileDialog
        folder: StandardPaths.writableLocation(StandardPaths.DownloadsLocation)
        onAccepted: hashHelper.file = currentFile
    }

    globalDrawer: Kirigami.GlobalDrawer {
        titleIcon: "applications-graphics"
        isMenu: enabled
        enabled: !Kirigami.Settings.hasPlatformMenuBar
        actions: Kirigami.PagePoolAction {
            id: aboutAction
            text: i18n("About")
            icon.name: "help-about"
            page: 'qrc:AboutPage.qml'
            pagePool: mainPagePool
            checkable: false
            useLayers: true
        }
    }

    Kirigami.PagePool {
        id: mainPagePool
    }

    footer: Kirigami.NavigationTabBar {
        actions: [
            Kirigami.PagePoolAction {
                id: generateAction
                text: i18nc("@action:inmenu", "Generate")
                icon.name: "password-generate"
                page: "qrc:/GeneratePage.qml"
                pagePool: mainPagePool
            },
            Kirigami.PagePoolAction {
                id: compareAction
                text: i18nc("@action:inmenu", "Compare")
                icon.name: "kompare"
                page: "qrc:/ComparePage.qml"
                pagePool: mainPagePool
            },
            Kirigami.PagePoolAction {
                id: verifyAction
                text: i18nc("@action:inmenu", "Verify")
                icon.name: "document-edit-decrypt-verify"
                page: "qrc:/VerifyPage.qml"
                pagePool: mainPagePool
            }
        ]
    }

    pageStack.initialPage: mainPagePool.loadPage('qrc:/WelcomePage.qml')
}

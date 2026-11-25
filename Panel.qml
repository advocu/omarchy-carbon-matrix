import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "CarbonData.js" as CarbonData

Panel {
  id: root
  moduleName: "io.github.advocu.carbon-matrix"
  ipcTarget: "io.github.advocu.carbon-matrix"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  property string selectedCategory: "All"
  property string searchQuery: ""
  property string selectedId: "C-01"

  readonly property color fgColor: root.barForeground
  readonly property color dimFg: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.68)
  readonly property color subtleBorder: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.16)
  readonly property color cardBg: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.05)

  readonly property var selectedItem: {
    var items = CarbonData.CARBON_ITEMS;
    for (var i = 0; i < items.length; i++) {
      if (items[i].id === root.selectedId) return items[i];
    }
    return items[0];
  }

  function itemMatchesFilter(item) {
    if (!item) return false;
    var catOk = root.selectedCategory === "All" || item.category === root.selectedCategory;
    if (!catOk) return false;
    var q = root.searchQuery.trim().toLowerCase();
    if (q === "") return true;
    if (item.id.toLowerCase().indexOf(q) !== -1) return true;
    if (item.name.toLowerCase().indexOf(q) !== -1) return true;
    if (item.shortName && item.shortName.toLowerCase().indexOf(q) !== -1) return true;
    if (item.noobHint && item.noobHint.toLowerCase().indexOf(q) !== -1) return true;
    if (item.symbol.toLowerCase().indexOf(q) !== -1) return true;
    if (item.iupacSuffix.toLowerCase().indexOf(q) !== -1) return true;
    for (var i = 0; i < item.realWorld.length; i++) {
      if (item.realWorld[i].toLowerCase().indexOf(q) !== -1) return true;
    }
    return false;
  }

  function open() {
    root.controller.show();
  }

  function openFromHotkey() {
    root.controller.show();
  }

  function close() {
    root.controller.hide();
  }

  function toggle() {
    if (root.opened) root.close();
    else root.openFromHotkey();
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction);
    return false;
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: false
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(1040))
    contentHeight: panel.fittedContentHeight(Style.space(650))

    content: PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: searchField.activeFocus
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: mainCol
        anchors.fill: parent
        spacing: Style.space(10)

        // ---- Top Header: Title + Search
        Item {
          id: headerBar
          width: parent.width
          height: Style.space(34)

          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: "THE CARBON MATRIX — ORGANIC CHEMISTRY FOR NOOBS"
            color: root.fgColor
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.weight: Font.Bold
          }

          Rectangle {
            id: searchBox
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Style.space(280)
            height: Style.space(30)
            radius: Style.space(6)
            color: root.cardBg
            border.width: 1
            border.color: searchField.activeFocus ? "#10B981" : root.subtleBorder

            TextInput {
              id: searchField
              anchors.fill: parent
              anchors.leftMargin: Style.space(10)
              anchors.rightMargin: Style.space(24)
              verticalAlignment: TextInput.AlignVCenter
              color: root.fgColor
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              clip: true
              onTextChanged: root.searchQuery = text
              Keys.onEscapePressed: {
                if (text !== "") text = "";
                else {
                  focus = false;
                  root.close();
                }
              }

              Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.PlainText
                text: "Search carbon form or example..."
                color: root.dimFg
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                visible: searchField.text === "" && !searchField.activeFocus
              }
            }

            Text {
              anchors.right: parent.right
              anchors.rightMargin: Style.space(8)
              anchors.verticalCenter: parent.verticalCenter
              textFormat: Text.PlainText
              text: "✕"
              color: root.dimFg
              font.pixelSize: Style.font.bodySmall
              visible: searchField.text !== ""

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: searchField.text = ""
              }
            }
          }
        }

        // ---- Category Filter Pills Row
        Flickable {
          id: filterFlick
          width: parent.width
          height: Style.space(30)
          contentWidth: filterRow.implicitWidth
          contentHeight: height
          clip: true
          boundsBehavior: Flickable.StopAtBounds

          Row {
            id: filterRow
            spacing: Style.space(6)

            Repeater {
              model: CarbonData.CATEGORIES
              delegate: Rectangle {
                id: catPill
                readonly property bool isActive: root.selectedCategory === modelData.name
                implicitWidth: labelText.implicitWidth + Style.space(20)
                implicitHeight: Style.space(28)
                radius: height / 2
                color: isActive ? modelData.color : root.cardBg
                border.width: 1
                border.color: isActive ? modelData.color : root.subtleBorder

                Text {
                  id: labelText
                  anchors.centerIn: parent
                  textFormat: Text.PlainText
                  text: modelData.name
                  color: catPill.isActive ? "#0B1120" : root.fgColor
                  font.family: Style.font.family
                  font.pixelSize: Style.font.bodySmall
                  font.weight: catPill.isActive ? Font.Bold : Font.Medium
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.selectedCategory = modelData.name
                }
              }
            }
          }
        }

        // ---- Split Body: Left 6x6 Matrix + Right Beginner Detail Card
        Row {
          id: bodyRow
          width: parent.width
          height: mainCol.height - headerBar.height - filterFlick.height - Style.space(20)
          spacing: Style.space(14)

          // Left Pane: 6x6 Grid
          Grid {
            id: matrixGrid
            width: Math.max(Style.space(618), Math.floor(bodyRow.width * 0.59))
            height: bodyRow.height
            columns: 6
            rows: 6
            columnSpacing: Style.space(6)
            rowSpacing: Style.space(6)

            readonly property real tileW: Math.floor((width - columnSpacing * 5) / 6)
            readonly property real tileH: Math.floor((height - rowSpacing * 5) / 6)

            Repeater {
              model: CarbonData.CARBON_ITEMS
              delegate: Rectangle {
                id: tile
                readonly property color catColor: CarbonData.categoryColor(modelData.category)
                readonly property bool isSelected: root.selectedId === modelData.id
                readonly property bool isMatched: root.itemMatchesFilter(modelData)

                width: matrixGrid.tileW
                height: matrixGrid.tileH
                clip: true
                radius: Style.space(6)
                opacity: isMatched ? 1.0 : 0.22
                color: isSelected
                  ? Qt.rgba(catColor.r, catColor.g, catColor.b, 0.24)
                  : root.cardBg
                border.width: isSelected ? 2 : 1
                border.color: isSelected
                  ? catColor
                  : Qt.rgba(catColor.r, catColor.g, catColor.b, 0.55)

                Item {
                  anchors.fill: parent
                  anchors.margins: Style.space(5)

                  Text {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    textFormat: Text.PlainText
                    text: modelData.id
                    color: tile.catColor
                    font.family: Style.font.family
                    font.pixelSize: 12
                    font.weight: Font.Bold
                  }

                  Text {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -Style.space(8)
                    width: parent.width - 4
                    textFormat: Text.PlainText
                    text: modelData.symbol
                    color: "#F8FAFC"
                    font.family: Style.font.family
                    font.pixelSize: 19
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                  }

                  Column {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 1

                    Text {
                      width: parent.width - 4
                      anchors.horizontalCenter: parent.horizontalCenter
                      textFormat: Text.PlainText
                      text: modelData.shortName
                      color: "#FFFFFF"
                      font.family: Style.font.family
                      font.pixelSize: 14
                      font.weight: Font.Bold
                      horizontalAlignment: Text.AlignHCenter
                      maximumLineCount: 1
                      elide: Text.ElideRight
                    }

                    Text {
                      width: parent.width - 4
                      anchors.horizontalCenter: parent.horizontalCenter
                      textFormat: Text.PlainText
                      text: modelData.noobHint
                      color: "#CBD5E1"
                      font.family: Style.font.family
                      font.pixelSize: 11
                      horizontalAlignment: Text.AlignHCenter
                      maximumLineCount: 1
                      elide: Text.ElideRight
                    }
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.selectedId = modelData.id
                }
              }
            }
          }

          // Right Pane: Beginner Detail Card
          Rectangle {
            id: detailCard
            width: bodyRow.width - matrixGrid.width - bodyRow.spacing
            height: bodyRow.height
            radius: Style.space(8)
            color: root.cardBg
            border.width: 1
            border.color: root.subtleBorder

            readonly property color activeCatColor: CarbonData.categoryColor(root.selectedItem.category)

            Flickable {
              id: detailScroll
              anchors.fill: parent
              anchors.margins: Style.space(10)
              contentWidth: width
              contentHeight: detailCol.implicitHeight
              clip: true
              boundsBehavior: Flickable.StopAtBounds
              ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
              }

              Column {
                id: detailCol
                width: detailScroll.width
                spacing: Style.space(7)

                // Title + Category Badge
                Row {
                  width: parent.width
                  spacing: Style.space(8)

                  Rectangle {
                    implicitWidth: idTxt.implicitWidth + Style.space(12)
                    implicitHeight: Style.space(22)
                    radius: Style.space(4)
                    color: detailCard.activeCatColor
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                      id: idTxt
                      anchors.centerIn: parent
                      textFormat: Text.PlainText
                      text: root.selectedItem.id
                      color: "#0B1120"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.bodySmall
                      font.weight: Font.Bold
                    }
                  }

                  Text {
                    width: parent.width - Style.space(70)
                    textFormat: Text.PlainText
                    text: root.selectedItem.name
                    color: root.fgColor
                    font.family: Style.font.family
                    font.pixelSize: Style.font.subtitle
                    font.weight: Font.Bold
                    wrapMode: Text.WordWrap
                  }
                }

                // Metadata Chips: Category, Formula, Suffix, Hybridization, Angle
                Flow {
                  width: parent.width
                  spacing: Style.space(5)

                  Repeater {
                    model: [
                      root.selectedItem.category,
                      "Formula: " + root.selectedItem.formulaExample,
                      "Word Ending: " + root.selectedItem.iupacSuffix,
                      root.selectedItem.hybridization,
                      "Angle: " + root.selectedItem.bondAngle
                    ]
                    delegate: Rectangle {
                      implicitWidth: chipTxt.implicitWidth + 16
                      implicitHeight: chipTxt.implicitHeight + 8
                      radius: Style.space(4)
                      color: Qt.rgba(root.fgColor.r, root.fgColor.g, root.fgColor.b, 0.08)
                      border.width: 1
                      border.color: root.subtleBorder

                      Text {
                        id: chipTxt
                        anchors.centerIn: parent
                        textFormat: Text.PlainText
                        text: modelData
                        color: root.fgColor
                        font.family: Style.font.family
                        font.pixelSize: 11
                      }
                    }
                  }
                }

                // Live 2D Molecular Bond Canvas
                MolecularCanvas {
                  width: parent.width
                  height: Style.space(155)
                  itemData: root.selectedItem
                  panelForeground: root.fgColor
                }

                // Section 1: What Is It? (Noob Translation)
                Column {
                  width: parent.width
                  spacing: Style.space(3)

                  Text {
                    textFormat: Text.PlainText
                    text: "What Is It? (Noob Translation)"
                    color: detailCard.activeCatColor
                    font.family: Style.font.family
                    font.pixelSize: 15
                    font.weight: Font.Bold
                  }

                  Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    text: root.selectedItem.eli12
                    color: root.fgColor
                    font.family: Style.font.family
                    font.pixelSize: 14
                    lineHeight: 1.35
                    wrapMode: Text.WordWrap
                  }
                }

                // Section 2: How To Spot It In A Formula
                Column {
                  width: parent.width
                  spacing: Style.space(3)

                  Text {
                    textFormat: Text.PlainText
                    text: "How To Spot It In A Formula"
                    color: detailCard.activeCatColor
                    font.family: Style.font.family
                    font.pixelSize: 15
                    font.weight: Font.Bold
                  }

                  Text {
                    width: parent.width
                    textFormat: Text.PlainText
                    text: root.selectedItem.howToSpot + " — Behavior: " + root.selectedItem.reactivity
                    color: root.dimFg
                    font.family: Style.font.family
                    font.pixelSize: 14
                    lineHeight: 1.35
                    wrapMode: Text.WordWrap
                  }
                }

                // Section 3: Where You Touch Or Eat It Daily
                Column {
                  width: parent.width
                  spacing: Style.space(5)

                  Text {
                    textFormat: Text.PlainText
                    text: "Where You Touch Or Eat It Daily"
                    color: detailCard.activeCatColor
                    font.family: Style.font.family
                    font.pixelSize: 15
                    font.weight: Font.Bold
                  }

                  Flow {
                    width: parent.width
                    spacing: Style.space(6)

                    Repeater {
                      model: root.selectedItem.realWorld
                      delegate: Rectangle {
                        implicitWidth: rwTxt.implicitWidth + Style.space(14)
                        implicitHeight: Style.space(24)
                        radius: Style.space(12)
                        color: Qt.rgba(detailCard.activeCatColor.r, detailCard.activeCatColor.g, detailCard.activeCatColor.b, 0.16)
                        border.width: 1
                        border.color: Qt.rgba(detailCard.activeCatColor.r, detailCard.activeCatColor.g, detailCard.activeCatColor.b, 0.6)

                        Text {
                          id: rwTxt
                          anchors.centerIn: parent
                          textFormat: Text.PlainText
                          text: modelData
                          color: root.fgColor
                          font.family: Style.font.family
                          font.pixelSize: Style.font.caption
                          font.weight: Font.Medium
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

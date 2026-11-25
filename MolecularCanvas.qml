import QtQuick
import qs.Commons
import qs.Commons as Commons

Item {
  id: root

  property var itemData: null
  property bool showFullAtoms: true
  property color panelForeground: Commons.Color.foreground

  implicitHeight: 216

  onItemDataChanged: molCanvas.requestPaint()
  onShowFullAtomsChanged: molCanvas.requestPaint()
  onPanelForegroundChanged: molCanvas.requestPaint()

  // Bordered container with 3 non-overlapping vertical zones: Top bar (32), Canvas (140), Legend (38)
  Rectangle {
    anchors.fill: parent
    radius: Style.space(8)
    color: Qt.rgba(0, 0, 0, 0.22)
    border.width: 1
    border.color: Qt.rgba(root.panelForeground.r, root.panelForeground.g, root.panelForeground.b, 0.14)
    clip: true

    Column {
      anchors.fill: parent
      spacing: 0

      // ---- Zone 1: Top bar (height: 32)
      Item {
        width: parent.width
        height: 32

        Text {
          anchors.left: parent.left
          anchors.leftMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          text: "[Space] Toggle View"
          color: Qt.rgba(root.panelForeground.r, root.panelForeground.g, root.panelForeground.b, 0.55)
          font.family: Style.font.family
          font.pixelSize: 11
        }

        Rectangle {
          id: togglePill
          anchors.right: parent.right
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          implicitWidth: toggleLabel.implicitWidth + 16
          implicitHeight: 24
          radius: height / 2
          color: root.showFullAtoms
            ? Qt.rgba(16 / 255, 185 / 255, 129 / 255, 0.22)
            : Qt.rgba(168 / 255, 85 / 255, 247 / 255, 0.22)
          border.width: 1
          border.color: root.showFullAtoms ? "#10B981" : "#A855F7"

          Text {
            id: toggleLabel
            anchors.centerIn: parent
            textFormat: Text.PlainText
            text: root.showFullAtoms ? "View: Full Atoms (Noob)" : "View: Skeletal Lines (Pro)"
            color: root.panelForeground
            font.family: Style.font.family
            font.pixelSize: 11
            font.weight: Font.Medium
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.showFullAtoms = !root.showFullAtoms
          }
        }
      }

      // ---- Zone 2: Middle Canvas (height: 140, strictly reserved for 2D drawing)
      Canvas {
        id: molCanvas
        width: parent.width
        height: 140
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
          var ctx = getContext("2d");
          ctx.reset();
          if (width <= 10 || height <= 10 || !root.itemData) return;

          var mode = root.itemData.canvasMode || "tetravalency";
          var full = root.showFullAtoms;
          var cx = width * 0.5;
          var cy = height * 0.5;
          var u = Math.min(width * 0.22, height * 0.215);

          var C_COL = "#10B981";
          var O_COL = "#EF4444";
          var N_COL = "#3B82F6";
          var H_COL = "#94A3B8";
          var S_COL = "#EAB308";
          var X_COL = "#22D3EE";
          var P_COL = "#F97316";
          var BOND_COL = "rgba(226, 232, 240, 0.85)";
          var ARC_COL = "rgba(250, 204, 21, 0.85)";

          function drawBond(x1, y1, x2, y2, order) {
            order = order || 1;
            var dx = x2 - x1;
            var dy = y2 - y1;
            var len = Math.sqrt(dx * dx + dy * dy) || 1;
            var nx = -dy / len;
            var ny = dx / len;
            ctx.strokeStyle = BOND_COL;
            ctx.lineCap = "round";

            if (order === 1) {
              ctx.lineWidth = 2.4;
              ctx.beginPath();
              ctx.moveTo(x1, y1);
              ctx.lineTo(x2, y2);
              ctx.stroke();
            } else if (order === 2) {
              var off2 = 3.0;
              ctx.lineWidth = 2.0;
              ctx.beginPath();
              ctx.moveTo(x1 + nx * off2, y1 + ny * off2);
              ctx.lineTo(x2 + nx * off2, y2 + ny * off2);
              ctx.moveTo(x1 - nx * off2, y1 - ny * off2);
              ctx.lineTo(x2 - nx * off2, y2 - ny * off2);
              ctx.stroke();
            } else if (order === 3) {
              var off3 = 4.2;
              ctx.lineWidth = 1.8;
              ctx.beginPath();
              ctx.moveTo(x1, y1);
              ctx.lineTo(x2, y2);
              ctx.moveTo(x1 + nx * off3, y1 + ny * off3);
              ctx.lineTo(x2 + nx * off3, y2 + ny * off3);
              ctx.moveTo(x1 - nx * off3, y1 - ny * off3);
              ctx.lineTo(x2 - nx * off3, y2 - ny * off3);
              ctx.stroke();
            }
          }

          function drawWedge(x1, y1, x2, y2) {
            var dx = x2 - x1;
            var dy = y2 - y1;
            var len = Math.sqrt(dx * dx + dy * dy) || 1;
            var nx = (-dy / len) * 5.5;
            var ny = (dx / len) * 5.5;
            ctx.fillStyle = BOND_COL;
            ctx.beginPath();
            ctx.moveTo(x1, y1);
            ctx.lineTo(x2 + nx, y2 + ny);
            ctx.lineTo(x2 - nx, y2 - ny);
            ctx.closePath();
            ctx.fill();
          }

          function drawDash(x1, y1, x2, y2) {
            var steps = 6;
            var dx = x2 - x1;
            var dy = y2 - y1;
            var len = Math.sqrt(dx * dx + dy * dy) || 1;
            var nx = -dy / len;
            var ny = dx / len;
            ctx.strokeStyle = BOND_COL;
            ctx.lineWidth = 1.8;
            for (var i = 1; i <= steps; i++) {
              var t = i / (steps + 1);
              var w = 2.0 + t * 4.0;
              var px = x1 + dx * t;
              var py = y1 + dy * t;
              ctx.beginPath();
              ctx.moveTo(px + nx * w, py + ny * w);
              ctx.lineTo(px - nx * w, py - ny * w);
              ctx.stroke();
            }
          }

          function drawAtom(x, y, sym, col, rOverride) {
            if (!full && sym === "H") return;
            if (!full && sym === "C") {
              ctx.fillStyle = C_COL;
              ctx.beginPath();
              ctx.arc(x, y, 4.0, 0, Math.PI * 2);
              ctx.fill();
              return;
            }
            var r = rOverride || (sym === "H" ? 10 : 13);
            ctx.fillStyle = "#0F172A";
            ctx.beginPath();
            ctx.arc(x, y, r + 1.5, 0, Math.PI * 2);
            ctx.fill();

            ctx.fillStyle = col;
            ctx.beginPath();
            ctx.arc(x, y, r, 0, Math.PI * 2);
            ctx.fill();

            ctx.fillStyle = "#0B1120";
            ctx.font = "bold " + (sym.length > 2 ? 9 : 11) + "px sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillText(sym, x, y + 0.5);
          }

          function drawAngleArc(x, y, rad, a1, a2, label) {
            ctx.strokeStyle = ARC_COL;
            ctx.lineWidth = 1.5;
            ctx.beginPath();
            ctx.arc(x, y, rad, a1, a2);
            ctx.stroke();

            var mid = (a1 + a2) * 0.5;
            ctx.fillStyle = ARC_COL;
            ctx.font = "bold 10px sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillText(label, x + Math.cos(mid) * (rad + 14), y + Math.sin(mid) * (rad + 12));
          }

          function drawHexagon(hcx, hcy, r, aromatic, rotOffset) {
            rotOffset = rotOffset || -Math.PI / 2;
            var pts = [];
            for (var i = 0; i < 6; i++) {
              var a = rotOffset + i * (Math.PI / 3);
              pts.push({ x: hcx + Math.cos(a) * r, y: hcy + Math.sin(a) * r });
            }
            for (var j = 0; j < 6; j++) {
              var p1 = pts[j];
              var p2 = pts[(j + 1) % 6];
              drawBond(p1.x, p1.y, p2.x, p2.y, 1);
            }
            if (aromatic) {
              ctx.strokeStyle = "#10B981";
              ctx.lineWidth = 1.8;
              ctx.setLineDash([4, 3]);
              ctx.beginPath();
              ctx.arc(hcx, hcy, r * 0.58, 0, Math.PI * 2);
              ctx.stroke();
              ctx.setLineDash([]);
            }
            for (var k = 0; k < 6; k++) {
              drawAtom(pts[k].x, pts[k].y, "C", C_COL, 11);
            }
            return pts;
          }

          // ---- Render by canvasMode ----
          if (mode === "tetravalency") {
            var pts4 = [
              { x: cx, y: cy - u * 1.15 },
              { x: cx + u * 1.15, y: cy },
              { x: cx, y: cy + u * 1.15 },
              { x: cx - u * 1.15, y: cy }
            ];
            for (var i4 = 0; i4 < 4; i4++) {
              drawBond(cx, cy, pts4[i4].x, pts4[i4].y, 1);
              drawAtom(pts4[i4].x, pts4[i4].y, "H", H_COL, 11);
            }
            drawAtom(cx, cy, "C", C_COL, 15);
          } else if (mode === "sp3_tetra" || mode === "methane") {
            var topP = { x: cx, y: cy - u * 1.2 };
            var leftP = { x: cx - u * 1.15, y: cy + u * 0.55 };
            var frontP = { x: cx + u * 0.45, y: cy + u * 1.05 };
            var backP = { x: cx + u * 1.15, y: cy - u * 0.15 };
            drawBond(cx, cy, topP.x, topP.y, 1);
            drawBond(cx, cy, leftP.x, leftP.y, 1);
            drawWedge(cx, cy, frontP.x, frontP.y);
            drawDash(cx, cy, backP.x, backP.y);
            drawAngleArc(cx, cy, u * 0.55, -Math.PI / 2, -Math.PI / 2 + 1.91, "109.5°");
            drawAtom(topP.x, topP.y, "H", H_COL);
            drawAtom(leftP.x, leftP.y, "H", H_COL);
            drawAtom(frontP.x, frontP.y, "H", H_COL);
            drawAtom(backP.x, backP.y, "H", H_COL);
            drawAtom(cx, cy, "C", C_COL, 14);
          } else if (mode === "sp2_planar") {
            var pR = { x: cx + u * 1.25, y: cy };
            var pTL = { x: cx - u * 0.85, y: cy - u * 0.95 };
            var pBL = { x: cx - u * 0.85, y: cy + u * 0.95 };
            drawBond(cx, cy, pR.x, pR.y, 2);
            drawBond(cx, cy, pTL.x, pTL.y, 1);
            drawBond(cx, cy, pBL.x, pBL.y, 1);
            drawAngleArc(cx, cy, u * 0.52, -Math.PI * 0.67, 0, "120°");
            drawAtom(pR.x, pR.y, "C", C_COL);
            drawAtom(pTL.x, pTL.y, "H", H_COL);
            drawAtom(pBL.x, pBL.y, "H", H_COL);
            drawAtom(cx, cy, "C", C_COL, 14);
          } else if (mode === "sp_linear") {
            var pL = { x: cx - u * 1.45, y: cy };
            var pR2 = { x: cx + u * 1.45, y: cy };
            drawBond(pL.x, pL.y, cx, cy, 3);
            drawBond(cx, cy, pR2.x, pR2.y, 1);
            drawAngleArc(cx, cy, u * 0.55, Math.PI, Math.PI * 2, "180°");
            drawAtom(pL.x, pL.y, "C", C_COL);
            drawAtom(pR2.x, pR2.y, "H", H_COL);
            drawAtom(cx, cy, "C", C_COL, 14);
          } else if (mode === "diamond_lattice") {
            var dPts = [
              { x: cx, y: cy - u * 0.9 },
              { x: cx - u * 0.9, y: cy },
              { x: cx + u * 0.9, y: cy },
              { x: cx - u * 0.5, y: cy + u * 0.95 },
              { x: cx + u * 0.5, y: cy + u * 0.95 }
            ];
            drawBond(cx, cy - u * 0.1, dPts[0].x, dPts[0].y, 1);
            drawBond(cx, cy - u * 0.1, dPts[1].x, dPts[1].y, 1);
            drawBond(cx, cy - u * 0.1, dPts[2].x, dPts[2].y, 1);
            drawBond(dPts[1].x, dPts[1].y, dPts[3].x, dPts[3].y, 1);
            drawBond(dPts[2].x, dPts[2].y, dPts[4].x, dPts[4].y, 1);
            drawBond(dPts[3].x, dPts[3].y, dPts[4].x, dPts[4].y, 1);
            drawAtom(cx, cy - u * 0.1, "C", C_COL, 12);
            for (var di = 0; di < dPts.length; di++) drawAtom(dPts[di].x, dPts[di].y, "C", C_COL, 11);
          } else if (mode === "graphene_hex") {
            drawHexagon(cx - u * 0.62, cy, u * 0.72, true, 0);
            drawHexagon(cx + u * 0.62, cy, u * 0.72, true, 0);
          } else if (mode === "alkane_chain") {
            var zPts = [
              { x: cx - u * 1.6, y: cy + u * 0.45 },
              { x: cx - u * 0.8, y: cy - u * 0.45 },
              { x: cx,           y: cy + u * 0.45 },
              { x: cx + u * 0.8, y: cy - u * 0.45 },
              { x: cx + u * 1.6, y: cy + u * 0.45 }
            ];
            for (var zi = 0; zi < zPts.length - 1; zi++) {
              drawBond(zPts[zi].x, zPts[zi].y, zPts[zi + 1].x, zPts[zi + 1].y, 1);
            }
            drawAngleArc(zPts[1].x, zPts[1].y, u * 0.42, 0.7, 2.4, "109.5°");
            for (var zj = 0; zj < zPts.length; zj++) drawAtom(zPts[zj].x, zPts[zj].y, "C", C_COL, 12);
          } else if (mode === "alkene_double") {
            var e1 = { x: cx - u * 0.85, y: cy };
            var e2 = { x: cx + u * 0.85, y: cy };
            var h1 = { x: e1.x - u * 0.75, y: cy - u * 0.75 };
            var h2 = { x: e1.x - u * 0.75, y: cy + u * 0.75 };
            var h3 = { x: e2.x + u * 0.75, y: cy - u * 0.75 };
            var h4 = { x: e2.x + u * 0.75, y: cy + u * 0.75 };
            drawBond(e1.x, e1.y, e2.x, e2.y, 2);
            drawBond(e1.x, e1.y, h1.x, h1.y, 1);
            drawBond(e1.x, e1.y, h2.x, h2.y, 1);
            drawBond(e2.x, e2.y, h3.x, h3.y, 1);
            drawBond(e2.x, e2.y, h4.x, h4.y, 1);
            drawAtom(h1.x, h1.y, "H", H_COL);
            drawAtom(h2.x, h2.y, "H", H_COL);
            drawAtom(h3.x, h3.y, "H", H_COL);
            drawAtom(h4.x, h4.y, "H", H_COL);
            drawAtom(e1.x, e1.y, "C", C_COL);
            drawAtom(e2.x, e2.y, "C", C_COL);
          } else if (mode === "alkyne_triple") {
            var y1 = { x: cx - u * 0.75, y: cy };
            var y2 = { x: cx + u * 0.75, y: cy };
            var yh1 = { x: y1.x - u * 1.0, y: cy };
            var yh2 = { x: y2.x + u * 1.0, y: cy };
            drawBond(y1.x, y1.y, y2.x, y2.y, 3);
            drawBond(y1.x, y1.y, yh1.x, yh1.y, 1);
            drawBond(y2.x, y2.y, yh2.x, yh2.y, 1);
            drawAtom(yh1.x, yh1.y, "H", H_COL);
            drawAtom(yh2.x, yh2.y, "H", H_COL);
            drawAtom(y1.x, y1.y, "C", C_COL);
            drawAtom(y2.x, y2.y, "C", C_COL);
          } else if (mode === "cycloalkane_ring") {
            drawHexagon(cx, cy, u * 1.08, false);
          } else if (mode === "benzene_aromatic") {
            drawHexagon(cx, cy, u * 1.08, true);
          } else if (mode === "alcohol_oh") {
            var ac1 = { x: cx - u * 1.2, y: cy + u * 0.35 };
            var ac2 = { x: cx - u * 0.25, y: cy - u * 0.35 };
            var ao  = { x: cx + u * 0.75, y: cy + u * 0.35 };
            var ah  = { x: cx + u * 1.55, y: cy - u * 0.15 };
            drawBond(ac1.x, ac1.y, ac2.x, ac2.y, 1);
            drawBond(ac2.x, ac2.y, ao.x, ao.y, 1);
            drawBond(ao.x, ao.y, ah.x, ah.y, 1);
            if (full) {
              drawBond(ac1.x, ac1.y, ac1.x - u * 0.5, ac1.y - u * 0.4, 1);
              drawBond(ac1.x, ac1.y, ac1.x - u * 0.35, ac1.y + u * 0.55, 1);
              drawBond(ac2.x, ac2.y, ac2.x, ac2.y - u * 0.55, 1);
              drawAtom(ac1.x - u * 0.5, ac1.y - u * 0.4, "H", H_COL, 9);
              drawAtom(ac1.x - u * 0.35, ac1.y + u * 0.55, "H", H_COL, 9);
              drawAtom(ac2.x, ac2.y - u * 0.55, "H", H_COL, 9);
            }
            drawAtom(ac1.x, ac1.y, "C", C_COL);
            drawAtom(ac2.x, ac2.y, "C", C_COL);
            drawAtom(ao.x, ao.y, "O", O_COL);
            drawAtom(ah.x, ah.y, "H", H_COL);
          } else if (mode === "ether_coc") {
            var ec1 = { x: cx - u * 1.1, y: cy + u * 0.35 };
            var eo  = { x: cx, y: cy - u * 0.35 };
            var ec2 = { x: cx + u * 1.1, y: cy + u * 0.35 };
            drawBond(ec1.x, ec1.y, eo.x, eo.y, 1);
            drawBond(eo.x, eo.y, ec2.x, ec2.y, 1);
            drawAtom(ec1.x, ec1.y, "C", C_COL);
            drawAtom(eo.x, eo.y, "O", O_COL);
            drawAtom(ec2.x, ec2.y, "C", C_COL);
          } else if (mode === "aldehyde_cho") {
            var alc = { x: cx, y: cy + u * 0.15 };
            var alr = { x: cx - u * 1.15, y: cy + u * 0.75 };
            var alo = { x: cx, y: cy - u * 1.05 };
            var alh = { x: cx + u * 1.15, y: cy + u * 0.75 };
            drawBond(alr.x, alr.y, alc.x, alc.y, 1);
            drawBond(alc.x, alc.y, alo.x, alo.y, 2);
            drawBond(alc.x, alc.y, alh.x, alh.y, 1);
            drawAtom(alr.x, alr.y, "C", C_COL);
            drawAtom(alo.x, alo.y, "O", O_COL);
            drawAtom(alh.x, alh.y, "H", H_COL);
            drawAtom(alc.x, alc.y, "C", C_COL);
          } else if (mode === "ketone_co") {
            var kc = { x: cx, y: cy + u * 0.15 };
            var kl = { x: cx - u * 1.15, y: cy + u * 0.75 };
            var ko = { x: cx, y: cy - u * 1.05 };
            var kr = { x: cx + u * 1.15, y: cy + u * 0.75 };
            drawBond(kl.x, kl.y, kc.x, kc.y, 1);
            drawBond(kc.x, kc.y, ko.x, ko.y, 2);
            drawBond(kc.x, kc.y, kr.x, kr.y, 1);
            drawAtom(kl.x, kl.y, "C", C_COL);
            drawAtom(ko.x, ko.y, "O", O_COL);
            drawAtom(kr.x, kr.y, "C", C_COL);
            drawAtom(kc.x, kc.y, "C", C_COL);
          } else if (mode === "carboxylic_acid") {
            var cac = { x: cx - u * 0.15, y: cy + u * 0.15 };
            var cal = { x: cx - u * 1.25, y: cy + u * 0.75 };
            var cao1 = { x: cx - u * 0.15, y: cy - u * 1.05 };
            var cao2 = { x: cx + u * 0.95, y: cy + u * 0.75 };
            var cah  = { x: cx + u * 1.65, y: cy + u * 0.25 };
            drawBond(cal.x, cal.y, cac.x, cac.y, 1);
            drawBond(cac.x, cac.y, cao1.x, cao1.y, 2);
            drawBond(cac.x, cac.y, cao2.x, cao2.y, 1);
            drawBond(cao2.x, cao2.y, cah.x, cah.y, 1);
            drawAtom(cal.x, cal.y, "C", C_COL);
            drawAtom(cao1.x, cao1.y, "O", O_COL);
            drawAtom(cao2.x, cao2.y, "O", O_COL);
            drawAtom(cah.x, cah.y, "H", H_COL);
            drawAtom(cac.x, cac.y, "C", C_COL);
          } else if (mode === "ester_coor") {
            var esc = { x: cx - u * 0.25, y: cy + u * 0.15 };
            var esl = { x: cx - u * 1.35, y: cy + u * 0.75 };
            var eso1 = { x: cx - u * 0.25, y: cy - u * 1.05 };
            var eso2 = { x: cx + u * 0.85, y: cy + u * 0.75 };
            var esr = { x: cx + u * 1.7, y: cy + u * 0.15 };
            drawBond(esl.x, esl.y, esc.x, esc.y, 1);
            drawBond(esc.x, esc.y, eso1.x, eso1.y, 2);
            drawBond(esc.x, esc.y, eso2.x, eso2.y, 1);
            drawBond(eso2.x, eso2.y, esr.x, esr.y, 1);
            drawAtom(esl.x, esl.y, "C", C_COL);
            drawAtom(eso1.x, eso1.y, "O", O_COL);
            drawAtom(eso2.x, eso2.y, "O", O_COL);
            drawAtom(esr.x, esr.y, "C", C_COL);
            drawAtom(esc.x, esc.y, "C", C_COL);
          } else if (mode === "haloalkane") {
            var hc1 = { x: cx - u * 1.0, y: cy + u * 0.35 };
            var hc2 = { x: cx, y: cy - u * 0.35 };
            var hx  = { x: cx + u * 1.05, y: cy + u * 0.35 };
            drawBond(hc1.x, hc1.y, hc2.x, hc2.y, 1);
            drawBond(hc2.x, hc2.y, hx.x, hx.y, 1);
            drawAtom(hc1.x, hc1.y, "C", C_COL);
            drawAtom(hc2.x, hc2.y, "C", C_COL);
            drawAtom(hx.x, hx.y, "Cl", X_COL);
          } else if (mode === "amine_nh2") {
            var amc = { x: cx - u * 0.85, y: cy + u * 0.3 };
            var amn = { x: cx + u * 0.3, y: cy - u * 0.2 };
            var amh1 = { x: cx + u * 1.25, y: cy - u * 0.7 };
            var amh2 = { x: cx + u * 1.25, y: cy + u * 0.55 };
            drawBond(amc.x, amc.y, amn.x, amn.y, 1);
            drawBond(amn.x, amn.y, amh1.x, amh1.y, 1);
            drawBond(amn.x, amn.y, amh2.x, amh2.y, 1);
            drawAtom(amc.x, amc.y, "C", C_COL);
            drawAtom(amh1.x, amh1.y, "H", H_COL);
            drawAtom(amh2.x, amh2.y, "H", H_COL);
            drawAtom(amn.x, amn.y, "N", N_COL);
          } else if (mode === "amide_conh2") {
            var adc = { x: cx - u * 0.15, y: cy + u * 0.15 };
            var adl = { x: cx - u * 1.25, y: cy + u * 0.75 };
            var ado = { x: cx - u * 0.15, y: cy - u * 1.05 };
            var adn = { x: cx + u * 0.95, y: cy + u * 0.75 };
            var adh = { x: cx + u * 1.75, y: cy + u * 0.2 };
            drawBond(adl.x, adl.y, adc.x, adc.y, 1);
            drawBond(adc.x, adc.y, ado.x, ado.y, 2);
            drawBond(adc.x, adc.y, adn.x, adn.y, 1);
            drawBond(adn.x, adn.y, adh.x, adh.y, 1);
            drawAtom(adl.x, adl.y, "C", C_COL);
            drawAtom(ado.x, ado.y, "O", O_COL);
            drawAtom(adh.x, adh.y, "H", H_COL);
            drawAtom(adn.x, adn.y, "N", N_COL);
            drawAtom(adc.x, adc.y, "C", C_COL);
          } else if (mode === "nitrile_cn") {
            var ntc1 = { x: cx - u * 1.35, y: cy };
            var ntc2 = { x: cx, y: cy };
            var ntn  = { x: cx + u * 1.35, y: cy };
            drawBond(ntc1.x, ntc1.y, ntc2.x, ntc2.y, 1);
            drawBond(ntc2.x, ntc2.y, ntn.x, ntn.y, 3);
            drawAtom(ntc1.x, ntc1.y, "C", C_COL);
            drawAtom(ntc2.x, ntc2.y, "C", C_COL);
            drawAtom(ntn.x, ntn.y, "N", N_COL);
          } else if (mode === "thiol_sh") {
            var tc1 = { x: cx - u * 1.1, y: cy + u * 0.35 };
            var tc2 = { x: cx - u * 0.15, y: cy - u * 0.35 };
            var ts  = { x: cx + u * 0.85, y: cy + u * 0.35 };
            var th  = { x: cx + u * 1.6, y: cy - u * 0.1 };
            drawBond(tc1.x, tc1.y, tc2.x, tc2.y, 1);
            drawBond(tc2.x, tc2.y, ts.x, ts.y, 1);
            drawBond(ts.x, ts.y, th.x, th.y, 1);
            drawAtom(tc1.x, tc1.y, "C", C_COL);
            drawAtom(tc2.x, tc2.y, "C", C_COL);
            drawAtom(ts.x, ts.y, "S", S_COL);
            drawAtom(th.x, th.y, "H", H_COL);
          } else if (mode === "organophosphate") {
            var pc = { x: cx - u * 1.5, y: cy };
            var po = { x: cx - u * 0.55, y: cy };
            var pp = { x: cx + u * 0.45, y: cy };
            var poTop = { x: cx + u * 0.45, y: cy - u * 1.0 };
            var poBot = { x: cx + u * 0.45, y: cy + u * 1.0 };
            var poR   = { x: cx + u * 1.45, y: cy };
            drawBond(pc.x, pc.y, po.x, po.y, 1);
            drawBond(po.x, po.y, pp.x, pp.y, 1);
            drawBond(pp.x, pp.y, poTop.x, poTop.y, 2);
            drawBond(pp.x, pp.y, poBot.x, poBot.y, 1);
            drawBond(pp.x, pp.y, poR.x, poR.y, 1);
            drawAtom(pc.x, pc.y, "C", C_COL);
            drawAtom(po.x, po.y, "O", O_COL);
            drawAtom(poTop.x, poTop.y, "O", O_COL);
            drawAtom(poBot.x, poBot.y, "O⁻", O_COL);
            drawAtom(poR.x, poR.y, "O⁻", O_COL);
            drawAtom(pp.x, pp.y, "P", P_COL, 14);
          } else if (mode === "isomer_chain") {
            var s1 = { x: cx - u * 1.65, y: cy - u * 0.55 };
            var s2 = { x: cx - u * 0.95, y: cy - u * 0.95 };
            var s3 = { x: cx - u * 0.25, y: cy - u * 0.55 };
            var s4 = { x: cx + u * 0.45, y: cy - u * 0.95 };
            drawBond(s1.x, s1.y, s2.x, s2.y, 1);
            drawBond(s2.x, s2.y, s3.x, s3.y, 1);
            drawBond(s3.x, s3.y, s4.x, s4.y, 1);
            drawAtom(s1.x, s1.y, "C", C_COL, 10);
            drawAtom(s2.x, s2.y, "C", C_COL, 10);
            drawAtom(s3.x, s3.y, "C", C_COL, 10);
            drawAtom(s4.x, s4.y, "C", C_COL, 10);

            var bc = { x: cx + u * 0.55, y: cy + u * 0.65 };
            var b1 = { x: bc.x - u * 0.75, y: bc.y + u * 0.4 };
            var b2 = { x: bc.x + u * 0.75, y: bc.y + u * 0.4 };
            var b3 = { x: bc.x, y: bc.y - u * 0.65 };
            drawBond(bc.x, bc.y, b1.x, b1.y, 1);
            drawBond(bc.x, bc.y, b2.x, b2.y, 1);
            drawBond(bc.x, bc.y, b3.x, b3.y, 1);
            drawAtom(b1.x, b1.y, "C", C_COL, 10);
            drawAtom(b2.x, b2.y, "C", C_COL, 10);
            drawAtom(b3.x, b3.y, "C", C_COL, 10);
            drawAtom(bc.x, bc.y, "C", C_COL, 10);
          } else if (mode === "isomer_cistrans") {
            var c1 = { x: cx - u * 0.55, y: cy - u * 0.45 };
            var c2 = { x: cx + u * 0.55, y: cy - u * 0.45 };
            drawBond(c1.x, c1.y, c2.x, c2.y, 2);
            drawBond(c1.x, c1.y, c1.x - u * 0.6, c1.y - u * 0.55, 1);
            drawBond(c2.x, c2.y, c2.x + u * 0.6, c2.y - u * 0.55, 1);
            drawAtom(c1.x - u * 0.6, c1.y - u * 0.55, "C", C_COL, 10);
            drawAtom(c2.x + u * 0.6, c2.y - u * 0.55, "C", C_COL, 10);
            drawAtom(c1.x, c1.y, "C", C_COL, 10);
            drawAtom(c2.x, c2.y, "C", C_COL, 10);

            var t1 = { x: cx - u * 0.55, y: cy + u * 0.65 };
            var t2 = { x: cx + u * 0.55, y: cy + u * 0.65 };
            drawBond(t1.x, t1.y, t2.x, t2.y, 2);
            drawBond(t1.x, t1.y, t1.x - u * 0.6, t1.y + u * 0.55, 1);
            drawBond(t2.x, t2.y, t2.x + u * 0.6, t2.y - u * 0.55, 1);
            drawAtom(t1.x - u * 0.6, t1.y + u * 0.55, "C", C_COL, 10);
            drawAtom(t2.x + u * 0.6, t2.y - u * 0.55, "C", C_COL, 10);
            drawAtom(t1.x, t1.y, "C", C_COL, 10);
            drawAtom(t2.x, t2.y, "C", C_COL, 10);
          } else if (mode === "chiral_rs") {
            var chTop = { x: cx, y: cy - u * 1.15 };
            var chL   = { x: cx - u * 1.15, y: cy + u * 0.45 };
            var chF   = { x: cx + u * 0.4, y: cy + u * 1.05 };
            var chB   = { x: cx + u * 1.2, y: cy - u * 0.15 };
            drawBond(cx, cy, chTop.x, chTop.y, 1);
            drawBond(cx, cy, chL.x, chL.y, 1);
            drawWedge(cx, cy, chF.x, chF.y);
            drawDash(cx, cy, chB.x, chB.y);
            drawAtom(chTop.x, chTop.y, "OH", O_COL, 12);
            drawAtom(chL.x, chL.y, "C", C_COL, 12);
            drawAtom(chF.x, chF.y, "N", N_COL, 12);
            drawAtom(chB.x, chB.y, "H", H_COL, 10);
            drawAtom(cx, cy, "C*", C_COL, 14);
          } else if (mode === "resonance") {
            var rc = { x: cx, y: cy + u * 0.2 };
            var ro1 = { x: cx - u * 1.05, y: cy - u * 0.65 };
            var ro2 = { x: cx + u * 1.05, y: cy - u * 0.65 };
            var rl  = { x: cx, y: cy + u * 1.15 };
            drawBond(rc.x, rc.y, rl.x, rl.y, 1);
            drawBond(rc.x, rc.y, ro1.x, ro1.y, 2);
            drawBond(rc.x, rc.y, ro2.x, ro2.y, 1);
            ctx.strokeStyle = ARC_COL;
            ctx.lineWidth = 1.6;
            ctx.setLineDash([4, 3]);
            ctx.beginPath();
            ctx.moveTo(ro1.x, ro1.y + 15);
            ctx.quadraticCurveTo(cx, cy - u * 0.1, ro2.x, ro2.y + 15);
            ctx.stroke();
            ctx.setLineDash([]);
            drawAtom(rl.x, rl.y, "C", C_COL);
            drawAtom(ro1.x, ro1.y, "O", O_COL);
            drawAtom(ro2.x, ro2.y, "O⁻", O_COL);
            drawAtom(rc.x, rc.y, "C", C_COL);
          } else if (mode === "sn2_swap") {
            var nu = { x: cx - u * 1.5, y: cy };
            var sc = { x: cx, y: cy };
            var lg = { x: cx + u * 1.45, y: cy };
            drawDash(nu.x + 16, nu.y, sc.x - 16, sc.y);
            drawDash(sc.x + 16, sc.y, lg.x - 16, lg.y);
            drawBond(sc.x, sc.y, sc.x, sc.y - u * 0.95, 1);
            drawWedge(sc.x, sc.y, sc.x - u * 0.45, sc.y + u * 0.85);
            drawDash(sc.x, sc.y, sc.x + u * 0.45, sc.y + u * 0.85);
            drawAtom(nu.x, nu.y, "Nu⁻", N_COL, 13);
            drawAtom(lg.x, lg.y, "Cl⁻", X_COL, 13);
            drawAtom(sc.x, sc.y - u * 0.95, "H", H_COL);
            drawAtom(sc.x, sc.y, "C", C_COL, 14);
          } else if (mode === "add_elim") {
            var ae1 = { x: cx - u * 1.25, y: cy };
            var ae2 = { x: cx - u * 0.15, y: cy };
            var ae3 = { x: cx + u * 1.15, y: cy };
            drawBond(ae1.x, ae1.y, ae2.x, ae2.y, 2);
            drawBond(ae2.x, ae2.y + u * 0.75, ae3.x, ae3.y + u * 0.75, 1);
            drawAtom(ae1.x, ae1.y, "C", C_COL);
            drawAtom(ae2.x, ae2.y, "C", C_COL);
            drawAtom(ae2.x, ae2.y + u * 0.75, "C", C_COL);
            drawAtom(ae3.x, ae3.y + u * 0.75, "Br", X_COL);
            ctx.fillStyle = ARC_COL;
            ctx.font = "bold 11px sans-serif";
            ctx.textAlign = "center";
            ctx.fillText("+ HBr ⇌", cx + u * 0.9, cy - u * 0.45);
          } else if (mode === "glucose_ring") {
            var gPts = [];
            for (var gi = 0; gi < 6; gi++) {
              var ga = -Math.PI / 2 + gi * (Math.PI / 3);
              gPts.push({ x: cx + Math.cos(ga) * u * 1.0, y: cy + Math.sin(ga) * u * 1.0 });
            }
            for (var gj = 0; gj < 6; gj++) {
              drawBond(gPts[gj].x, gPts[gj].y, gPts[(gj + 1) % 6].x, gPts[(gj + 1) % 6].y, 1);
            }
            drawBond(gPts[3].x, gPts[3].y, gPts[3].x + u * 0.55, gPts[3].y, 1);
            drawAtom(gPts[3].x + u * 0.55, gPts[3].y, "OH", O_COL, 10);
            for (var gk = 0; gk < 6; gk++) {
              if (gk === 1) drawAtom(gPts[gk].x, gPts[gk].y, "O", O_COL, 11);
              else drawAtom(gPts[gk].x, gPts[gk].y, "C", C_COL, 11);
            }
          } else if (mode === "lipid_triglyceride") {
            var gx = cx - u * 1.25;
            for (var li = -1; li <= 1; li++) {
              var gy = cy + li * u * 0.65;
              var ox = gx + u * 0.75;
              var cx2 = ox + u * 0.75;
              var cx3 = cx2 + u * 0.75;
              var cx4 = cx3 + u * 0.75;
              drawBond(gx, gy, ox, gy, 1);
              drawBond(ox, gy, cx2, gy, 1);
              drawBond(cx2, gy, cx3, gy - u * 0.2, 1);
              drawBond(cx3, gy - u * 0.2, cx4, gy, 1);
              drawAtom(gx, gy, "C", C_COL, 10);
              drawAtom(ox, gy, "O", O_COL, 10);
              drawAtom(cx2, gy, "C", C_COL, 9);
              drawAtom(cx3, gy - u * 0.2, "C", C_COL, 9);
              drawAtom(cx4, gy, "C", C_COL, 9);
            }
            drawBond(gx, cy - u * 0.65, gx, cy + u * 0.65, 1);
          } else if (mode === "amino_acid") {
            var aac = { x: cx, y: cy + u * 0.1 };
            var aan = { x: cx - u * 1.25, y: cy + u * 0.1 };
            var aac2 = { x: cx + u * 1.15, y: cy + u * 0.1 };
            var aao1 = { x: aac2.x + u * 0.45, y: cy - u * 0.85 };
            var aao2 = { x: aac2.x + u * 0.45, y: cy + u * 0.95 };
            var aar  = { x: cx, y: cy - u * 1.05 };
            drawBond(aan.x, aan.y, aac.x, aac.y, 1);
            drawBond(aac.x, aac.y, aac2.x, aac2.y, 1);
            drawBond(aac.x, aac.y, aar.x, aar.y, 1);
            drawBond(aac2.x, aac2.y, aao1.x, aao1.y, 2);
            drawBond(aac2.x, aac2.y, aao2.x, aao2.y, 1);
            drawAtom(aan.x, aan.y, "NH₃⁺", N_COL, 13);
            drawAtom(aar.x, aar.y, "CH₃", C_COL, 12);
            drawAtom(aao1.x, aao1.y, "O", O_COL, 11);
            drawAtom(aao2.x, aao2.y, "O⁻", O_COL, 11);
            drawAtom(aac2.x, aac2.y, "C", C_COL, 11);
            drawAtom(aac.x, aac.y, "Cα", C_COL, 13);
          } else if (mode === "nucleotide") {
            var np = { x: cx - u * 1.5, y: cy };
            var ns = { x: cx, y: cy };
            var nb = { x: cx + u * 1.45, y: cy };
            drawBond(np.x, np.y, ns.x - u * 0.45, ns.y, 1);
            drawBond(ns.x + u * 0.45, ns.y, nb.x, nb.y, 1);
            drawAtom(np.x, np.y, "PO₄", P_COL, 14);
            drawAtom(ns.x, ns.y, "Ribose", C_COL, 18);
            drawAtom(nb.x, nb.y, "A/T/G/C", N_COL, 16);
          } else if (mode === "polymer_chain") {
            var pPts = [
              { x: cx - u * 1.5, y: cy + u * 0.3 },
              { x: cx - u * 0.75, y: cy - u * 0.3 },
              { x: cx, y: cy + u * 0.3 },
              { x: cx + u * 0.75, y: cy - u * 0.3 },
              { x: cx + u * 1.5, y: cy + u * 0.3 }
            ];
            for (var pi = 0; pi < pPts.length - 1; pi++) {
              drawBond(pPts[pi].x, pPts[pi].y, pPts[pi + 1].x, pPts[pi + 1].y, 1);
            }
            for (var pj = 0; pj < pPts.length; pj++) drawAtom(pPts[pj].x, pPts[pj].y, "C", C_COL, 11);
            ctx.strokeStyle = ARC_COL;
            ctx.lineWidth = 2.0;
            ctx.beginPath();
            ctx.moveTo(cx - u * 1.1, cy - u * 0.9);
            ctx.lineTo(cx - u * 1.25, cy - u * 0.9);
            ctx.lineTo(cx - u * 1.25, cy + u * 0.9);
            ctx.lineTo(cx - u * 1.1, cy + u * 0.9);
            ctx.moveTo(cx + u * 1.1, cy - u * 0.9);
            ctx.lineTo(cx + u * 1.25, cy - u * 0.9);
            ctx.lineTo(cx + u * 1.25, cy + u * 0.9);
            ctx.lineTo(cx + u * 1.1, cy + u * 0.9);
            ctx.stroke();
            ctx.fillStyle = ARC_COL;
            ctx.font = "bold 11px sans-serif";
            ctx.fillText("n", cx + u * 1.42, cy + u * 0.85);
          } else if (mode === "medicinal_scaffold") {
            var mPts = drawHexagon(cx, cy, u * 0.8, true);
            var mTop = { x: mPts[0].x, y: mPts[0].y - u * 0.55 };
            var mBot = { x: mPts[3].x, y: mPts[3].y + u * 0.55 };
            drawBond(mPts[0].x, mPts[0].y, mTop.x, mTop.y, 1);
            drawBond(mPts[3].x, mPts[3].y, mBot.x, mBot.y, 1);
            drawAtom(mTop.x, mTop.y, "OH", O_COL, 11);
            drawAtom(mBot.x, mBot.y, "NHAc", N_COL, 12);
          }
        }
      }

      // ---- Zone 3: Bottom Legend Strip (height: 44)
      Item {
        width: parent.width
        height: 44

        Rectangle {
          anchors.top: parent.top
          width: parent.width
          height: 1
          color: "#1E293B"
        }

        Flow {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          anchors.topMargin: 5
          spacing: 8

          Repeater {
            model: [
              { label: "Carbon (C)", col: "#10B981" },
              { label: "Oxygen (O)", col: "#EF4444" },
              { label: "Nitrogen (N)", col: "#3B82F6" },
              { label: "Hydrogen (H)", col: "#94A3B8" },
              { label: "Halogen/Sulfur / P", col: "#22D3EE" }
            ]
            delegate: Row {
              spacing: 4
              Rectangle {
                width: 8
                height: 8
                radius: width / 2
                anchors.verticalCenter: parent.verticalCenter
                color: modelData.col
              }
              Text {
                textFormat: Text.PlainText
                text: modelData.label
                color: Qt.rgba(root.panelForeground.r, root.panelForeground.g, root.panelForeground.b, 0.85)
                font.family: Style.font.family
                font.pixelSize: 11
              }
            }
          }
        }
      }
    }
  }
}

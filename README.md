# Carbon Matrix (`io.github.advocu.carbon-matrix`)

An interactive **6x6 Periodic-Table-style visual guide to Carbon and Organic Chemistry** designed for ultra-beginners on **Omarchy Quattro**.

Click the `⬡ Carbon` button in the Omarchy bar to explore 36 color-coded carbon forms, functional groups, 3D stereochemistry rules, and biomolecules—each paired with a live 2D QML molecular bond canvas, plain-English explanations, everyday household examples, and reactivity cues.

## Features

- **6x6 Color-Coded Matrix (36 Carbon Forms):** Organized into 6 rows across *Core & Allotropes*, *Hydrocarbons*, *Oxygen Groups*, *N / S / Halogens*, *Isomers & 3D*, and *Life & Polymers*.
- **Live 2D Molecular Bond Canvas:** Procedurally renders color-coded atoms (`C`, `O`, `N`, `H`, `S`, `X`, `P`), double/triple bonds, wedged/dashed 3D stereo bonds, aromatic rings, and bond angle arcs (`109.5°`, `120°`, `180°`).
- **Noob vs. Pro View Toggle:** Switch instantly between `"View: Full Atoms (Noob)"` and `"View: Skeletal Lines (Pro)"`.
- **Live Search & Category Filters:** Filter by name, symbol, IUPAC suffix, or everyday item.
- **Plain-English Beginner Cards:** Every tile explains *What Is It?*, *How To Spot It In A Formula*, and *Where You Touch Or Eat It Daily*.

## Installation

```bash
omarchy plugin add https://github.com/advocu/omarchy-carbon-matrix.git --enable
```

## Usage

- Click **`⬡ Carbon`** in the right section of the Omarchy bar, or summon the panel via IPC:
  ```bash
  omarchy-shell shell summon io.github.advocu.carbon-matrix '{}'
  ```
- Click any of the 36 tiles in the 6x6 grid to inspect its 2D bond canvas and beginner card.
- Use the **`View: Full Atoms (Noob)` / `View: Skeletal Lines (Pro)`** pill to toggle skeletal shorthand.
- Press **`Escape`** to close the panel.

## Configuration

Move the widget to any bar section (default is `right`):

```bash
omarchy bar move io.github.advocu.carbon-matrix --section right
```

## Removal

```bash
omarchy plugin remove io.github.advocu.carbon-matrix
```

## Dependencies & License

- **Dependencies:** Built-in Omarchy Quattro / Quickshell runtime only (zero external packages required).
- **License:** [MIT](LICENSE) — Copyright (c) 2026 Suyash Verma.

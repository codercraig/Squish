# StatSquish Addon

**StatSquish** is a World of Warcraft addon designed to modify and visually scale down various in-game stats, combat damage, and healing values to more manageable levels. This addon also adjusts tooltips to provide a cleaner and more classic-like experience.

## Features

- **Damage Scaling**  
  Combat damage is divided by 1000, with large damage values displayed in red and critical hits highlighted in yellow.

- **Healing Scaling**  
  Healing amounts are scaled down and displayed in green, with critical heals being emphasized.

- **Tooltip Stat Squishing**  
  Item stats in tooltips are scaled down by dividing them by 100, making them more readable and manageable.

- **Customizable Combat Text**  
  Damage and healing values are displayed with customizable positioning and animations, including shaking for large numbers.

- **Clean Tooltips**  
  Specific lines in tooltips such as cooldowns, durability, and mythic/seasonal information are ignored, ensuring only relevant stats are adjusted.

## Installation

1. Download the `StatSquish` addon files.
2. Extract the contents to your `World of Warcraft/_retail_/Interface/Addons` directory.
3. Ensure the folder is named `StatSquish`.
4. Launch World of Warcraft and enable the `StatSquish` addon in the Addons menu.

## Usage

The addon works automatically once installed and enabled. It will:

- Adjust combat text during fights.
- Scale down stats in tooltips for items and units.
- Display critical hits in yellow and healing in green.

### Configuration

Currently, there are no in-game configuration options for `StatSquish`. If you wish to adjust the scaling factors or modify other behavior, you can do so by editing the `StatSquish.lua` file directly.

## Customization

### Damage and Healing Modifiers

- **Damage Modifier**: The default value is set to `0.001`, dividing damage by 1000.
- **Stat Modifier**: The default value is set to `0.01`, dividing stats in tooltips by 100.

You can adjust these values by editing the corresponding variables in the `StatSquish.lua` file:

```lua
local damageModifier = 0.001  -- This will divide the damage by 1000
local statModifier = 0.01     -- This will divide the stats in tooltips by 100

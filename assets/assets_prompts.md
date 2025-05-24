# Asset Generation Prompts

This file contains Stable Diffusion prompts for generating all game assets. Use these prompts with the Flux model on mage.space to generate consistent pixel art assets.

## Base Prompt
All prompts should start with this base for consistency:
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000
```

## Character Sprites

### Player Character
1. **player_idle.png** (64x64, 4 frames)
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 A friendly video game character in a neutral pose, facing forward, wearing a blue cap and green suite, simple pixel art style, 4 frame idle animation, side view, white background
```

2. **player_run.png** (64x128, 6 frames)
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Video game character running animation, 6 frames, side view, blue cap and green suite, arms and legs in motion, simple pixel art, white background
```

3. **player_jump.png** (64x64)
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Video game character in mid-air jump pose, arms raised, legs bent, blue cap and green suite, pixel art, side view, white background
```

### Enemies
1. **slime_idle.png** (48x32, 4 frames)
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Cute green slime enemy, 4 frame idle animation, bouncing slightly, pixel art, simple shapes, translucent, side view, white background
```

2. **bat_fly.png** (32x32, 4 frames)
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Small purple bat enemy, 4 frame flying animation, wings flapping, pixel art, simple design, side view, white background
```

## Tilesets

### Forest Tileset (tiles.png, 512x512)
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Top-down view of a forest tileset, 16x16 pixel tiles including: grass, dirt path, stone, water, tree trunks, bushes, and flowers, pixel art, vibrant colors, game ready
```

### Cave Tileset (tiles.png, 512x512)
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Top-down view of a cave tileset, 16x16 pixel tiles including: stone floor, walls, stalactites, crystals, and dark corners, pixel art, blue-gray color palette, game ready
```

## UI Elements

### Buttons
1. **play_button.png** (200x80)
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Green rectangular game button with "PLAY" text, pixel art, beveled edges, slight glow, game UI element, isometric perspective
```

2. **settings_button.png** (40x40)
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Small square gear icon, pixel art, white on dark gray, simple and clean, game UI element
```

### Icons (all 16x16)
1. **heart.png**
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Simple red heart icon, pixel art, 16x16 pixels, game UI element, clean lines
```

2. **coin.png**
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Gold coin icon, pixel art, 16x16 pixels, round shape with simple shine, game currency
```

3. **star.png**
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Yellow five-pointed star, pixel art, 16x16 pixels, game collectible icon, clean lines
```

4. **pause.png**
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Simple pause icon, two vertical rectangles, pixel art, 16x16 pixels, white on transparent, game UI
```

5. **sound_on.png**
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Sound on icon, speaker with sound waves, pixel art, 16x16 pixels, white on transparent, game UI
```

6. **sound_off.png**
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Muted sound icon, speaker with X, pixel art, 16x16 pixels, white on transparent, game UI
```

## Effects

### Particles
1. **sparkle.png** (16x16)
```
Pixel art, 2D game asset, clean lines, vibrant colors, 16-bit style, no anti-aliasing, sharp edges, game ready, isometric perspective, --ar 1:1 --v 6.0 --q 2 --style 4b --stylize 1000 Simple white sparkle effect, pixel art, 16x16 pixels, transparent background, game VFX
```

## Generation Notes
1. Use the Flux model on mage.space
2. Set the resolution according to each asset's specified size
3. Use the exact aspect ratio (--ar) specified for each asset
4. Generate with transparent background where applicable
5. Save files with the exact names specified to maintain compatibility with the game
6. For multi-frame animations, generate each frame separately and combine them into a sprite sheet

## Style Guide
- Color Palette: Bright, vibrant colors
- Pixel Art Style: Clean, 16-bit aesthetic
- Perspective: Side view for characters, top-down for tiles
- Background: Transparent for sprites, solid colors for UI elements
- Consistency: Maintain consistent lighting and shading across all assets

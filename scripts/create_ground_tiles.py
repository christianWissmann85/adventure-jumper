#!/usr/bin/env python3
"""
Script to create placeholder ground tile sprites for Adventure Jumper.
"""

from PIL import Image, ImageDraw, ImageFilter
import os
import random
import math

def create_ground_tiles():
    """Create placeholder ground tile sprites for different terrain types."""
    # Create output directory if it doesn't exist
    output_dir = r'c:\Users\User\source\repos\Cascade\adventure-jumper\assets\images\tilesets'
    base_dir = output_dir
    os.makedirs(output_dir, exist_ok=True)
    
    # Create different tile types
    tiles_to_create = [
        # Basic tiles
        ('dirt_tile.png', (139, 69, 19), 'dirt'),       # Brown
        ('ground_tile.png', (160, 82, 45), 'ground'),   # Sienna 
        ('grass_tile.png', (34, 139, 34), 'grass'),     # Forest Green
        ('stone_tile.png', (105, 105, 105), 'stone'),   # Dim Gray
        
        # Special tiles
        ('ice_tile.png', (135, 206, 250), 'ice'),       # Light Sky Blue
        ('lava_tile.png', (255, 69, 0), 'lava'),        # Red-Orange
        ('crystal_tile.png', (147, 112, 219), 'crystal') # Medium Purple
    ]
    
    # Create tileset folder if it doesn't exist
    os.makedirs(os.path.join(base_dir), exist_ok=True)
    
    # Create each tile
    for filename, base_color, tile_type in tiles_to_create:
        create_tile(os.path.join(base_dir, filename), base_color, tile_type)
        print(f"Created {filename}")
    
    print("All ground tiles created successfully!")

def create_tile(output_path, base_color, tile_type, size=(16, 16)):
    """Create a ground tile with the specified parameters."""
    width, height = size
    
    # Create base image with the base color
    image = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Fill background
    draw.rectangle([0, 0, width-1, height-1], fill=base_color)
    
    # Add texture based on tile type
    if tile_type == 'dirt':
        add_dirt_texture(draw, width, height, base_color)
    elif tile_type == 'ground':
        add_ground_texture(draw, width, height, base_color)
    elif tile_type == 'grass':
        add_grass_texture(draw, width, height, base_color)
    elif tile_type == 'stone':
        add_stone_texture(draw, width, height, base_color)
    elif tile_type == 'ice':
        add_ice_texture(draw, width, height, base_color)
    elif tile_type == 'lava':
        add_lava_texture(draw, width, height, base_color)
    elif tile_type == 'crystal':
        add_crystal_texture(draw, width, height, base_color)
    
    # Add a subtle border to make tiling more obvious
    draw.rectangle([0, 0, width-1, height-1], outline=(0, 0, 0, 80), width=1)
    
    # Save the tile
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    image.save(output_path)
    return output_path

def add_dirt_texture(draw, width, height, base_color):
    """Add a dirt-like texture with small dots and variations."""
    # Add small dots for texture
    r, g, b = base_color
    for _ in range(20):
        x = random.randint(0, width-1)
        y = random.randint(0, height-1)
        size = random.randint(1, 2)
        # Vary the color slightly
        color_var = random.randint(-20, 20)
        color = (
            max(0, min(255, r + color_var)),
            max(0, min(255, g + color_var)),
            max(0, min(255, b + color_var)),
            255
        )
        draw.rectangle([x, y, x+size, y+size], fill=color)

def add_ground_texture(draw, width, height, base_color):
    """Add a ground-like texture with lines and variations."""
    # Add horizontal streaks for texture
    r, g, b = base_color
    for _ in range(5):
        y = random.randint(0, height-1)
        color_var = random.randint(-15, 15)
        color = (
            max(0, min(255, r + color_var)),
            max(0, min(255, g + color_var)),
            max(0, min(255, b + color_var)),
            255
        )
        draw.line([(0, y), (width-1, y)], fill=color, width=1)

def add_grass_texture(draw, width, height, base_color):
    """Add a grass-like texture with small lines at the top."""
    # Add grass blades
    r, g, b = base_color
    # Make the top part slightly lighter
    top_color = (
        min(255, r + 20),
        min(255, g + 30),
        min(255, b + 20),
        255
    )
    # Draw the top part
    draw.rectangle([0, 0, width-1, 3], fill=top_color)
    
    # Add small vertical lines for grass blades
    for _ in range(7):
        x = random.randint(1, width-2)
        height_var = random.randint(1, 3)
        color_var = random.randint(-10, 20)
        color = (
            max(0, min(255, r + color_var)),
            max(0, min(255, g + color_var + 10)),
            max(0, min(255, b + color_var)),
            255
        )
        draw.line([(x, 0), (x, height_var)], fill=color, width=1)

def add_stone_texture(draw, width, height, base_color):
    """Add a stone-like texture with cracks and variations."""
    # Add cracks and variations
    r, g, b = base_color
    # Add some subtle cracks
    for _ in range(3):
        x1 = random.randint(1, width-2)
        y1 = random.randint(1, height-2)
        x2 = x1 + random.randint(-3, 3)
        y2 = y1 + random.randint(-3, 3)
        x2 = max(0, min(width-1, x2))
        y2 = max(0, min(height-1, y2))
        
        color = (
            max(0, min(255, r - 20)),
            max(0, min(255, g - 20)),
            max(0, min(255, b - 20)),
            255
        )
        draw.line([(x1, y1), (x2, y2)], fill=color, width=1)

def add_ice_texture(draw, width, height, base_color):
    """Add an ice-like texture with shine and highlights."""
    # Add shine effect
    r, g, b = base_color
    # Add a shine line
    x1 = random.randint(2, width-3)
    y1 = random.randint(2, height-3)
    x2 = x1 + random.randint(2, 5)
    y2 = y1 + random.randint(2, 5)
    x2 = max(0, min(width-1, x2))
    y2 = max(0, min(height-1, y2))
    
    shine_color = (
        min(255, r + 50),
        min(255, g + 50),
        min(255, b + 50),
        180
    )
    draw.line([(x1, y1), (x2, y2)], fill=shine_color, width=1)

def add_lava_texture(draw, width, height, base_color):
    """Add a lava-like texture with bubbles and brightness variations."""
    # Add bubbles and hot spots
    r, g, b = base_color
    for _ in range(4):
        x = random.randint(1, width-2)
        y = random.randint(1, height-2)
        size = random.randint(1, 2)
        
        # Make some bright spots
        bright_color = (
            min(255, r + 30),
            min(255, g + 20),
            min(255, b - 10),
            255
        )
        draw.ellipse([x, y, x+size, y+size], fill=bright_color)

def add_crystal_texture(draw, width, height, base_color):
    """Add a crystal-like texture with facets and shine."""
    # Add facet lines
    r, g, b = base_color
    # Create diagonal facet lines
    for i in range(0, width, 4):
        color_var = random.randint(-15, 15)
        color = (
            max(0, min(255, r + color_var)),
            max(0, min(255, g + color_var)),
            max(0, min(255, b + color_var + 15)),  # Slight blue tint to facets
            255
        )
        draw.line([(i, 0), (0, i)], fill=color, width=1)
    
    # Add shine spot
    shine_x = random.randint(width//4, 3*width//4)
    shine_y = random.randint(height//4, 3*height//4)
    shine_size = random.randint(1, 2)
    shine_color = (255, 255, 255, 180)
    draw.ellipse([shine_x, shine_y, shine_x+shine_size, shine_y+shine_size], 
                fill=shine_color)

if __name__ == "__main__":
    create_ground_tiles()

#!/usr/bin/env python3
"""
Script to create placeholder player sprites for the Adventure Jumper game.
"""

from PIL import Image, ImageDraw
import os

def create_player_sprites():
    # Create the player assets directory if it doesn't exist
    assets_dir = r'c:\Users\User\source\repos\Cascade\adventure-jumper\assets\images\characters\player'
    os.makedirs(assets_dir, exist_ok=True)

    # Define sprite configurations (name, color, size)
    sprites_to_create = [
        ('player_fall.png', (255, 200, 100), 32, 64),      # Orange for falling
        ('player_landing.png', (100, 255, 100), 32, 64),   # Green for landing
        ('player_attack.png', (255, 100, 100), 32, 64),    # Red for attack
        ('player_damaged.png', (255, 50, 50), 32, 64),     # Dark red for damaged
        ('player_death.png', (100, 100, 100), 32, 64),     # Gray for death
    ]

    for sprite_name, color, width, height in sprites_to_create:
        # Create a new image with RGBA mode for transparency
        img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # Draw a simple character shape (rectangle with head)
        # Body
        draw.rectangle([8, 16, 24, 56], fill=color + (255,))
        # Head
        draw.ellipse([6, 4, 26, 20], fill=color + (255,))
        
        # Add simple details based on sprite type
        if 'attack' in sprite_name:
            # Add an 'arm' extending forward
            draw.rectangle([24, 20, 30, 24], fill=color + (255,))
        elif 'fall' in sprite_name:
            # Add motion lines
            draw.line([2, 10, 6, 14], fill=(255, 255, 255, 128), width=2)
            draw.line([2, 20, 6, 24], fill=(255, 255, 255, 128), width=2)
        elif 'landing' in sprite_name:
            # Add impact lines at bottom
            draw.line([4, 58, 12, 62], fill=(255, 255, 255, 128), width=2)
            draw.line([20, 58, 28, 62], fill=(255, 255, 255, 128), width=2)
        elif 'damaged' in sprite_name:
            # Add 'X' marks to show damage
            draw.line([2, 2, 8, 8], fill=(255, 255, 255, 200), width=2)
            draw.line([2, 8, 8, 2], fill=(255, 255, 255, 200), width=2)
        elif 'death' in sprite_name:
            # Make it lying down (wider, shorter)
            img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
            draw = ImageDraw.Draw(img)
            draw.rectangle([4, 48, 28, 60], fill=color + (255,))  # Body lying down
            draw.ellipse([2, 44, 14, 52], fill=color + (255,))    # Head
        
        # Save the sprite
        sprite_path = os.path.join(assets_dir, sprite_name)
        img.save(sprite_path)
        print(f'Created {sprite_name} at {sprite_path}')

    print('All missing player sprites created successfully!')

if __name__ == '__main__':
    create_player_sprites()

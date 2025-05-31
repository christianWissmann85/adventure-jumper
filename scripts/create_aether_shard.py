#!/usr/bin/env python3
"""
Script to create an Aether Shard collectible sprite for Adventure Jumper game.
This creates a more visually appealing crystal-like shard with glow effects.
"""

from PIL import Image, ImageDraw, ImageFilter, ImageChops, ImageEnhance
import os
import math
import colorsys
import random

def create_aether_shard(output_size=(16, 16), animation_frames=6, animated=True):
    """
    Creates an Aether Shard sprite with subtle pulsing animation.
    
    Args:
        output_size: Tuple of (width, height) for the output sprite
        animation_frames: Number of animation frames if animated
        animated: Whether to create an animated sprite or a single frame
    
    Returns:
        Path to the created sprite file
    """
    # Create output directory if it doesn't exist
    output_dir = r'c:\Users\User\source\repos\Cascade\adventure-jumper\assets\images\props\collectibles'
    os.makedirs(output_dir, exist_ok=True)
    
    # Define the base color and glow color for the Aether Shard (magical purple)
    base_color = (200, 100, 255)  # Base purple
    glow_color = (255, 200, 255)  # Light purple glow
    
    if animated:
        # For animated version, create a spritesheet
        width, height = output_size
        spritesheet = Image.new('RGBA', (width * animation_frames, height), (0, 0, 0, 0))
        
        for i in range(animation_frames):
            # Pulse effect: calculate intensity based on frame
            pulse = 0.5 + 0.5 * math.sin(i * 2 * math.pi / animation_frames)
            
            # Adjust colors based on pulse
            adjusted_base = tuple(int(c * (0.8 + 0.2 * pulse)) for c in base_color)
            adjusted_glow = tuple(int(c * pulse) for c in glow_color)
            
            # Create the frame
            frame = create_shard_frame(output_size, adjusted_base, adjusted_glow, pulse)
            
            # Add to spritesheet
            spritesheet.paste(frame, (i * width, 0), frame)
        
        output_path = os.path.join(output_dir, 'collectible_aether_shard.png')
        spritesheet.save(output_path)
    else:
        # For static version, create a single image
        shard = create_shard_frame(output_size, base_color, glow_color, 1.0)
        output_path = os.path.join(output_dir, 'collectible_aether_shard.png')
        shard.save(output_path)
    
    print(f"Created Aether Shard sprite at: {output_path}")
    return output_path

def create_shard_frame(size, base_color, glow_color, intensity=1.0):
    """Creates a single frame of the Aether Shard with the specified intensity."""
    width, height = size
    
    # Create base transparent image
    image = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Calculate center and dimensions
    center_x, center_y = width // 2, height // 2
    shard_width = int(width * 0.6)
    shard_height = int(height * 0.8)
    
    # Create crystal shard shape
    # The shard is a hexagonal crystal with some randomization for a more natural look
    crystal_color = base_color + (255,)  # Add full alpha
    
    # Generate crystal points
    num_points = 6
    points = []
    
    # Top point
    points.append((center_x, center_y - shard_height // 2))
    
    # Side points with slight randomization
    for i in range(num_points - 1):
        angle = math.pi * 2 * i / (num_points - 1) + math.pi / 2
        distance = shard_width // 2
        if i % 2 == 0:
            distance *= 0.7  # Make alternating points closer for gem-like look
        
        x = center_x + int(math.cos(angle) * distance)
        y = center_y + int(math.sin(angle) * distance)
        
        # Add some random variation
        x += random.randint(-1, 1)
        y += random.randint(-1, 1)
        
        points.append((x, y))
    
    # Draw the crystal
    draw.polygon(points, fill=crystal_color)
    
    # Add facet lines for crystal effect
    for i in range(0, len(points), 2):
        draw.line([points[0], points[i]], fill=(255, 255, 255, 100), width=1)
    
    # Add a highlight
    highlight_points = [
        (center_x - shard_width//4, center_y - shard_height//4),
        (center_x + shard_width//6, center_y - shard_height//3),
        (center_x, center_y)
    ]
    draw.polygon(highlight_points, fill=(255, 255, 255, 80))
    
    # Create glow effect
    glow = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    
    # Draw a slightly larger crystal shape for the glow
    glow_points = []
    for x, y in points:
        # Expand points outward from center for glow
        dx, dy = x - center_x, y - center_y
        expansion = 1.2 + 0.2 * intensity
        gx = center_x + int(dx * expansion)
        gy = center_y + int(dy * expansion)
        glow_points.append((gx, gy))
    
    glow_draw.polygon(glow_points, fill=glow_color + (100,))
    
    # Apply blur for soft glow
    glow = glow.filter(ImageFilter.GaussianBlur(radius=2))
    
    # Adjust glow intensity
    if intensity != 1.0:
        enhancer = ImageEnhance.Brightness(glow)
        glow = enhancer.enhance(intensity)
    
    # Composite layers: glow behind crystal
    result = Image.alpha_composite(glow, image)
    
    # Add a small sparkle at the top for extra shininess
    if random.random() < 0.7 or intensity > 0.8:
        sparkle = Image.new('RGBA', (width, height), (0, 0, 0, 0))
        sparkle_draw = ImageDraw.Draw(sparkle)
        
        # Small star/diamond shape
        sparkle_x, sparkle_y = center_x - 2 + random.randint(0, 4), center_y - shard_height // 3
        sparkle_size = 2 + int(intensity * 2)
        
        sparkle_draw.line(
            [(sparkle_x - sparkle_size, sparkle_y), 
             (sparkle_x + sparkle_size, sparkle_y)], 
            fill=(255, 255, 255, 200), width=1
        )
        sparkle_draw.line(
            [(sparkle_x, sparkle_y - sparkle_size), 
             (sparkle_x, sparkle_y + sparkle_size)], 
            fill=(255, 255, 255, 200), width=1
        )
        
        # Blur the sparkle
        sparkle = sparkle.filter(ImageFilter.GaussianBlur(0.5))
        
        # Composite the sparkle
        result = Image.alpha_composite(result, sparkle)
    
    return result

if __name__ == '__main__':
    # Create both animated and static versions
    animated_path = create_aether_shard(animation_frames=6, animated=True)
    print(f"Created animated Aether Shard sprite at: {animated_path}")
    
    # Optional: Uncomment to also create a static version
    # static_path = create_aether_shard(animated=False)
    # print(f"Created static Aether Shard sprite at: {static_path}")

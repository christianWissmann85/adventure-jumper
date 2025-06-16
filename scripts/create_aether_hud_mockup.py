#!/usr/bin/env python3
"""
Script to create a mockup HUD design for Aether display in Adventure Jumper.
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import os
import math

def create_aether_hud_mockup():
    """Creates a mockup design for the Aether HUD display."""
    # Create output directory
    output_dir = r'c:\Users\User\source\repos\Cascade\adventure-jumper\assets\images\ui\hud'
    os.makedirs(output_dir, exist_ok=True)
    
    # Define dimensions based on game UI specifications
    mockup_width = 320  # Full game width for context
    mockup_height = 180  # Full game height for context
    
    # Create the mockup image (transparent background)
    mockup = Image.new('RGBA', (mockup_width, mockup_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(mockup)
    
    # Draw a semi-transparent game background to provide context
    # This represents a typical game scene so we can see how the HUD looks in-game
    bg_color = (60, 80, 120, 100)  # Semi-transparent bluish color
    draw.rectangle([(0, 0), (mockup_width, mockup_height)], fill=bg_color)
    
    # Add some background elements to simulate a game scene
    # Draw a platform
    platform_color = (120, 140, 200, 180)
    draw.rectangle([(50, 140), (270, 160)], fill=platform_color)
    
    # Draw a simple player character
    player_color = (200, 180, 100, 255)
    draw.rectangle([(150, 100), (170, 140)], fill=player_color)
    draw.ellipse([(145, 80), (175, 110)], fill=player_color)
    
    # Now create the actual HUD elements
    
    # 1. Aether Counter Frame
    counter_width = 80
    counter_height = 24
    counter_x = mockup_width - counter_width - 10  # Position in top right with padding
    counter_y = 10
    
    # Create counter frame with crystal-like appearance
    frame_color = (150, 100, 220, 230)  # Purple for Aether theme
    frame_border = (100, 50, 180, 255)  # Darker border
    
    # Draw main frame
    draw.rectangle([(counter_x, counter_y), (counter_x + counter_width, counter_y + counter_height)], 
                  fill=frame_color, outline=frame_border, width=2)
    
    # Add crystal-like accents to frame corners
    accent_size = 4
    for corner in [(counter_x, counter_y), (counter_x + counter_width, counter_y), 
                   (counter_x, counter_y + counter_height), (counter_x + counter_width, counter_y + counter_height)]:
        draw.polygon([
            (corner[0], corner[1]),
            (corner[0] + accent_size, corner[1]),
            (corner[0], corner[1] + accent_size)
        ], fill=(200, 150, 255, 255))
    
    # 2. Aether Icon
    icon_size = 16
    icon_x = counter_x + 4
    icon_y = counter_y + 4
    
    # Create mini shard icon
    icon_color = (230, 150, 255, 255)
    
    # Crystal polygon points for icon
    icon_points = [
        (icon_x + icon_size//2, icon_y),  # Top
        (icon_x + icon_size, icon_y + icon_size//2),  # Right
        (icon_x + icon_size//2, icon_y + icon_size),  # Bottom
        (icon_x, icon_y + icon_size//2),  # Left
    ]
    
    # Draw shard icon
    draw.polygon(icon_points, fill=icon_color)
    
    # Add highlight
    highlight_points = [
        icon_points[0],
        (icon_x + icon_size//2, icon_y + icon_size//3),
        icon_points[3]
    ]
    draw.polygon(highlight_points, fill=(255, 200, 255, 150))
    
    # 3. Aether Counter Text
    value_x = icon_x + icon_size + 8
    value_y = counter_y + 4
    aether_value = "50/100"
    
    # Draw counter text with shadow
    shadow_offset = 1
    draw.text((value_x + shadow_offset, value_y + shadow_offset), aether_value, fill=(50, 10, 80, 180))
    draw.text((value_x, value_y), aether_value, fill=(255, 230, 255, 255))
    
    # 4. Create a separate preview image for the Aether icon to be used as a collectible counter
    icon_img = Image.new('RGBA', (icon_size, icon_size), (0, 0, 0, 0))
    icon_draw = ImageDraw.Draw(icon_img)
    
    # Rescale points to fit the new image
    adjusted_icon_points = [
        (icon_size//2, 0),  # Top
        (icon_size, icon_size//2),  # Right
        (icon_size//2, icon_size),  # Bottom
        (0, icon_size//2),  # Left
    ]
    
    # Draw the icon
    icon_draw.polygon(adjusted_icon_points, fill=icon_color)
    
    # Add glow effect
    icon_glow = Image.new('RGBA', (icon_size, icon_size), (0, 0, 0, 0))
    icon_glow_draw = ImageDraw.Draw(icon_glow)
    
    # Draw slightly larger polygon for glow
    glow_points = []
    center_x, center_y = icon_size//2, icon_size//2
    for x, y in adjusted_icon_points:
        # Expand points outward from center for glow
        dx, dy = x - center_x, y - center_y
        expansion = 1.3
        gx = center_x + int(dx * expansion)
        gy = center_y + int(dy * expansion)
        glow_points.append((gx, gy))
    
    icon_glow_draw.polygon(glow_points, fill=(230, 150, 255, 100))
    
    # Apply blur for the glow
    icon_glow = icon_glow.filter(ImageFilter.GaussianBlur(radius=2))
    
    # Composite layers
    icon_final = Image.alpha_composite(icon_glow, icon_img)
    
    # Save separate icon
    icon_path = os.path.join(output_dir, 'ui_aether_counter_icon.png')
    icon_final.save(icon_path)
    print(f"Created Aether icon at: {icon_path}")
    
    # 5. Health Bar (to show HUD context)
    health_bar_width = 120
    health_bar_height = 16
    health_bar_x = 10
    health_bar_y = 10
    
    # Draw health bar frame
    health_frame_color = (100, 100, 200, 230)
    health_border = (50, 50, 150, 255)
    draw.rectangle(
        [(health_bar_x, health_bar_y), 
         (health_bar_x + health_bar_width, health_bar_y + health_bar_height)], 
        fill=health_frame_color, outline=health_border, width=2
    )
    
    # Draw health fill
    health_fill_color = (200, 100, 100, 255)
    fill_width = int(health_bar_width * 0.8) - 4  # 80% health
    draw.rectangle(
        [(health_bar_x + 4, health_bar_y + 4), 
         (health_bar_x + 4 + fill_width, health_bar_y + health_bar_height - 4)], 
        fill=health_fill_color
    )
    
    # Draw HP text
    hp_x = health_bar_x + 6
    hp_y = health_bar_y + 2
    draw.text((hp_x, hp_y), "HP", fill=(255, 255, 255, 255))
    
    # Save frame mockup
    frame_path = os.path.join(output_dir, 'ui_aether_counter_frame.png')
    frame_img = mockup.crop((counter_x, counter_y, counter_x + counter_width, counter_y + counter_height))
    frame_img.save(frame_path)
    print(f"Created Aether counter frame at: {frame_path}")
    
    # Save full HUD mockup
    mockup_path = os.path.join(output_dir, 'ui_aether_hud_mockup.png')
    mockup.save(mockup_path)
    print(f"Created full HUD mockup at: {mockup_path}")
    
    return mockup_path

if __name__ == '__main__':
    mockup_path = create_aether_hud_mockup()
    print(f"\nAether HUD mockup design created successfully!")
    print(f"Mockup saved at: {mockup_path}")
    print("\nDesign details:")
    print("- Aether counter positioned in top-right corner")
    print("- Crystal-themed frame with accent corners")
    print("- Distinctive Aether shard icon")
    print("- Clear counter text showing current/maximum (50/100)")
    print("- Health bar shown in top-left for context")
    print("- Design uses magical purple theme for Aether elements")

#!/usr/bin/env python3
"""
Script to create a placeholder sprite for Kael, the main character in Adventure Jumper.
"""

from PIL import Image, ImageDraw, ImageFont
import os
import random
import math

def create_kael_sprite(output_size=(32, 64), output_filename="player_idle.png"):
    """
    Creates a placeholder sprite for Kael with the correct dimensions.
    
    Args:
        output_size: Tuple of (width, height) for the sprite
        output_filename: Filename to save the sprite as
    
    Returns:
        Path to the created sprite
    """
    # Create output directory if it doesn't exist
    output_dir = r'c:\Users\User\source\repos\Cascade\adventure-jumper\assets\images\characters\player'
    os.makedirs(output_dir, exist_ok=True)
    
    # Define color scheme for Kael (blue/teal with Aether energy accents)
    # Based on the game's lore, Kael is a Jumper who can harness Aether energy
    primary_color = (50, 120, 180)  # Blue/teal body
    secondary_color = (30, 80, 120)  # Darker blue for details
    accent_color = (180, 210, 255)   # Light blue for highlights/glow
    aether_color = (180, 150, 255)   # Purple for Aether energy

    # Create base transparent image
    image = Image.new('RGBA', output_size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    width, height = output_size
    
    # Draw the character silhouette
    
    # Head (slightly smaller than typical to match pixel art style)
    head_width = width * 0.6
    head_height = height * 0.2
    head_x = (width - head_width) / 2
    head_y = height * 0.1
    draw.ellipse([head_x, head_y, head_x + head_width, head_y + head_height], 
                fill=primary_color)
    
    # Body (tapered rectangle)
    body_width = width * 0.5
    body_height = height * 0.4
    body_x = (width - body_width) / 2
    body_y = head_y + head_height - 2  # Slight overlap with head
    draw.rectangle([body_x, body_y, body_x + body_width, body_y + body_height],
                  fill=primary_color)
    
    # Legs
    leg_width = width * 0.2
    leg_height = height * 0.3
    leg_spacing = width * 0.15
    
    # Left leg
    left_leg_x = body_x + body_width*0.25 - leg_width/2
    left_leg_y = body_y + body_height - 2  # Slight overlap
    draw.rectangle([left_leg_x, left_leg_y, left_leg_x + leg_width, left_leg_y + leg_height],
                  fill=primary_color)
    
    # Right leg
    right_leg_x = body_x + body_width*0.75 - leg_width/2
    right_leg_y = body_y + body_height - 2
    draw.rectangle([right_leg_x, right_leg_y, right_leg_x + leg_width, right_leg_y + leg_height],
                  fill=primary_color)

    # Arms
    arm_width = width * 0.15
    arm_height = height * 0.3
    
    # Left arm (slightly angled for a more dynamic idle pose)
    left_arm_x = body_x - 2
    left_arm_y = body_y + 4
    draw.line([(left_arm_x + arm_width/2, left_arm_y), 
               (left_arm_x, left_arm_y + arm_height*0.8)], 
              fill=primary_color, width=int(arm_width))
    
    # Right arm (slightly angled the other way)
    right_arm_x = body_x + body_width + 2 - arm_width
    right_arm_y = body_y + 4
    draw.line([(right_arm_x + arm_width/2, right_arm_y),
               (right_arm_x + arm_width, right_arm_y + arm_height*0.8)],
              fill=primary_color, width=int(arm_width))
    
    # Add facial features (simple)
    eye_size = max(1, int(head_width * 0.15))
    eye_y = head_y + head_height * 0.4
    
    # Left eye
    left_eye_x = head_x + head_width * 0.3
    draw.ellipse([left_eye_x, eye_y, left_eye_x + eye_size, eye_y + eye_size],
                fill=accent_color)
    
    # Right eye
    right_eye_x = head_x + head_width * 0.7 - eye_size
    draw.ellipse([right_eye_x, eye_y, right_eye_x + eye_size, eye_y + eye_size],
                fill=accent_color)
    
    # Add some details/accessories
    
    # Jumper's Mark (glowing symbol that marks Kael as a Jumper)
    mark_size = width * 0.25
    mark_x = (width - mark_size) / 2
    mark_y = body_y + body_height * 0.5 - mark_size/2
    
    # Draw a subtle glow for the mark
    for i in range(3):
        glow_size = mark_size + i*2
        glow_x = mark_x - i
        glow_y = mark_y - i
        glow_alpha = 100 - i*30
        glow_color = aether_color + (glow_alpha,)
        draw.ellipse([glow_x, glow_y, glow_x + glow_size, glow_y + glow_size],
                    fill=glow_color)
    
    # Mark itself (simple geometric shape)
    draw.polygon([
        (mark_x + mark_size/2, mark_y),
        (mark_x + mark_size, mark_y + mark_size*0.7),
        (mark_x + mark_size*0.7, mark_y + mark_size),
        (mark_x + mark_size*0.3, mark_y + mark_size),
        (mark_x, mark_y + mark_size*0.7)
    ], fill=aether_color)
    
    # Add some subtle shading/highlights
    
    # Highlight on head
    highlight_width = head_width * 0.3
    highlight_height = head_height * 0.2
    highlight_x = head_x + head_width * 0.2
    highlight_y = head_y + head_height * 0.2
    draw.ellipse([highlight_x, highlight_y, 
                  highlight_x + highlight_width, highlight_y + highlight_height],
                 fill=accent_color + (100,))
    
    # Add a subtle aether glow effect around the character
    glow = Image.new('RGBA', output_size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    
    # Draw a larger silhouette for the glow
    glow_draw.ellipse([head_x-2, head_y-2, head_x+head_width+2, head_y+head_height+2],
                     fill=aether_color + (40,))
    glow_draw.rectangle([body_x-2, body_y-1, body_x+body_width+2, body_y+body_height+1],
                       fill=aether_color + (40,))
    
    # Blur the glow (simple approximation without filters)
    glow = glow.resize((width//2, height//2), Image.LANCZOS).resize(output_size, Image.LANCZOS)
    
    # Merge the glow with the main image
    result = Image.alpha_composite(glow, image)
    
    # Add a subtle aether particle effect
    particles = Image.new('RGBA', output_size, (0, 0, 0, 0))
    particles_draw = ImageDraw.Draw(particles)
    
    # Draw a few particles of Aether energy
    for _ in range(5):
        px = random.randint(int(width*0.2), int(width*0.8))
        py = random.randint(int(height*0.6), int(height*0.9))
        psize = random.randint(1, 2)
        particles_draw.ellipse([px, py, px+psize, py+psize],
                              fill=aether_color + (200,))
    
    # Add a rising trail effect
    for i in range(3):
        trail_x = width//2 + random.randint(-5, 5)
        trail_y = height - random.randint(5, 15) - i*5
        trail_size = 1
        particles_draw.ellipse([trail_x, trail_y, trail_x+trail_size, trail_y+trail_size],
                              fill=aether_color + (150-i*40,))
    
    # Merge particles with the result
    final_image = Image.alpha_composite(result, particles)
    
    # Save the sprite
    output_path = os.path.join(output_dir, output_filename)
    final_image.save(output_path)
    print(f"Created Kael sprite at: {output_path}")
    return output_path

if __name__ == "__main__":
    # Create Kael's idle sprite
    idle_sprite = create_kael_sprite(output_size=(32, 64), output_filename="player_idle.png")
    
    # Optionally create other basic poses with slight variations
    # These are already present according to the asset manifest, but you can uncomment
    # if you want to regenerate them
    
    # Running pose (slightly different leg positions)
    # create_kael_sprite(output_size=(32, 64), output_filename="player_run.png")
    
    # Jumping pose (arms up, legs together)
    # create_kael_sprite(output_size=(32, 64), output_filename="player_jump.png")
    
    # Falling pose (arms out, legs apart)
    # create_kael_sprite(output_size=(32, 64), output_filename="player_fall.png")
    
    # Landing pose (crouched)
    # create_kael_sprite(output_size=(32, 64), output_filename="player_landing.png")
    
    print("Kael sprite creation complete!")

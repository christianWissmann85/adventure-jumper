#!/usr/bin/env python3
"""
Script to create Zephyr NPC character sprites for Adventure Jumper.
This generates sprite sheets for all required Zephyr animation frames:
- Idle animation (8 frames)
- Gesture animation (6 frames)
- Float animation (12 frames)
"""

from PIL import Image, ImageDraw, ImageFont
import os
import random
import math
import colorsys
import sys

def create_zephyr_sprites():
    """
    Creates all Zephyr NPC sprites with appropriate styling.
    """
    # Create output directory if it doesn't exist
    output_dir = r'c:\Users\User\source\repos\Cascade\adventure-jumper\assets\images\characters\npcs'
    os.makedirs(output_dir, exist_ok=True)
    
    # Define color scheme for Zephyr based on character specs
    # Zephyr is the Archive Guardian with aether-infused appearance and flowing ethereal design
    primary_color = (120, 200, 255)   # Light blue robes (#78C8FF)
    secondary_color = (230, 230, 255)  # Near-white hair with blue tinge (#E6E6FF)
    accent_color = (0, 255, 200)       # Aqua aether energy glow (#00FFC8)
    
    # Define sprites to create
    sprites_to_create = [
        # Each sprite sheet with animation frames
        ('character_zephyr_idle.png', 8, 'idle'),     # 8 frames, 256x32 total
        ('character_zephyr_gesture.png', 6, 'gesture'), # 6 frames, 192x32 total
        ('character_zephyr_float.png', 12, 'float')   # 12 frames, 384x32 total
    ]
    
    # Create each sprite sheet
    for filename, frames, pose in sprites_to_create:
        create_zephyr_sprite_sheet(filename, frames, primary_color, secondary_color, accent_color, pose)
        print(f"Created {filename}")
    
    print("All Zephyr sprites created successfully!")

def create_zephyr_sprite_sheet(filename, frame_count, primary_color, secondary_color, accent_color, pose):
    """
    Creates a sprite sheet for Zephyr with the specified number of animation frames
    
    Args:
        filename: Output filename
        frame_count: Number of animation frames
        primary_color: Main robe color (light blue)
        secondary_color: Hair color (white-blue)
        accent_color: Energy color (aqua)
        pose: Animation type ('idle', 'gesture', 'float')
    """
    output_dir = r'c:\Users\User\source\repos\Cascade\adventure-jumper\assets\images\characters\npcs'
    
    # Each frame is 32x32 pixels
    frame_size = 32
    sprite_width = frame_count * frame_size
    sprite_height = frame_size
    
    # Create base transparent sprite sheet
    sprite_sheet = Image.new('RGBA', (sprite_width, sprite_height), (0, 0, 0, 0))
    
    # Generate each frame
    for frame in range(frame_count):
        # Create a single frame
        frame_img = Image.new('RGBA', (frame_size, frame_size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(frame_img)
        
        # Calculate animation offset based on frame number
        animation_progress = frame / max(frame_count - 1, 1)  # 0.0 to 1.0
        
        # Draw Zephyr based on the pose and animation progress
        draw_zephyr_frame(draw, frame_size, frame_size, primary_color, secondary_color, 
                      accent_color, pose, animation_progress, frame)
        
        # Add the frame to the sprite sheet
        sprite_sheet.paste(frame_img, (frame * frame_size, 0))
    
    # Save the sprite sheet
    output_path = os.path.join(output_dir, filename)
    sprite_sheet.save(output_path)
    return output_path

def draw_zephyr_frame(draw, width, height, primary_color, secondary_color, accent_color, pose, animation_progress, frame_num):
    """
    Draw a single frame of Zephyr's animation
    
    Args:
        draw: ImageDraw object
        width, height: Frame dimensions
        primary_color: Light blue robe color
        secondary_color: White-blue hair color
        accent_color: Aqua energy color
        pose: Animation type ('idle', 'gesture', 'float')
        animation_progress: Progress through animation cycle (0.0 to 1.0)
        frame_num: Current frame number
    """
    # Base character proportions - Zephyr is drawn in 32x32 pixels with ethereal appearance
    head_width = width * 0.4
    head_height = height * 0.35
    head_x = (width - head_width) / 2
    head_y = height * 0.15
    
    body_width = width * 0.5
    body_height = height * 0.45
    body_x = (width - body_width) / 2
    body_y = head_y + head_height - 2  # Slight overlap with head
    
    # Calculate floating animation for all poses
    # Zephyr is always slightly floating with ethereal movement
    float_amount = math.sin(animation_progress * math.pi * 2) * 1.5
    
    # Apply the floating offset to base position
    head_y += float_amount * 0.5
    body_y += float_amount * 0.5
    
    if pose == 'idle':
        # Draw ethereal robe (flowing, semi-transparent)
        robe_top_width = body_width
        robe_bottom_width = body_width * 1.4  # Wider than Mira's robe, more flowing
        
        # Create a slightly transparent version of the primary color
        robe_color = (*primary_color, 220)  # Add alpha channel
        
        # Flowing robe with wave effect
        wave_offset = math.sin(animation_progress * math.pi * 2) * 0.7
        
        # Draw main robe body (flowing form with undulating bottom)
        points = []
        robe_segments = 8  # number of points to create the flowing bottom edge
        
        for i in range(robe_segments + 1):
            # Create wavy bottom edge
            x_percent = i / robe_segments
            x_pos = body_x + (body_width - robe_bottom_width)/2 + robe_bottom_width * x_percent
            
            # Each segment has a different wave offset based on position
            segment_wave = math.sin((x_percent + animation_progress) * math.pi * 2) * 2
            
            if i == 0 or i == robe_segments:
                # First and last points (top corners)
                if i == 0:
                    points.append((body_x + (body_width - robe_top_width)/2, body_y))
                else:
                    points.append((body_x + (body_width + robe_top_width)/2, body_y))
            else:
                # Bottom edge points with wave effect
                bottom_y = body_y + body_height + segment_wave + float_amount
                points.append((x_pos, bottom_y))
        
        # Connect back to first point
        points.append((body_x + (body_width - robe_top_width)/2, body_y))
        
        # Draw the robe as a polygon
        draw.polygon(points, fill=robe_color)
        
        # Add subtle glow effect around robe edges (aether energy)
        for i in range(2):
            glow_points = []
            glow_width = 1.5 - i * 0.5
            glow_alpha = 90 - i * 30
            
            for point in points:
                # Slightly expand points for glow effect
                gx = point[0] + (random.random() - 0.5) * glow_width
                gy = point[1] + (random.random() - 0.5) * glow_width
                glow_points.append((gx, gy))
            
            # Draw glow
            glow_color = (*accent_color, glow_alpha)
            if len(glow_points) >= 3:  # Need at least 3 points for a polygon
                draw.polygon(glow_points, fill=glow_color)
        
        # Head - ethereal appearance
        # Draw a slightly transparent head
        head_color = (*secondary_color, 220)  # Add alpha channel
        draw.ellipse([head_x, head_y, head_x + head_width, head_y + head_height], 
                    fill=head_color)
        
        # Face - more ethereal, less distinct features
        # Just hint at eyes with glowing dots
        eye_size = head_width * 0.15
        left_eye_x = head_x + head_width * 0.25
        right_eye_x = head_x + head_width * 0.75
        eyes_y = head_y + head_height * 0.4
        
        # Glowing eyes
        for eye_x in [left_eye_x, right_eye_x]:
            # Inner glow (brighter)
            draw.ellipse([eye_x - eye_size/2, eyes_y - eye_size/2, 
                        eye_x + eye_size/2, eyes_y + eye_size/2], 
                        fill=accent_color)
            
            # Outer glow (softer)
            larger_size = eye_size * 1.5
            glow_color = (*accent_color, 100)  # Semi-transparent
            draw.ellipse([eye_x - larger_size/2, eyes_y - larger_size/2, 
                        eye_x + larger_size/2, eyes_y + larger_size/2], 
                        fill=glow_color)
        
        # Ethereal energy wisps around the head (aether energy)
        draw_energy_wisps(draw, head_x + head_width/2, head_y + head_height/2, 
                         accent_color, animation_progress, radius=head_width * 0.7)
    
    elif pose == 'gesture':
        # Similar to idle, but with arm/hand gesture
        # Draw ethereal robe base
        robe_top_width = body_width
        robe_bottom_width = body_width * 1.4
        
        # Create a slightly transparent version of the primary color
        robe_color = (*primary_color, 220)  # Add alpha channel
        
        # Main robe body
        draw.polygon([
            (body_x + (body_width - robe_top_width)/2, body_y),
            (body_x + (body_width + robe_top_width)/2, body_y),
            (body_x + (body_width + robe_bottom_width)/2, body_y + body_height + float_amount),
            (body_x + (body_width - robe_bottom_width)/2, body_y + body_height + float_amount)
        ], fill=robe_color)
        
        # Head - ethereal appearance
        head_color = (*secondary_color, 220)  # Add alpha channel
        draw.ellipse([head_x, head_y, head_x + head_width, head_y + head_height], 
                    fill=head_color)
        
        # Glowing eyes
        eye_size = head_width * 0.15
        left_eye_x = head_x + head_width * 0.25
        right_eye_x = head_x + head_width * 0.75
        eyes_y = head_y + head_height * 0.4
        
        # Draw eyes with glow
        for eye_x in [left_eye_x, right_eye_x]:
            # Inner glow (brighter)
            draw.ellipse([eye_x - eye_size/2, eyes_y - eye_size/2, 
                        eye_x + eye_size/2, eyes_y + eye_size/2], 
                        fill=accent_color)
            
            # Outer glow (softer)
            larger_size = eye_size * 1.5
            glow_color = (*accent_color, 100)  # Semi-transparent
            draw.ellipse([eye_x - larger_size/2, eyes_y - larger_size/2, 
                        eye_x + larger_size/2, eyes_y + larger_size/2], 
                        fill=glow_color)
        
        # Gesture animation - hand raised with energy swirl
        # Hand position changes with animation progress
        gesture_height = math.sin(animation_progress * math.pi) * 8
        hand_x = body_x + body_width * 0.7
        hand_y = body_y + body_height * 0.3 - gesture_height  # Moves up and down
        hand_size = width * 0.12
        
        # Draw ethereal hand (glowing)
        hand_color = (*secondary_color, 180)  # Transparent hand
        draw.ellipse([hand_x - hand_size/2, hand_y - hand_size/2, 
                     hand_x + hand_size/2, hand_y + hand_size/2], 
                     fill=hand_color)
        
        # Draw energy swirl around hand
        energy_radius = hand_size * (0.8 + animation_progress * 0.6)  # Grows with animation
        draw_energy_swirl(draw, hand_x, hand_y, accent_color, animation_progress, energy_radius)
        
        # Subtle wisps connecting hand to body
        draw_connecting_wisps(draw, 
                             body_x + body_width * 0.5, body_y + body_height * 0.4,
                             hand_x, hand_y,
                             accent_color, animation_progress)
    
    elif pose == 'float':
        # Full floating animation with more pronounced movement and energy effects
        # More extreme floating effect
        enhanced_float = float_amount * 2.0
        head_y += enhanced_float * 0.5  # Additional floating movement
        body_y += enhanced_float * 0.5
        
        # Draw ethereal robe with more dynamic flow
        robe_top_width = body_width * 0.9  # Slightly narrower top for more flow
        robe_bottom_width = body_width * 1.6  # Much wider at bottom during float
        
        # Create a slightly transparent version of the primary color
        robe_color = (*primary_color, 200)  # More transparent for floating
        
        # Flowing robe with stronger wave effect
        points = []
        robe_segments = 10  # More points for more fluid movement
        
        for i in range(robe_segments + 1):
            # Create very wavy bottom edge
            x_percent = i / robe_segments
            x_pos = body_x + (body_width - robe_bottom_width)/2 + robe_bottom_width * x_percent
            
            # Each segment has a different wave offset based on position and time
            segment_wave = math.sin((x_percent * 2 + animation_progress) * math.pi * 2) * 3
            
            if i == 0 or i == robe_segments:
                # First and last points (top corners)
                if i == 0:
                    points.append((body_x + (body_width - robe_top_width)/2, body_y))
                else:
                    points.append((body_x + (body_width + robe_top_width)/2, body_y))
            else:
                # Bottom edge points with enhanced wave effect
                bottom_y = body_y + body_height + segment_wave + enhanced_float
                points.append((x_pos, bottom_y))
        
        # Connect back to first point
        points.append((body_x + (body_width - robe_top_width)/2, body_y))
        
        # Draw the robe as a polygon
        draw.polygon(points, fill=robe_color)
        
        # Enhanced glow effect around robe
        for i in range(3):  # More glow layers
            glow_points = []
            glow_width = 2.0 - i * 0.5
            glow_alpha = 100 - i * 25
            
            for point in points:
                # Expand points for glow effect
                gx = point[0] + (random.random() - 0.5) * glow_width
                gy = point[1] + (random.random() - 0.5) * glow_width
                glow_points.append((gx, gy))
            
            # Draw glow
            glow_color = (*accent_color, glow_alpha)
            if len(glow_points) >= 3:
                draw.polygon(glow_points, fill=glow_color)
        
        # Head with stronger glow
        head_color = (*secondary_color, 200)  # More transparent for floating
        draw.ellipse([head_x, head_y, head_x + head_width, head_y + head_height], 
                    fill=head_color)
        
        # Brighter eyes during float
        eye_size = head_width * 0.18  # Larger eyes during float
        left_eye_x = head_x + head_width * 0.25
        right_eye_x = head_x + head_width * 0.75
        eyes_y = head_y + head_height * 0.4
        
        # Draw eyes with enhanced glow
        for eye_x in [left_eye_x, right_eye_x]:
            # Inner glow (brighter)
            draw.ellipse([eye_x - eye_size/2, eyes_y - eye_size/2, 
                        eye_x + eye_size/2, eyes_y + eye_size/2], 
                        fill=accent_color)
            
            # Middle glow
            mid_size = eye_size * 1.5
            mid_color = (*accent_color, 150)
            draw.ellipse([eye_x - mid_size/2, eyes_y - mid_size/2, 
                        eye_x + mid_size/2, eyes_y + mid_size/2], 
                        fill=mid_color)
            
            # Outer glow (softer)
            larger_size = eye_size * 2.0
            glow_color = (*accent_color, 80)
            draw.ellipse([eye_x - larger_size/2, eyes_y - larger_size/2, 
                        eye_x + larger_size/2, eyes_y + larger_size/2], 
                        fill=glow_color)
        
        # Multiple energy wisps emanating from the body
        # Center wisp
        draw_energy_wisps(draw, width/2, height/2, 
                         accent_color, animation_progress, radius=width * 0.5)
        
        # Additional wisps
        wisp_count = 3
        for i in range(wisp_count):
            angle = (animation_progress + i/wisp_count) * math.pi * 2
            offset_x = math.cos(angle) * width * 0.15
            offset_y = math.sin(angle) * height * 0.15
            
            draw_energy_wisps(draw, width/2 + offset_x, height/2 + offset_y, 
                             accent_color, animation_progress + i/wisp_count, 
                             radius=width * 0.3)

def draw_energy_wisps(draw, center_x, center_y, color, animation_progress, radius=10.0):
    """Draw ethereal energy wisps emanating from a central point"""
    # Number of wisps
    wisp_count = 5
    
    for i in range(wisp_count):
        # Each wisp starts at a different angle
        base_angle = (i / wisp_count) * math.pi * 2 + animation_progress * math.pi
        
        # Length of wisp
        wisp_length = radius * (0.6 + random.random() * 0.4)
        
        # Draw curved wisp
        points = []
        segments = 8
        
        for j in range(segments + 1):
            # Calculate point along the wisp
            t = j / segments
            # Curve the path
            angle = base_angle + t * math.pi * 0.5 * (random.random() * 0.4 + 0.8)
            # Distance from center decreases toward the end of the wisp
            dist = wisp_length * (1 - t * t)
            # Calculate point
            x = center_x + math.cos(angle) * dist
            y = center_y + math.sin(angle) * dist
            points.append((x, y))
        
        # Draw the wisp with decreasing width
        for j in range(segments):
            # Width decreases along the wisp
            width = 3 * (1 - j/segments) 
            # Alpha decreases along the wisp
            alpha = int(150 * (1 - j/segments))
            wisp_color = (*color[:3], alpha)
            
            # Draw line segment
            if j < len(points) - 1:  # Ensure we have a next point
                draw.line([points[j], points[j+1]], fill=wisp_color, width=int(width))

def draw_energy_swirl(draw, center_x, center_y, color, animation_progress, radius=10.0):
    """Draw a swirling energy pattern around a central point"""
    # Number of energy particles in the swirl
    particle_count = 12
    
    for i in range(particle_count):
        # Each particle is at a different position in the swirl
        angle = (i / particle_count) * math.pi * 2 + animation_progress * math.pi * 4
        
        # Distance from center (spiral effect)
        distance = radius * (0.4 + 0.6 * (i / particle_count))
        
        # Calculate particle position
        x = center_x + math.cos(angle) * distance
        y = center_y + math.sin(angle) * distance
        
        # Particle size decreases toward the center
        particle_size = 2 + 2 * (i / particle_count)
        
        # Particle color with varying alpha
        alpha = int(200 * (0.5 + 0.5 * i / particle_count))
        particle_color = (*color[:3], alpha)
        
        # Draw the particle
        draw.ellipse([x - particle_size/2, y - particle_size/2, 
                      x + particle_size/2, y + particle_size/2], 
                     fill=particle_color)
        
        # Add a glow around larger particles
        if particle_size > 3:
            glow_size = particle_size * 2
            glow_color = (*color[:3], int(alpha * 0.4))
            draw.ellipse([x - glow_size/2, y - glow_size/2, 
                          x + glow_size/2, y + glow_size/2], 
                         fill=glow_color)

def draw_connecting_wisps(draw, start_x, start_y, end_x, end_y, color, animation_progress):
    """Draw ethereal wisps connecting two points (like an energy flow)"""
    # Number of wisp lines
    wisp_count = 3
    
    # Distance between points
    dx = end_x - start_x
    dy = end_y - start_y
    distance = math.sqrt(dx*dx + dy*dy)
    
    # Base angle between points
    base_angle = math.atan2(dy, dx)
    
    for i in range(wisp_count):
        # Create a curved path for each wisp
        control_deviation = distance * 0.3  # How much the control point deviates
        
        # Control point perpendicular to the line
        perpendicular_angle = base_angle + math.pi/2
        
        # Deviation oscillates with animation
        deviation_factor = math.sin((animation_progress + i/wisp_count) * math.pi * 2)
        
        # Control point coordinates
        mid_x = (start_x + end_x) / 2 + math.cos(perpendicular_angle) * control_deviation * deviation_factor
        mid_y = (start_y + end_y) / 2 + math.sin(perpendicular_angle) * control_deviation * deviation_factor
        
        # Draw the curved wisp as multiple segments
        segments = 10
        last_x, last_y = start_x, start_y
        
        for j in range(1, segments + 1):
            t = j / segments
            # Quadratic Bezier calculation
            x = (1-t)**2 * start_x + 2*(1-t)*t * mid_x + t**2 * end_x
            y = (1-t)**2 * start_y + 2*(1-t)*t * mid_y + t**2 * end_y
            
            # Width and alpha decrease along the path
            width = 2 * (1 - 0.5 * abs(t - 0.5) * 2)  # Thickest in the middle
            alpha = int(120 * width / 2)
            wisp_color = (*color[:3], alpha)
            
            # Draw line segment
            draw.line([(last_x, last_y), (x, y)], fill=wisp_color, width=int(width))
            
            # Update last point
            last_x, last_y = x, y

if __name__ == "__main__":
    create_zephyr_sprites()

#!/usr/bin/env python3
"""
Script to create Mira NPC character sprites for Adventure Jumper.
This generates sprite sheets for all required Mira animation frames:
- Idle animation (6 frames)
- Talking animation (4 frames)
- Pointing animation (3 frames)
"""

from PIL import Image, ImageDraw, ImageFont
import os
import random
import math
import colorsys
import sys

def create_mira_sprites():
    """
    Creates all Mira NPC sprites with appropriate styling.
    """
    # Create output directory if it doesn't exist
    output_dir = r'c:\Users\User\source\repos\Cascade\adventure-jumper\assets\images\characters\npcs'
    os.makedirs(output_dir, exist_ok=True)
    
    # Define color scheme for Mira based on character specs
    # Mira is the Archivist with silver hair, blue robes, and golden accessories
    primary_color = (0, 102, 204)    # Blue robes (#0066CC)
    secondary_color = (192, 192, 192) # Silver hair (#C0C0C0)
    accent_color = (255, 215, 0)      # Golden accessories (#FFD700)
    
    # Define sprites to create
    sprites_to_create = [
        # Each sprite sheet with animation frames
        ('character_mira_idle.png', 6, 'idle'),     # 6 frames, 192x32 total
        ('character_mira_talk.png', 4, 'talking'),  # 4 frames, 128x32 total
        ('character_mira_point.png', 3, 'pointing') # 3 frames, 96x32 total
    ]
    
    # Create each sprite sheet
    for filename, frames, pose in sprites_to_create:
        create_mira_sprite_sheet(filename, frames, primary_color, secondary_color, accent_color, pose)
        print(f"Created {filename}")
    
    print("All Mira sprites created successfully!")

def create_mira_sprite_sheet(filename, frame_count, primary_color, secondary_color, accent_color, pose):
    """
    Creates a sprite sheet for Mira with the specified number of animation frames
    
    Args:
        filename: Output filename
        frame_count: Number of animation frames
        primary_color: Main robe color (blue)
        secondary_color: Hair color (silver)
        accent_color: Accessories color (gold)
        pose: Animation type ('idle', 'talking', 'pointing')
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
        
        # Draw Mira based on the pose and animation progress
        draw_mira_frame(draw, frame_size, frame_size, primary_color, secondary_color, 
                      accent_color, pose, animation_progress, frame)
        
        # Add the frame to the sprite sheet
        sprite_sheet.paste(frame_img, (frame * frame_size, 0))
    
    # Save the sprite sheet
    output_path = os.path.join(output_dir, filename)
    sprite_sheet.save(output_path)
    return output_path

def draw_mira_frame(draw, width, height, primary_color, secondary_color, accent_color, pose, animation_progress, frame_num):
    """
    Draw a single frame of Mira's animation
    
    Args:
        draw: ImageDraw object
        width, height: Frame dimensions
        primary_color: Blue robe color
        secondary_color: Silver hair color
        accent_color: Gold accessory color
        pose: Animation type ('idle', 'talking', 'pointing')
        animation_progress: Progress through animation cycle (0.0 to 1.0)
        frame_num: Current frame number
    """
    # Base character proportions - Mira is drawn in 32x32 pixels
    head_width = width * 0.4
    head_height = height * 0.35
    head_x = (width - head_width) / 2
    head_y = height * 0.15
    
    body_width = width * 0.5
    body_height = height * 0.45
    body_x = (width - body_width) / 2
    body_y = head_y + head_height - 2  # Slight overlap with head
    
    # Basic idle pose as foundation
    if pose == 'idle':
        # Draw flowing robe (wider at bottom)
        robe_top_width = body_width
        robe_bottom_width = body_width * 1.3
        
        # Robe with slight bobbing motion
        bob_offset = math.sin(animation_progress * math.pi * 2) * 0.5
        
        # Robe/body (trapezoid shape)
        draw.polygon([
            (body_x + (body_width - robe_top_width)/2, body_y),
            (body_x + (body_width + robe_top_width)/2, body_y),
            (body_x + (body_width + robe_bottom_width)/2, body_y + body_height + bob_offset),
            (body_x + (body_width - robe_bottom_width)/2, body_y + body_height + bob_offset)
        ], fill=primary_color)
        
        # Head with silver hair in bun
        draw.ellipse([head_x, head_y + bob_offset/2, head_x + head_width, head_y + head_height + bob_offset/2], 
                    fill=secondary_color)
        
        # Face (slightly smaller ellipse)
        face_width = head_width * 0.8
        face_height = head_height * 0.8
        face_x = head_x + (head_width - face_width) / 2
        face_y = head_y + (head_height - face_height) / 2 + bob_offset/2
        draw.ellipse([face_x, face_y, face_x + face_width, face_y + face_height], 
                    fill=(255, 220, 200, 255))  # Light skin tone
        
        # Round glasses
        glasses_size = head_width * 0.25
        left_eye_x = head_x + head_width * 0.25 - glasses_size/2
        right_eye_x = head_x + head_width * 0.75 - glasses_size/2
        eyes_y = head_y + head_height * 0.4 - glasses_size/2 + bob_offset/2
        
        # Draw glasses frames
        draw.ellipse([left_eye_x, eyes_y, left_eye_x + glasses_size, eyes_y + glasses_size], 
                    outline=accent_color, width=1)
        draw.ellipse([right_eye_x, eyes_y, right_eye_x + glasses_size, eyes_y + glasses_size], 
                    outline=accent_color, width=1)
        draw.line([left_eye_x + glasses_size, eyes_y + glasses_size/2, 
                  right_eye_x, eyes_y + glasses_size/2], fill=accent_color, width=1)
        
        # Hair bun on top of head
        bun_size = head_width * 0.35
        bun_x = head_x + (head_width - bun_size) / 2
        bun_y = head_y - bun_size * 0.7 + bob_offset/2
        draw.ellipse([bun_x, bun_y, bun_x + bun_size, bun_y + bun_size], 
                    fill=secondary_color)
        
        # Floating quill (Mira's distinctive feature)
        quill_bob_offset = bob_offset * 1.5 - 0.5  # More pronounced bobbing for quill
        draw_floating_quill(draw, width, height, accent_color, quill_bob_offset, animation_progress)
        
    elif pose == 'talking':
        # Similar to idle, but with mouth animation and hand gesture
        # Robe/body (trapezoid shape)
        robe_top_width = body_width
        robe_bottom_width = body_width * 1.3
        draw.polygon([
            (body_x + (body_width - robe_top_width)/2, body_y),
            (body_x + (body_width + robe_top_width)/2, body_y),
            (body_x + (body_width + robe_bottom_width)/2, body_y + body_height),
            (body_x + (body_width - robe_bottom_width)/2, body_y + body_height)
        ], fill=primary_color)
        
        # Head with silver hair in bun
        draw.ellipse([head_x, head_y, head_x + head_width, head_y + head_height], 
                    fill=secondary_color)
        
        # Face (slightly smaller ellipse)
        face_width = head_width * 0.8
        face_height = head_height * 0.8
        face_x = head_x + (head_width - face_width) / 2
        face_y = head_y + (head_height - face_height) / 2
        draw.ellipse([face_x, face_y, face_x + face_width, face_y + face_height], 
                    fill=(255, 220, 200, 255))  # Light skin tone
        
        # Round glasses
        glasses_size = head_width * 0.25
        left_eye_x = head_x + head_width * 0.25 - glasses_size/2
        right_eye_x = head_x + head_width * 0.75 - glasses_size/2
        eyes_y = head_y + head_height * 0.4 - glasses_size/2
        
        # Draw glasses frames
        draw.ellipse([left_eye_x, eyes_y, left_eye_x + glasses_size, eyes_y + glasses_size], 
                    outline=accent_color, width=1)
        draw.ellipse([right_eye_x, eyes_y, right_eye_x + glasses_size, eyes_y + glasses_size], 
                    outline=accent_color, width=1)
        draw.line([left_eye_x + glasses_size, eyes_y + glasses_size/2, 
                  right_eye_x, eyes_y + glasses_size/2], fill=accent_color, width=1)
        
        # Hair bun on top of head
        bun_size = head_width * 0.35
        bun_x = head_x + (head_width - bun_size) / 2
        bun_y = head_y - bun_size * 0.7
        draw.ellipse([bun_x, bun_y, bun_x + bun_size, bun_y + bun_size], 
                    fill=secondary_color)
        
        # Mouth animation - changes size based on frame
        mouth_width = head_width * 0.3 * (0.7 + 0.3 * math.sin(animation_progress * math.pi * 2))
        mouth_height = head_height * 0.1 * (0.7 + 0.3 * math.sin(animation_progress * math.pi * 2))
        mouth_x = head_x + (head_width - mouth_width) / 2
        mouth_y = head_y + head_height * 0.65
        draw.ellipse([mouth_x, mouth_y, mouth_x + mouth_width, mouth_y + mouth_height], 
                    fill=(150, 50, 50, 255))  # Mouth color
        
        # Talking hand gesture (right hand raised)
        hand_x = body_x + body_width * 0.8
        hand_y = body_y + body_height * 0.3
        hand_size = width * 0.1
        gesture_offset = math.sin(animation_progress * math.pi * 2) * 2  # Hand moves slightly
        draw.ellipse([hand_x + gesture_offset, hand_y, 
                     hand_x + hand_size + gesture_offset, hand_y + hand_size], 
                     fill=(255, 220, 200, 255))  # Hand color
        
        # Floating quill (moves more actively during talking)
        quill_anim_offset = math.sin(animation_progress * math.pi * 4) * 1.5
        draw_floating_quill(draw, width, height, accent_color, quill_anim_offset, animation_progress)
        
    elif pose == 'pointing':
        # Similar to talking, but with pointing gesture
        # Robe/body (trapezoid shape)
        robe_top_width = body_width
        robe_bottom_width = body_width * 1.3
        draw.polygon([
            (body_x + (body_width - robe_top_width)/2, body_y),
            (body_x + (body_width + robe_top_width)/2, body_y),
            (body_x + (body_width + robe_bottom_width)/2, body_y + body_height),
            (body_x + (body_width - robe_bottom_width)/2, body_y + body_height)
        ], fill=primary_color)
        
        # Head with silver hair in bun
        draw.ellipse([head_x, head_y, head_x + head_width, head_y + head_height], 
                    fill=secondary_color)
        
        # Face (slightly smaller ellipse)
        face_width = head_width * 0.8
        face_height = head_height * 0.8
        face_x = head_x + (head_width - face_width) / 2
        face_y = head_y + (head_height - face_height) / 2
        draw.ellipse([face_x, face_y, face_x + face_width, face_y + face_height], 
                    fill=(255, 220, 200, 255))  # Light skin tone
        
        # Round glasses
        glasses_size = head_width * 0.25
        left_eye_x = head_x + head_width * 0.25 - glasses_size/2
        right_eye_x = head_x + head_width * 0.75 - glasses_size/2
        eyes_y = head_y + head_height * 0.4 - glasses_size/2
        
        # Draw glasses frames
        draw.ellipse([left_eye_x, eyes_y, left_eye_x + glasses_size, eyes_y + glasses_size], 
                    outline=accent_color, width=1)
        draw.ellipse([right_eye_x, eyes_y, right_eye_x + glasses_size, eyes_y + glasses_size], 
                    outline=accent_color, width=1)
        draw.line([left_eye_x + glasses_size, eyes_y + glasses_size/2, 
                  right_eye_x, eyes_y + glasses_size/2], fill=accent_color, width=1)
        
        # Hair bun on top of head
        bun_size = head_width * 0.35
        bun_x = head_x + (head_width - bun_size) / 2
        bun_y = head_y - bun_size * 0.7
        draw.ellipse([bun_x, bun_y, bun_x + bun_size, bun_y + bun_size], 
                    fill=secondary_color)
        
        # Small mouth (fixed, not animated)
        mouth_width = head_width * 0.25
        mouth_height = head_height * 0.05
        mouth_x = head_x + (head_width - mouth_width) / 2
        mouth_y = head_y + head_height * 0.65
        draw.ellipse([mouth_x, mouth_y, mouth_x + mouth_width, mouth_y + mouth_height], 
                    fill=(150, 50, 50, 255))  # Mouth color
        
        # Pointing gesture (arm extended forward)
        arm_width = width * 0.1
        arm_length = width * 0.4
        arm_x = body_x + body_width * 0.75
        arm_y = body_y + body_height * 0.3
        
        # Animate the pointing gesture
        gesture_extension = animation_progress * 0.2  # Extending arm animation
        point_angle = -30 + animation_progress * 10  # Slight angle change
        point_angle_rad = point_angle * (math.pi / 180)
        
        # Calculate arm end point based on angle
        arm_end_x = arm_x + math.cos(point_angle_rad) * (arm_length * (0.8 + gesture_extension))
        arm_end_y = arm_y + math.sin(point_angle_rad) * (arm_length * (0.8 + gesture_extension))
        
        # Draw arm
        draw.line([(arm_x, arm_y), (arm_end_x, arm_end_y)], 
                 fill=primary_color, width=int(arm_width))
        
        # Draw hand at the end of the arm
        hand_size = width * 0.12
        draw.ellipse([arm_end_x - hand_size/2, arm_end_y - hand_size/2, 
                     arm_end_x + hand_size/2, arm_end_y + hand_size/2], 
                     fill=(255, 220, 200, 255))
        
        # Draw pointed finger
        finger_length = hand_size * 0.8
        finger_angle_rad = point_angle_rad - math.pi/8  # Angle finger slightly up
        finger_end_x = arm_end_x + math.cos(finger_angle_rad) * finger_length
        finger_end_y = arm_end_y + math.sin(finger_angle_rad) * finger_length
        draw.line([(arm_end_x, arm_end_y), (finger_end_x, finger_end_y)], 
                 fill=(255, 220, 200, 255), width=2)
        
        # Floating quill (moves less during pointing as focus is on the gesture)
        quill_static_offset = 0.5 + animation_progress * 0.5
        draw_floating_quill(draw, width, height, accent_color, quill_static_offset, animation_progress * 0.5)

def draw_floating_quill(draw, width, height, accent_color, offset_y, animation_progress):
    """Draw Mira's floating quill with subtle animation"""
    # Quill positioning
    quill_x = width * 0.7
    quill_y = height * 0.3 + offset_y
    quill_length = width * 0.25
    quill_width = height * 0.06
    quill_angle = -30 + (math.sin(animation_progress * math.pi * 2) * 5)
    quill_angle_rad = quill_angle * (math.pi / 180)
    
    # Calculate quill end points
    quill_end_x = quill_x + math.cos(quill_angle_rad) * quill_length
    quill_end_y = quill_y + math.sin(quill_angle_rad) * quill_length
    
    # Draw quill body
    draw.line([(quill_x, quill_y), (quill_end_x, quill_end_y)], 
             fill=accent_color, width=int(quill_width))
    
    # Draw quill tip
    tip_length = quill_length * 0.3
    tip_angle_rad = quill_angle_rad - (math.pi/12)  # Angle tip slightly differently
    tip_end_x = quill_end_x + math.cos(tip_angle_rad) * tip_length
    tip_end_y = quill_end_y + math.sin(tip_angle_rad) * tip_length
    draw.line([(quill_end_x, quill_end_y), (tip_end_x, tip_end_y)], 
             fill=accent_color, width=int(quill_width * 0.8))
    
    # Draw subtle glow around quill
    for i in range(2):
        glow_size = 2 - i*0.5
        glow_alpha = 70 - i*30
        glow_color = tuple(list(accent_color) + [glow_alpha])
        draw.line([(quill_x, quill_y), (quill_end_x, quill_end_y)], 
                 fill=glow_color, width=int(quill_width + glow_size))

if __name__ == "__main__":
    create_mira_sprites()

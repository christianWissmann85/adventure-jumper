#!/usr/bin/env python3
"""
Asset Placeholder Generator for Adventure Jumper
Generates placeholder assets for all missing files identified in the asset inventory.
"""

import os
import json
from PIL import Image, ImageDraw, ImageFont
import colorsys

def ensure_directory_exists(path):
    """Create directory if it doesn't exist."""
    os.makedirs(path, exist_ok=True)

def generate_colored_sprite(width, height, color, text="", output_path=""):
    """Generate a colored placeholder sprite with optional text."""
    # Create image with transparency
    image = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Draw colored rectangle with border (ensure valid coordinates)
    border = min(2, width // 4, height // 4)
    if width > border * 2 and height > border * 2:
        draw.rectangle([border, border, width-border-1, height-border-1], fill=color, outline=(0, 0, 0, 255), width=1)
    else:
        # For very small sprites, just fill with color
        draw.rectangle([0, 0, width-1, height-1], fill=color)
      # Add text if provided and image is large enough
    if text and width >= 16 and height >= 12:
        try:
            # Try to use a simple font
            font_size = min(width // max(len(text), 1), height // 3, 12)
            if font_size > 4:
                # Calculate text position (centered)
                bbox = draw.textbbox((0, 0), text)
                text_width = bbox[2] - bbox[0]
                text_height = bbox[3] - bbox[1]
                x = max(0, (width - text_width) // 2)
                y = max(0, (height - text_height) // 2)
                
                # Ensure text fits within bounds
                if x + text_width <= width and y + text_height <= height:
                    # Draw text with outline for visibility
                    for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                        if x + dx >= 0 and y + dy >= 0:
                            draw.text((x + dx, y + dy), text, fill=(0, 0, 0, 255))
                    draw.text((x, y), text, fill=(255, 255, 255, 255))
        except Exception as e:
            print(f"Warning: Could not add text '{text}' to {width}x{height} sprite: {e}")
            pass  # Skip text if any issues
      # Save the image
    if output_path:
        try:
            ensure_directory_exists(os.path.dirname(output_path))
            image.save(output_path)
            print(f"Created: {output_path}")
        except Exception as e:
            print(f"Error creating {output_path}: {e}")
    
    return image
    
    return image

def create_sprite_sheet(frames, frame_width, frame_height, output_path, base_color, animation_name):
    """Create a sprite sheet with multiple frames showing animation progression."""
    sheet_width = frames * frame_width
    sheet_height = frame_height
    
    # Create the sprite sheet
    sprite_sheet = Image.new('RGBA', (sheet_width, sheet_height), (0, 0, 0, 0))
    
    for frame in range(frames):
        # Create slight color variation for each frame to simulate animation
        hue_shift = (frame * 30) % 360
        r, g, b = base_color[:3]
        h, s, v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
        h = (h + hue_shift/360) % 1.0
        new_r, new_g, new_b = colorsys.hsv_to_rgb(h, s, v)
        frame_color = (int(new_r * 255), int(new_g * 255), int(new_b * 255), 255)
        
        # Generate frame
        frame_image = generate_colored_sprite(
            frame_width, frame_height, frame_color, 
            text=f"{animation_name[:3]}{frame+1}"
        )
        
        # Paste frame into sprite sheet
        sprite_sheet.paste(frame_image, (frame * frame_width, 0))
    
    # Save sprite sheet
    ensure_directory_exists(os.path.dirname(output_path))
    sprite_sheet.save(output_path)
    print(f"Created sprite sheet: {output_path}")

def create_silent_audio_file(output_path, duration_seconds=1.0):
    """Create a silent audio file using basic file operations (no audio libraries needed)."""
    # Create a minimal WAV file header for a silent audio file
    # This is a simplified approach that creates a valid but silent WAV file
    
    ensure_directory_exists(os.path.dirname(output_path))
    
    # Simple silent WAV file creation (44.1kHz, 16-bit, mono)
    sample_rate = 44100
    bits_per_sample = 16
    channels = 1
    samples = int(sample_rate * duration_seconds)
    
    # WAV file header (44 bytes)
    header = bytearray(44)
    
    # "RIFF" chunk descriptor
    header[0:4] = b'RIFF'
    header[4:8] = (36 + samples * channels * bits_per_sample // 8).to_bytes(4, 'little')
    header[8:12] = b'WAVE'
    
    # "fmt " sub-chunk
    header[12:16] = b'fmt '
    header[16:20] = (16).to_bytes(4, 'little')  # Sub-chunk size
    header[20:22] = (1).to_bytes(2, 'little')   # Audio format (PCM)
    header[22:24] = channels.to_bytes(2, 'little')
    header[24:28] = sample_rate.to_bytes(4, 'little')
    header[28:32] = (sample_rate * channels * bits_per_sample // 8).to_bytes(4, 'little')
    header[32:34] = (channels * bits_per_sample // 8).to_bytes(2, 'little')
    header[34:36] = bits_per_sample.to_bytes(2, 'little')
    
    # "data" sub-chunk
    header[36:40] = b'data'
    header[40:44] = (samples * channels * bits_per_sample // 8).to_bytes(4, 'little')
    
    # Write the file
    with open(output_path, 'wb') as f:
        f.write(header)
        # Write silent samples (all zeros)
        f.write(b'\x00' * (samples * channels * bits_per_sample // 8))
    
    print(f"Created silent audio: {output_path}")

def main():
    """Generate all missing placeholder assets."""
    base_path = r'c:\Users\User\source\repos\Cascade\adventure-jumper\assets'
    
    print("=== Adventure Jumper Asset Placeholder Generator ===")
    print("Generating placeholder assets for all missing files...\n")
    
    # Enemy Character Assets
    print("1. Creating Enemy Character Assets...")
    enemies_path = os.path.join(base_path, 'images', 'characters', 'enemies')
    
    enemy_assets = [
        ('goblin_idle.png', 24, 24, (100, 200, 100, 255), 'Goblin'),
        ('goblin_walk.png', 144, 24, (100, 200, 100, 255), 'Goblin'),  # 6 frames
        ('orc_idle.png', 48, 48, (200, 100, 100, 255), 'Orc'),
        ('orc_attack.png', 336, 48, (200, 100, 100, 255), 'Orc'),  # 7 frames
        ('enemy_forest_creeper_idle.png', 96, 24, (150, 200, 150, 255), 'Creeper'),  # 4 frames
        ('enemy_forest_creeper_walk.png', 144, 24, (150, 200, 150, 255), 'Creeper'),  # 6 frames
        ('enemy_thorn_spitter_idle.png', 192, 24, (200, 150, 100, 255), 'Spitter'),  # 6 frames
        ('enemy_thorn_spitter_attack.png', 256, 24, (200, 150, 100, 255), 'Spitter'),  # 8 frames
    ]
    
    for asset_name, width, height, color, enemy_type in enemy_assets:
        output_path = os.path.join(enemies_path, asset_name)
        if width > height:  # Sprite sheet
            frames = width // height
            create_sprite_sheet(frames, height, height, output_path, color, enemy_type)
        else:  # Single sprite
            generate_colored_sprite(width, height, color, enemy_type, output_path)
    
    # UI Assets
    print("\n2. Creating UI Assets...")
    ui_path = os.path.join(base_path, 'images', 'ui')
    
    ui_assets = [
        # HUD elements
        ('hud/ui_health_bar_frame.png', 120, 16, (100, 100, 200, 255), 'HP'),
        ('hud/ui_health_bar_fill.png', 112, 8, (200, 100, 100, 255), 'FILL'),
        ('hud/ui_aether_counter_frame.png', 80, 24, (150, 100, 200, 255), 'AETHER'),
        ('hud/ui_aether_counter_icon.png', 16, 16, (200, 150, 255, 255), 'A'),
        
        # Button assets
        ('buttons/ui_button.png', 288, 32, (150, 150, 150, 255), 'BTN'),  # 3 states
        ('menus/ui_button_crystal_normal.png', 64, 24, (100, 200, 255, 255), 'CRYSTAL'),
        ('menus/ui_button_crystal_hover.png', 64, 24, (150, 220, 255, 255), 'HOVER'),
        ('menus/ui_button_crystal_pressed.png', 64, 24, (80, 180, 255, 255), 'PRESS'),
        
        # Menu assets
        ('menus/ui_main_menu_bg.png', 320, 180, (50, 50, 100, 255), 'MENU'),
        
        # Tutorial assets
        ('tutorial/ui_tutorial_arrow.png', 32, 32, (255, 255, 100, 255), '=>'),
        ('tutorial/ui_tutorial_highlight.png', 48, 48, (255, 255, 150, 180), 'HELP'),
        ('tutorial/ui_tutorial_marker.png', 24, 24, (255, 200, 100, 255), '!'),
        ('tutorial/ui_key_prompt_wasd.png', 64, 32, (200, 200, 200, 255), 'WASD'),
        ('tutorial/ui_key_prompt_space.png', 48, 16, (200, 200, 200, 255), 'SPACE'),
    ]
    
    for asset_name, width, height, color, text in ui_assets:
        output_path = os.path.join(ui_path, asset_name)
        generate_colored_sprite(width, height, color, text, output_path)
    
    # Tileset Assets
    print("\n3. Creating Tileset Assets...")
    tileset_path = os.path.join(base_path, 'images', 'tilesets', 'luminara')
    
    tileset_assets = [
        ('tile_luminara_crystal_platform_azure.png', 16, 16, (100, 200, 255, 255), ''),
        ('tile_luminara_crystal_platform_teal.png', 16, 16, (100, 255, 200, 255), ''),
        ('tile_luminara_master_spire_base.png', 128, 256, (150, 150, 255, 255), 'SPIRE'),
        ('tile_luminara_spire_segment.png', 64, 64, (120, 120, 255, 255), 'SEG'),
        ('tile_luminara_crystal_bridge.png', 48, 16, (180, 180, 255, 255), 'BRIDGE'),
        ('tile_luminara_crystal_steps.png', 32, 32, (160, 160, 255, 255), 'STEPS'),
        ('tile_luminara_archive_entrance.png', 96, 96, (100, 100, 255, 255), 'ARCH'),
        ('tile_luminara_market_stall.png', 64, 48, (200, 180, 255, 255), 'STALL'),
    ]
    
    for asset_name, width, height, color, text in tileset_assets:
        output_path = os.path.join(tileset_path, asset_name)
        generate_colored_sprite(width, height, color, text, output_path)
    
    # Effects Assets
    print("\n4. Creating Effects Assets...")
    
    # Aether effects
    aether_effects_path = os.path.join(base_path, 'images', 'effects', 'aether')
    aether_effects = [
        ('effect_aether_pickup.png', 32, 32, (255, 200, 255, 200), 'PICK'),
        ('effect_crystal_resonance.png', 64, 64, (200, 200, 255, 180), 'RESON'),
        ('character_player_aether_dash.png', 128, 32, (255, 150, 255, 200), 'DASH'),  # 4 frames
        ('character_player_aether_pulse.png', 192, 32, (200, 150, 255, 200), 'PULSE'),  # 6 frames
        ('character_player_aether_shield.png', 256, 32, (150, 200, 255, 200), 'SHIELD'),  # 8 frames
    ]
    
    for asset_name, width, height, color, text in aether_effects:
        output_path = os.path.join(aether_effects_path, asset_name)
        if width > height and 'character_player' in asset_name:  # Sprite sheet
            frames = width // height
            create_sprite_sheet(frames, height, height, output_path, color, text)
        else:
            generate_colored_sprite(width, height, color, text, output_path)
    
    # Environmental effects
    env_effects_path = os.path.join(base_path, 'images', 'effects', 'environmental')
    env_effects = [
        ('effect_dust_motes.png', 128, 8, (200, 200, 150, 150), 'DUST'),  # 16 frames
        ('effect_crystal_sparkle.png', 192, 16, (255, 255, 200, 200), 'SPARK'),  # 12 frames
        ('effect_light_ray.png', 24, 64, (255, 255, 150, 150), 'RAY'),  # 6 frames
        ('effect_floating_particle.png', 80, 4, (200, 255, 200, 180), 'FLOAT'),  # 20 frames
    ]
    
    for asset_name, width, height, color, text in env_effects:
        output_path = os.path.join(env_effects_path, asset_name)
        frames = width // height if width > height else 1
        if frames > 1:
            create_sprite_sheet(frames, height, height, output_path, color, text)
        else:
            generate_colored_sprite(width, height, color, text, output_path)
    
    # Props Assets
    print("\n5. Creating Props Assets...")
    props_path = os.path.join(base_path, 'images', 'props')
    
    # Luminara props
    luminara_props = [
        ('luminara/prop_luminara_aether_well_core.png', 64, 64, (150, 255, 255, 255), 'WELL'),
        ('luminara/prop_luminara_small_crystal.png', 16, 16, (200, 200, 255, 255), 'S'),
        ('luminara/prop_luminara_medium_crystal.png', 32, 32, (180, 180, 255, 255), 'M'),
        ('luminara/prop_luminara_large_crystal.png', 48, 64, (160, 160, 255, 255), 'L'),
        ('luminara/prop_luminara_crystal_growth.png', 24, 32, (200, 180, 255, 255), 'GROW'),
        ('luminara/prop_luminara_floating_shard.png', 8, 8, (255, 200, 255, 255), 'F'),
        ('luminara/prop_luminara_luminous_moss.png', 16, 8, (150, 255, 150, 255), 'MOSS'),
        ('luminara/prop_luminara_inscription.png', 32, 24, (180, 180, 180, 255), 'TEXT'),
        
        # Collectibles
        ('collectibles/collectible_aether_shard.png', 16, 16, (255, 150, 255, 255), 'SHARD'),
    ]
    
    for asset_name, width, height, color, text in luminara_props:
        output_path = os.path.join(props_path, asset_name)
        generate_colored_sprite(width, height, color, text, output_path)
    
    # NPC Assets
    print("\n6. Creating NPC Assets...")
    npcs_path = os.path.join(base_path, 'images', 'characters', 'npcs')
    
    npc_assets = [
        # Mira
        ('character_mira_idle.png', 192, 32, (255, 180, 120, 255), 'Mira'),  # 6 frames
        ('character_mira_talk.png', 128, 32, (255, 180, 120, 255), 'Talk'),  # 4 frames
        ('character_mira_point.png', 96, 32, (255, 180, 120, 255), 'Point'),  # 3 frames
        
        # Zephyr
        ('character_zephyr_idle.png', 256, 32, (150, 150, 255, 255), 'Zephyr'),  # 8 frames
        ('character_zephyr_gesture.png', 192, 32, (150, 150, 255, 255), 'Gesture'),  # 6 frames
        ('character_zephyr_float.png', 384, 32, (150, 150, 255, 255), 'Float'),  # 12 frames
    ]
    
    for asset_name, width, height, color, text in npc_assets:
        output_path = os.path.join(npcs_path, asset_name)
        frames = width // height
        create_sprite_sheet(frames, height, height, output_path, color, text)
    
    # Background Assets
    print("\n7. Creating Background Assets...")
    bg_path = os.path.join(base_path, 'images', 'backgrounds', 'luminara')
    
    bg_assets = [
        ('bg_luminara_sky.png', 320, 180, (100, 150, 255, 255), 'SKY'),
        ('bg_luminara_distant_crystals.png', 640, 180, (150, 180, 255, 200), 'DIST'),
        ('bg_luminara_mid_spires.png', 960, 180, (120, 150, 255, 180), 'MID'),
        ('bg_luminara_near_arch.png', 1280, 180, (100, 120, 255, 160), 'NEAR'),
        ('bg_crystal_fog.png', 320, 60, (200, 200, 255, 100), 'FOG'),
        ('bg_light_shafts.png', 160, 180, (255, 255, 200, 120), 'LIGHT'),
        ('bg_particle_field.png', 320, 180, (255, 255, 255, 80), 'PARTICLES'),
    ]
    
    for asset_name, width, height, color, text in bg_assets:
        output_path = os.path.join(bg_path, asset_name)
        generate_colored_sprite(width, height, color, text, output_path)
    
    # Audio Assets
    print("\n8. Creating Audio Assets...")
    
    # Music assets
    music_path = os.path.join(base_path, 'audio', 'music')
    music_files = [
        'main_theme.mp3', 'level_1.mp3', 'level_2.mp3', 'boss_fight.mp3',
        'peaceful_area.mp3', 'tension.mp3', 'victory.mp3', 'game_over.mp3'
    ]
    
    for music_file in music_files:
        output_path = os.path.join(music_path, music_file)
        create_silent_audio_file(output_path, duration_seconds=30.0)  # Longer for music
    
    # Sound effects
    sfx_path = os.path.join(base_path, 'audio', 'sfx')
    sfx_files = [
        'jump.wav', 'land.wav', 'attack.wav', 'hit.wav', 'collect_coin.wav',
        'collect_powerup.wav', 'enemy_death.wav', 'button_click.wav',
        'button_hover.wav', 'menu_open.wav', 'menu_close.wav',
        'checkpoint.wav', 'level_complete.wav', 'game_over.wav'
    ]
    
    for sfx_file in sfx_files:
        output_path = os.path.join(sfx_path, sfx_file)
        create_silent_audio_file(output_path, duration_seconds=0.5)
    
    # UI sounds
    ui_audio_path = os.path.join(base_path, 'audio', 'ui')
    ui_audio_files = [
        'button_click.wav', 'button_hover.wav', 'tab_switch.wav',
        'popup_open.wav', 'popup_close.wav', 'error.wav',
        'success.wav', 'typing.wav'
    ]
    
    for ui_audio_file in ui_audio_files:
        output_path = os.path.join(ui_audio_path, ui_audio_file)
        create_silent_audio_file(output_path, duration_seconds=0.3)
    
    # Ambient sounds
    ambient_path = os.path.join(base_path, 'audio', 'ambient')
    ambient_files = [
        'forest.mp3', 'cave.mp3', 'water.mp3', 'wind.mp3',
        'fire.mp3', 'rain.mp3', 'thunder.mp3'
    ]
    
    for ambient_file in ambient_files:
        output_path = os.path.join(ambient_path, ambient_file)
        create_silent_audio_file(output_path, duration_seconds=10.0)
    
    # Voice clips
    voice_path = os.path.join(base_path, 'audio', 'voice')
    voice_files = [
        'player_hurt.wav', 'player_attack.wav', 'npc_greeting.wav',
        'npc_goodbye.wav', 'narrator_intro.wav'
    ]
    
    for voice_file in voice_files:
        output_path = os.path.join(voice_path, voice_file)
        create_silent_audio_file(output_path, duration_seconds=2.0)
    
    print("\n=== Asset Generation Complete! ===")
    print("\nSummary:")
    print("- Enemy character sprites: Created")
    print("- UI elements: Created")
    print("- Luminara tilesets: Created")
    print("- Effects and particles: Created")
    print("- Props and collectibles: Created")
    print("- NPC sprites: Created")
    print("- Background layers: Created")
    print("- Audio files (silent): Created")
    print("\nAll placeholder assets have been generated!")
    print("You can now run the game without asset loading errors.")
    print("\nNext steps:")
    print("1. Test the game to ensure all assets load correctly")
    print("2. Gradually replace placeholders with final art assets")
    print("3. Follow the sprint schedule for asset completion")

if __name__ == "__main__":
    main()

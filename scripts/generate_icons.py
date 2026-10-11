#!/usr/bin/env python3
import math
import os
from PIL import Image, ImageDraw, ImageFilter

def create_master_icon(size=2048, transparent=False):
    # Supersampled high-resolution canvas
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx, cy = size // 2, size // 2
    r_outer = int(size * 0.44)

    if not transparent:
        # Draw rich cinematic dark background
        bg_radius = int(size * 0.22)
        # Gradient background
        for y in range(size):
            factor = y / size
            r = int(8 + (17 - 8) * factor)
            g = int(11 + (25 - 11) * factor)
            b = int(16 + (35 - 16) * factor)
            draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

        # Radial center glow
        glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        gdraw = ImageDraw.Draw(glow)
        for i in range(120, 0, -2):
            rad = int(size * 0.45 * (i / 120))
            alpha = int(35 * (1 - i / 120))
            gdraw.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], fill=(20, 36, 56, alpha))
        img = Image.alpha_composite(img, glow)
        draw = ImageDraw.Draw(img)

    # Filmstrip Aperture Guide Rings
    for step in range(0, 360, 15):
        angle = math.radians(step)
        x1 = cx + int((r_outer * 0.92) * math.cos(angle))
        y1 = cy + int((r_outer * 0.92) * math.sin(angle))
        x2 = cx + int((r_outer * 0.98) * math.cos(angle))
        y2 = cy + int((r_outer * 0.98) * math.sin(angle))
        draw.line([(x1, y1), (x2, y2)], fill=(38, 51, 65, 180), width=int(size * 0.006))

    # Cyan Arc (West & South) - Filmstrip ribbon
    cyan_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    cdraw = ImageDraw.Draw(cyan_layer)
    cyan_points = []
    # Outer sweep
    for a in range(130, 310, 2):
        rad = math.radians(a)
        r = r_outer * (0.88 + 0.08 * math.sin(math.radians((a - 130) * 1.5)))
        cyan_points.append((cx + int(r * math.cos(rad)), cy + int(r * math.sin(rad))))
    # Inner sweep
    for a in range(308, 128, -2):
        rad = math.radians(a)
        r = r_outer * (0.58 + 0.12 * math.cos(math.radians((a - 130) * 1.2)))
        cyan_points.append((cx + int(r * math.cos(rad)), cy + int(r * math.sin(rad))))
    cdraw.polygon(cyan_points, fill=(0, 217, 255, 235))

    # Saffron Arc (East & North) - Filmstrip ribbon
    saffron_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(saffron_layer)
    saffron_points = []
    # Outer sweep
    for a in range(310, 490, 2):
        rad = math.radians(a)
        r = r_outer * (0.88 + 0.08 * math.sin(math.radians((a - 310) * 1.5)))
        saffron_points.append((cx + int(r * math.cos(rad)), cy + int(r * math.sin(rad))))
    # Inner sweep
    for a in range(488, 308, -2):
        rad = math.radians(a)
        r = r_outer * (0.58 + 0.12 * math.cos(math.radians((a - 310) * 1.2)))
        saffron_points.append((cx + int(r * math.cos(rad)), cy + int(r * math.sin(rad))))
    sdraw.polygon(saffron_points, fill=(255, 122, 0, 245))

    # Punch filmstrip sprocket perforations
    sprocket_bg = (8, 11, 16, 255) if not transparent else (0, 0, 0, 0)
    for a in range(145, 290, 24):
        rad = math.radians(a)
        sp_r = r_outer * 0.78
        sx = cx + int(sp_r * math.cos(rad))
        sy = cy + int(sp_r * math.sin(rad))
        w = int(size * 0.02)
        h = int(size * 0.038)
        cdraw.rounded_rectangle([sx - w, sy - h, sx + w, sy + h], radius=int(size * 0.006), fill=sprocket_bg)

    for a in range(325, 470, 24):
        rad = math.radians(a)
        sp_r = r_outer * 0.78
        sx = cx + int(sp_r * math.cos(rad))
        sy = cy + int(sp_r * math.sin(rad))
        w = int(size * 0.02)
        h = int(size * 0.038)
        sdraw.rounded_rectangle([sx - w, sy - h, sx + w, sy + h], radius=int(size * 0.006), fill=sprocket_bg)

    img = Image.alpha_composite(img, cyan_layer)
    img = Image.alpha_composite(img, saffron_layer)
    draw = ImageDraw.Draw(img)

    # Center Play Prismatic Crest Triangle
    play_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pdraw = ImageDraw.Draw(play_layer)

    p_size = int(size * 0.26)
    offset_x = int(size * 0.04)

    p1 = (cx - int(p_size * 0.7) + offset_x, cy - p_size) # top-left
    p2 = (cx + int(p_size * 0.95) + offset_x, cy)         # apex forward
    p3 = (cx - int(p_size * 0.7) + offset_x, cy + p_size) # bottom-left

    # Subtle drop shadow behind play crest
    s_offset = int(size * 0.015)
    pdraw.polygon([(p1[0]+s_offset, p1[1]+s_offset), (p2[0]+s_offset, p2[1]+s_offset), (p3[0]+s_offset, p3[1]+s_offset)], fill=(0, 0, 0, 140))

    # Gradient faceted play glyph
    # Top facet (Gold to Saffron)
    pdraw.polygon([p1, p2, (cx - int(p_size * 0.1) + offset_x, cy)], fill=(255, 200, 87, 255))
    # Bottom facet (Saffron to Electric Cyan blend)
    pdraw.polygon([(cx - int(p_size * 0.1) + offset_x, cy), p2, p3], fill=(255, 122, 0, 255))
    # Left facet highlight
    pdraw.polygon([p1, (cx - int(p_size * 0.1) + offset_x, cy), p3], fill=(255, 230, 140, 255))

    # Specular white beam on edge
    pdraw.line([p1, p2], fill=(255, 255, 255, 220), width=int(size * 0.01))

    img = Image.alpha_composite(img, play_layer)
    draw = ImageDraw.Draw(img)

    # Lens optical flare pinpoint
    flare_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    fdraw = ImageDraw.Draw(flare_layer)
    fx = cx + int(size * 0.06)
    fy = cy - int(size * 0.02)
    frad = int(size * 0.05)
    fdraw.ellipse([fx - frad, fy - frad, fx + frad, fy + frad], fill=(255, 255, 255, 160))
    flare_layer = flare_layer.filter(ImageFilter.GaussianBlur(int(size * 0.02)))
    img = Image.alpha_composite(img, flare_layer)

    return img

def main():
    os.makedirs("assets/branding", exist_ok=True)
    os.makedirs("assets/icons", exist_ok=True)
    os.makedirs("assets/splash", exist_ok=True)

    print("Generating master 2048 icon...")
    master = create_master_icon(size=2048, transparent=False)

    print("Saving assets/icons/app_icon_1024.png...")
    icon1024 = master.resize((1024, 1024), Image.Resampling.LANCZOS)
    icon1024.save("assets/icons/app_icon_1024.png", "PNG")

    print("Saving assets/icons/app_icon_512.png...")
    icon512 = master.resize((512, 512), Image.Resampling.LANCZOS)
    icon512.save("assets/icons/app_icon_512.png", "PNG")

    print("Generating transparent logo mark...")
    transparent_master = create_master_icon(size=2048, transparent=True)
    trans512 = transparent_master.resize((512, 512), Image.Resampling.LANCZOS)
    trans512.save("assets/branding/logo_transparent.png", "PNG")

    # Android Launcher Mipmaps
    android_res = "apps/mobile/android/app/src/main/res"
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, px in android_sizes.items():
        out_dir = os.path.join(android_res, folder)
        os.makedirs(out_dir, exist_ok=True)
        scaled = master.resize((px, px), Image.Resampling.LANCZOS)
        scaled.save(os.path.join(out_dir, "ic_launcher.png"), "PNG")
        print(f"Generated Android {folder}/ic_launcher.png ({px}x{px})")

    # iOS AppIcon assets
    ios_icon_dir = "apps/mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(ios_icon_dir, exist_ok=True)
    ios_sizes = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    for filename, px in ios_sizes.items():
        scaled = master.resize((px, px), Image.Resampling.LANCZOS)
        scaled.save(os.path.join(ios_icon_dir, filename), "PNG")
        print(f"Generated iOS {filename} ({px}x{px})")

    # Also save to assets/splash/splash_logo.png
    splash_logo = trans512
    splash_logo.save("assets/splash/splash_logo.png", "PNG")
    print("Generated assets/splash/splash_logo.png")

if __name__ == "__main__":
    main()

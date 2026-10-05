import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import arabic_reshaper
from bidi.algorithm import get_display

def reshape_text(text):
    reshaped = arabic_reshaper.reshape(text)
    return get_display(reshaped)

def create_gradient_bg(width, height, color1, color2, color3, accent_circle_color=None):
    # Base image
    img = Image.new("RGBA", (width, height), color1)
    draw = ImageDraw.Draw(img)
    
    # Linear gradient
    for y in range(height):
        p = y / height
        if p < 0.5:
            # color1 to color2
            sub_p = p / 0.5
            r = int(color1[0] + (color2[0] - color1[0]) * sub_p)
            g = int(color1[1] + (color2[1] - color1[1]) * sub_p)
            b = int(color1[2] + (color2[2] - color1[2]) * sub_p)
        else:
            # color2 to color3
            sub_p = (p - 0.5) / 0.5
            r = int(color2[0] + (color3[0] - color2[0]) * sub_p)
            g = int(color2[1] + (color3[1] - color2[1]) * sub_p)
            b = int(color2[2] + (color3[2] - color2[2]) * sub_p)
        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))
        
    # Add ambient glow
    glow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    if accent_circle_color:
        glow_draw.ellipse([width//2 - 400, 300 - 400, width//2 + 400, 300 + 400], fill=accent_circle_color)
        glow = glow.filter(ImageFilter.GaussianBlur(120))
        img = Image.alpha_composite(img, glow)
        
    return img

def render_device_frame(screen_img_path, target_w=980, corner_radius=70):
    raw_screen = Image.open(screen_img_path).convert("RGBA")
    
    # Crop out the Android status bar (top ~70px on a 720p screen) to look clean
    # and crop bottom navbar padding if any
    w, h = raw_screen.size
    crop_top = int(h * 0.045)  # remove status bar
    crop_bottom = int(h * 0.01)
    cropped_screen = raw_screen.crop((0, crop_top, w, h - crop_bottom))
    
    # Calculate aspect ratio
    aspect = cropped_screen.height / cropped_screen.width
    target_h = int(target_w * aspect)
    screen_resized = cropped_screen.resize((target_w, target_h), Image.Resampling.LANCZOS)
    
    # Rounded corners for screen
    mask = Image.new("L", (target_w, target_h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, target_w, target_h], radius=corner_radius, fill=255)
    
    screen_rounded = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    screen_rounded.paste(screen_resized, (0, 0), mask=mask)
    
    # Phone frame with bezel
    bezel = 16
    frame_w = target_w + bezel * 2
    frame_h = target_h + bezel * 2
    
    # Outer frame
    frame = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
    frame_draw = ImageDraw.Draw(frame)
    
    # Outer dark titanium border
    frame_draw.rounded_rectangle(
        [0, 0, frame_w, frame_h], 
        radius=corner_radius + bezel, 
        fill=(25, 30, 42, 255), 
        outline=(80, 100, 140, 255), 
        width=4
    )
    
    # Inner border
    frame_draw.rounded_rectangle(
        [bezel - 2, bezel - 2, frame_w - bezel + 2, frame_h - bezel + 2], 
        radius=corner_radius + 2, 
        fill=(10, 12, 18, 255)
    )
    
    # Paste screen inside
    frame.paste(screen_rounded, (bezel, bezel), mask=screen_rounded)
    
    # Add shadow
    shadow_pad = 80
    shadow_img = Image.new("RGBA", (frame_w + shadow_pad * 2, frame_h + shadow_pad * 2), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_img)
    shadow_draw.rounded_rectangle(
        [shadow_pad, shadow_pad + 20, shadow_pad + frame_w, shadow_pad + frame_h + 20],
        radius=corner_radius + bezel,
        fill=(0, 0, 0, 160)
    )
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(35))
    shadow_img.paste(frame, (shadow_pad, shadow_pad), mask=frame)
    
    return shadow_img

def generate_screenshots():
    out_dir = r"d:\M\met1\app_store_screenshots"
    os.makedirs(out_dir, exist_ok=True)
    
    scratch_dir = r"C:\Users\DELL 3561 G11\.gemini\antigravity-ide\brain\7d7eaeda-2071-4fd4-8e61-0c9c9c3fb019\scratch"
    
    title_font_path = r"C:\Windows\Fonts\arialbd.ttf"
    sub_font_path = r"C:\Windows\Fonts\arial.ttf"
    
    title_font = ImageFont.truetype(title_font_path, 86)
    sub_font = ImageFont.truetype(sub_font_path, 44)
    badge_font = ImageFont.truetype(title_font_path, 34)

    configs = [
        {
            "screen": "ss1_real_schedule.png",
            "badge": "MET BIS & CS",
            "title": "جدولك الدراسي الذكي",
            "sub": "محاضراتك وسكاشنك منظمة بمواعيدها وقاعاتها",
            "bg": ((6, 12, 28), (14, 28, 62), (24, 48, 98)),
            "glow": (30, 80, 200, 70),
            "name": "1_smart_schedule"
        },
        {
            "screen": "ss2.png",
            "badge": "متابعة مستمرة",
            "title": "تتبع موعدك القادم",
            "sub": "معرفة المحاضرة القادمة فوراً وحصيلة إنجاز اليوم",
            "bg": ((10, 8, 30), (22, 16, 68), (38, 28, 110)),
            "glow": (120, 50, 220, 60),
            "name": "2_upcoming_class"
        },
        {
            "screen": "ss1.png",
            "badge": "تخصيص متقدم",
            "title": "تخصيص كامل وتحكم بالثيم",
            "sub": "الوضع الليلي، تغيير السكشن، والتنبيهات الذكية",
            "bg": ((4, 18, 28), (10, 42, 62), (18, 70, 102)),
            "glow": (0, 170, 210, 60),
            "name": "3_settings_customization"
        },
        {
            "screen": "ss4.png",
            "badge": "أدوات جامعية",
            "title": "خدمات وأدوات متكاملة",
            "sub": "دليل المباني، تتبع الحضور والغياب، وروابط المنصات",
            "bg": ((18, 6, 32), (38, 14, 68), (62, 24, 108)),
            "glow": (180, 40, 160, 60),
            "name": "4_student_tools"
        },
        {
            "screen": "ss5.png",
            "badge": "مشروع التخرج",
            "title": "متابعة وإدارة مشروع التخرج",
            "sub": "تنظيم مهام الفريق ومستندات وروابط المشروع بسهولة",
            "bg": ((8, 14, 26), (18, 34, 58), (30, 56, 92)),
            "glow": (40, 130, 220, 60),
            "name": "5_graduation_project"
        }
    ]
    
    # Exact required sizes by App Store:
    # 6.5" Display: 1284 x 2778 px and 1242 x 2688 px
    # 6.7" Display: 1290 x 2796 px
    
    target_sizes = [
        ("6.5_1284x2778", 1284, 2778),
        ("6.5_1242x2688", 1242, 2688),
        ("6.7_1290x2796", 1290, 2796),
    ]
    
    for size_label, w, h in target_sizes:
        size_dir = os.path.join(out_dir, size_label)
        os.makedirs(size_dir, exist_ok=True)
        print(f"\n--- Generating for size: {size_label} ({w}x{h}) ---")
        
        for idx, cfg in enumerate(configs, 1):
            # 1. Background
            canvas = create_gradient_bg(w, h, cfg["bg"][0], cfg["bg"][1], cfg["bg"][2], cfg["glow"])
            draw = ImageDraw.Draw(canvas)
            
            # 2. Top Pill / Badge
            b_text = reshape_text(cfg["badge"])
            b_bbox = badge_font.getbbox(b_text)
            b_w = b_bbox[2] - b_bbox[0]
            b_h = b_bbox[3] - b_bbox[1]
            
            pill_w = b_w + 60
            pill_h = b_h + 30
            pill_x = (w - pill_w) // 2
            pill_y = int(h * 0.055)
            
            draw.rounded_rectangle(
                [pill_x, pill_y, pill_x + pill_w, pill_y + pill_h],
                radius=pill_h // 2,
                fill=(255, 255, 255, 25),
                outline=(255, 255, 255, 70),
                width=2
            )
            draw.text(((w - b_w) // 2, pill_y + 12), b_text, font=badge_font, fill=(180, 220, 255, 255))
            
            # 3. Main Title
            t_text = reshape_text(cfg["title"])
            t_bbox = title_font.getbbox(t_text)
            t_w = t_bbox[2] - t_bbox[0]
            draw.text(((w - t_w) // 2, pill_y + pill_h + 45), t_text, font=title_font, fill=(255, 255, 255, 255))
            
            # 4. Subtitle
            s_text = reshape_text(cfg["sub"])
            s_bbox = sub_font.getbbox(s_text)
            s_w = s_bbox[2] - s_bbox[0]
            draw.text(((w - s_w) // 2, pill_y + pill_h + 155), s_text, font=sub_font, fill=(200, 215, 235, 230))
            
            # 5. Render Device Mockup
            screen_file = os.path.join(scratch_dir, cfg["screen"])
            mockup_w = int(w * 0.76)
            device_img = render_device_frame(screen_file, target_w=mockup_w, corner_radius=65)
            
            # Position device mockup
            dev_x = (w - device_img.width) // 2
            dev_y = pill_y + pill_h + 250
            
            canvas.paste(device_img, (dev_x, dev_y), mask=device_img)
            
            # Save output
            final_rgb = canvas.convert("RGB")
            out_filename = f"{cfg['name']}.png"
            out_path = os.path.join(size_dir, out_filename)
            final_rgb.save(out_path, "PNG", quality=100)
            
            # Also save the 1284x2778 directly to main folder for easy drag and drop
            if size_label == "6.5_1284x2778":
                main_out_path = os.path.join(out_dir, out_filename)
                final_rgb.save(main_out_path, "PNG", quality=100)
                
            print(f"[{size_label}] Saved {out_filename} -> {final_rgb.size[0]}x{final_rgb.size[1]} px")

if __name__ == "__main__":
    generate_screenshots()

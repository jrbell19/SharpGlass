import sys
from PIL import Image, ImageDraw, ImageOps

def create_rounded_icon(input_path, output_path, corner_radius_ratio=0.22):
    try:
        # Open source image
        img = Image.open(input_path).convert("RGBA")
        
        # macOS squircle-ish rounded corners
        # Create mask
        mask = Image.new('L', img.size, 0)
        draw = ImageDraw.Draw(mask)
        
        w, h = img.size
        # Standard rounded rect for now (approximating macOS squircle)
        radius = min(w, h) * corner_radius_ratio
        draw.rounded_rectangle([(0, 0), (w, h)], radius=radius, fill=255)
        
        # Apply mask
        output = ImageOps.fit(img, mask.size, centering=(0.5, 0.5))
        output.putalpha(mask)
        
        # Save high-res master
        output.save(output_path, "PNG")
        print(f"Created processed icon at {output_path}")
        
    except Exception as e:
        print(f"Error processing image: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 process_icon.py <input> <output>")
        sys.exit(1)
    
    create_rounded_icon(sys.argv[1], sys.argv[2])

import sys
from PIL import Image

def resize_icon(input_path, output_dir):
    try:
        img = Image.open(input_path)
        sizes = [16, 32, 64, 128, 256, 512]
        
        for s in sizes:
            # 1x
            out_1x = img.resize((s, s), Image.Resampling.LANCZOS)
            out_1x.save(f"{output_dir}/icon_{s}x{s}.png")
            
            # 2x
            s2 = s * 2
            out_2x = img.resize((s2, s2), Image.Resampling.LANCZOS)
            out_2x.save(f"{output_dir}/icon_{s}x{s}@2x.png")
            
        print("Resized all icons.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    resize_icon(sys.argv[1], sys.argv[2])


import os
import glob
from PIL import Image

# Configuration
UNUSED_FILES = [
    r'assets\images\estrella.png',
    r'assets\images\Imagen1.png',
    r'assets\images\Imagen2.png',
    r'assets\images\doctor.png',
    r'assets\images\edicionPerfil.png',
    r'assets\images\engranaje.png',
    r'assets\images\prueba.png',
    r'assets\images\womanbaby1.png',
    r'assets\images\iluminacion_reparacion.jpeg'
]

OPTIMIZATION_RULES = [
    {
        'dir': r'assets\mini_videos',
        'max_width': 500,
        'quality': 85
    },
    {
        'dir': r'assets\images\badges',
        'max_width': 256,
        'quality': 85
    },
    {
        'dir': r'assets\tips',
        'max_width': 800,
        'quality': 85
    },
    {
        'dir': r'assets\images', # Root images (careful not to process subdirs again recursively unless wanted)
        'max_width': 800,
        'quality': 85,
        'recursive': False
    }
]

def delete_files():
    print("Deleting unused files...")
    for rel_path in UNUSED_FILES:
        # Construct absolute path carefully or use relative
        # Assuming script runs from root
        full_path = os.path.abspath(rel_path)
        if os.path.exists(full_path):
            try:
                os.remove(full_path)
                print(f"   Deleted: {rel_path}")
            except Exception as e:
                print(f"   Error deleting {rel_path}: {e}")
        else:
            print(f"   Not found (already deleted?): {rel_path}")

def optimize_images():
    print("\nOptimizing images...")
    
    total_saved = 0
    
    for rule in OPTIMIZATION_RULES:
        directory = os.path.abspath(rule['dir'])
        if not os.path.exists(directory):
            print(f"   Skipping missing directory: {directory}")
            continue
            
        print(f"   Processing directory: {rule['dir']} (Max Width: {rule['max_width']}px)")
        
        # Get files
        files = []
        if rule.get('recursive', False):
             for root, dirs, filenames in os.walk(directory):
                for f in filenames:
                    if f.lower().endswith(('.png', '.jpg', '.jpeg', '.webp')):
                        files.append(os.path.join(root, f))
        else:
            # Non-recursive, just files in this dir
            for f in os.listdir(directory):
                full_path = os.path.join(directory, f)
                if os.path.isfile(full_path) and f.lower().endswith(('.png', '.jpg', '.jpeg', '.webp')):
                    files.append(full_path)

        for img_path in files:
            try:
                original_size = os.path.getsize(img_path)
                
                with Image.open(img_path) as img:
                    # Skip if already small enough
                    should_resize = img.width > rule['max_width']
                    # Also optimize if it's large in bytes even if dims are small (re-save to compress)
                    # But for now let's strict to resize OR if it's > 500KB maybe?
                    # Let's simple stick to resize logic for safety, but force save for optimization
                    
                    if not should_resize:
                         # Just re-save for optimization?
                         # Only if original > 100KB to justify re-compression loss
                         if original_size < 100 * 1024:
                             continue

                    # Calculate new height
                    if should_resize:
                        ratio = rule['max_width'] / img.width
                        new_height = int(img.height * ratio)
                        img = img.resize((rule['max_width'], new_height), Image.Resampling.LANCZOS)
                    
                    # Save
                    # Optimize=True for PNG/JPG
                    img.save(img_path, optimize=True, quality=rule['quality'])
                
                new_size = os.path.getsize(img_path)
                saved = original_size - new_size
                if saved > 0:
                    total_saved += saved
                    print(f"     Optimized: {os.path.basename(img_path)} (Saved {saved/1024:.1f} KB)")
                    
            except Exception as e:
                print(f"     Error optimizing {os.path.basename(img_path)}: {e}")

    print(f"\nTotal space saved: {total_saved / (1024*1024):.2f} MB")

if __name__ == "__main__":
    delete_files()
    optimize_images()

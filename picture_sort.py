import os
import shutil
from tkinter import Tk, filedialog
#this program takes a file of pictures and organises them into 
#a file with multiple files containing only 4 pictures

def split_images_into_folders(source_folder, output_folder, batch_size=4):
    # Ensure output folder exists
    os.makedirs(output_folder, exist_ok=True)
    
    # Get list of image files sorted by name
    images = sorted([f for f in os.listdir(source_folder) if f.lower().endswith(('png', 'jpg', 'jpeg', 'bmp', 'gif','tiff'))])
    
    # Create subfolders and move images
    for i in range(0, len(images), batch_size):
        subfolder_name = os.path.join(output_folder, f'batch_{i // batch_size + 1}')
        os.makedirs(subfolder_name, exist_ok=True)
        
        for img in images[i:i + batch_size]:
            shutil.move(os.path.join(source_folder, img), os.path.join(subfolder_name, img))
        
    print(f"Processed {len(images)} images into {len(images) // batch_size + (1 if len(images) % batch_size else 0)} folders.")

# Let user select source folder
Tk().withdraw()  # Hide root window
source_folder = filedialog.askdirectory(title="Select the folder with images")
if not source_folder:
    print("No folder selected. Exiting.")
    exit()

output_folder = os.path.join(source_folder, "organized_images")
split_images_into_folders(source_folder, output_folder)

#this program will brows for the folder containing folders of the pictures than go through all the folders and 
#process the pictures the 4 by 4 before returning aopl matrixes with the batch names.
#This programm operates the same way piture_to_matrix does only it calculates the pixel coordinates differently
# and uses mm instead of pix
        
import os
import numpy as np
import matplotlib.pyplot as plt
import imageio.v2 as im
import tkinter as tk
from tkinter import filedialog
from scipy.io import savemat

# Open folder selection dialog
root = tk.Tk()
root.withdraw()  # Hide the main window
folder_path = filedialog.askdirectory(title="Select a folder containing images")

if not folder_path:
    print("No folder selected.")
    exit()

# Dictionary to store batch names and their corresponding images
batches_dict = {}
angles = {"-0": 0, "-45": 45, "-90": 90, "-135": 135}

# Walk through all subdirectories in the selected folder
for subfolder_path, _, files in os.walk(folder_path):
    batch_name = os.path.basename(os.path.normpath(subfolder_path))  # Extract batch name

    images_dict = {}
    for file in files:
        if file.lower().endswith(".tiff"):
            filename, ext = os.path.splitext(file)

            for suffix, angle in angles.items():
                if filename.endswith(suffix):  # Check if filename ends with "-0", "-45", etc.
                    images_dict[angle] = os.path.join(subfolder_path, file)
                    break  # Stop checking once a match is found

    # Store the batch only if it contains all 4 angles
    if set(images_dict.keys()) == {0, 45, 90, 135}:
        batches_dict[batch_name] = images_dict
    else:
        print(f"Skipping {batch_name}, missing images: {set(angles.values()) - set(images_dict.keys())}")

# Function to process images


save_dir = os.path.join(folder_path, "Processed_Matrices")
os.makedirs(save_dir, exist_ok=True) 


def process_images(I0, I45, I90, I135, batch_name):

    
# Load the images and convert them from uint8 to int64

    I0 = I0.astype(np.int64)
    I45 = I45.astype(np.int64)
    I90 = I90.astype(np.int64)
    I135 = I135.astype(np.int64)


# Stokes parameters
    S0 = (I0 + I45 + I90 + I135)/2 # Average value of total intensity
    S01 = I0 + I90 # Total intensity
    S02 = I45 + I135 # Total intensity
    S1 = I0 - I90 # Vector of polarization in 0-90
    S2 = I45 - I135 # Vector of polarization in 45-135

    Z_global = (S1 + 1j * S2)/S0 # Global Stokes parameters
    aopg=(1/2)*np.angle(S1+1j*S2) # Global Angle of Polarization arctan(S2/S1) returns division by 0

    dop = np.abs(Z_global) # Degree of Polarization
     
    



 # pixel elevation and azimuth section generation input variables
 
    fx= 10845.4425 * 2.74*(10**(-3)) # conversion from pix into mm
    fy= 10876.8867 * 2.74*(10**(-3))
    focal_length_mm=np.sqrt(fx**2+fy**2)

    height_pixels, width_pixels = I0.shape
    sensor_pixel_size_um = 2.74
    cx = 1206
    cy = 1657
 # pixel elevation and azimuth section generation
 

 # Convert focal length from mm to microns
    focal_length_um = focal_length_mm * 1000

    # Build centered coordinate grids (image center is origin)
    x_coords = np.linspace((width_pixels - 1) / 2, -(width_pixels - 1) / 2, width_pixels) + (cx-width_pixels/2)
    y_coords = np.linspace((height_pixels - 1) / 2, -(height_pixels - 1) / 2, height_pixels) + (cy - height_pixels/2)

    # Convert to micrometers
    x_um = x_coords * sensor_pixel_size_um
    y_um = y_coords * sensor_pixel_size_um

    # Meshgrid of coordinates
    X, Y = np.meshgrid(x_um, y_um)

    # Complex representation of sensor plane
    complex_plane = X + 1j * Y

    # Azimuth from complex argument
    azimuth_matrix = np.angle(complex_plane)

    # Elevation using perspective (r0): elevation = pi/2 - atan(r/F)
    radius = np.abs(complex_plane)
    elevation_matrix = (np.pi / 2) - np.arctan(radius / focal_length_um)

     #azimuth_matrix, elevation_matrix, x_coords, y_coords are returnes at the end of this section
    
    
    
    
    
    
    aopl = aopg - azimuth_matrix # Local Stokes Parameters
    
    
# **Save matrix for this batch**
    mat_filename = os.path.join(save_dir,f"matrices_{batch_name}.mat")  # Generate filename
    savemat(mat_filename, {'azimut': azimuth_matrix, 'elevation': elevation_matrix, 'aopl': aopl})
    print(f"Processed batch: {batch_name}, AoP matrix saved as {batch_name}_aopg.csv")



# Process each batch
for batch_name, images_dict in batches_dict.items():
    # Load images into respective variables
    I0 = im.imread(images_dict[0])
    I45 = im.imread(images_dict[45])
    I90 = im.imread(images_dict[90])
    I135 = im.imread(images_dict[135])

    process_images(I0, I45, I90, I135, batch_name)

    print(f"Loaded and processed images for batch: {batch_name}\n")

        


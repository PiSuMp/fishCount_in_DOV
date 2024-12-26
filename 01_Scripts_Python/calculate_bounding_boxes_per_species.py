import os
import csv
import re

#Function to extract the frame number - important for the chronology
def extract_number(file_path):
    # This regular expression looks for a number followed by ".txt"
    match = re.search(r'(\d+)\.txt$', file_path)
    
    if match:
        return int(match.group(1))  # Return the number found before ".txt"
    else:
        return None

#Function to count the species per frame
def process_yolo_label_file(file_path, currentClass):    
    with open(file_path, 'r') as file:
        lines = file.readlines()

    total_number_of_bb = 0
    for line in lines:
        parts = line.split()
        class_label = parts[0]

        if int(class_label) == int(currentClass):
            total_number_of_bb += 1

    return total_number_of_bb

#Function to extract the videoname to group frames per video
def extract_videoname(file_name):
    parts = file_name.split('_')
    return '_'.join(parts[:2]) if len(parts) >= 3 else parts[0]

#Function to sort the frames important to find 'empty' frame that YOLO doesn't account for
def natural_sort_key(s):
    return [int(part) if part.isdigit() else part for part in re.split(r'(\d+)', s)]

#The actual script
def main():
    path_to_folder = "[Directory of labels (predictions or groundtruth)]"
    output_file_path = "./03_Datasets/overall/boundingboxes_class"

    classes = list(range(0, 20))

    for k in range(0, len(classes)):
        #Workaround to be sure that we do not miss the initialisation frame 
        #Not the best way - improvement later on
        videonamePrevious = 'placeholder_for_first_video_1994'

        video_surface_areas = {}
        for root, dirs, files in os.walk(path_to_folder):
            # Sort files using natural sorting
            files.sort(key=natural_sort_key)
            for file_name in files:
                if file_name.endswith(".txt"):
                    videoname = extract_videoname(file_name)

                    #Initialisation - set counter to 1
                    if videonamePrevious == 'placeholder_for_first_video_1994':
                        videonamePrevious = videoname

                        file_path = os.path.join(root, file_name)
                        videoFrame = extract_number(file_path)

                        #Create counter for empty/non-existing files
                        counter = 1

                        while videoFrame > counter:
                            if videoname not in video_surface_areas:
                                video_surface_areas[videoname] = []  

                            video_surface_areas[videoname].append(0)
                            counter = counter + 1

                        surface_area = process_yolo_label_file(file_path, k)

                        if videoname not in video_surface_areas:
                            video_surface_areas[videoname] = []

                        video_surface_areas[videoname].append(surface_area)

                        counter = counter + 1 

                    #If there is no new video - do not reset counter
                    elif videoname == videonamePrevious:
                        file_path = os.path.join(root, file_name)
                        videoFrame = extract_number(file_path)

                        while videoFrame > counter:
                            if videoname not in video_surface_areas:
                                video_surface_areas[videoname] = []  

                            video_surface_areas[videoname].append(0)
                            counter = counter + 1

                        surface_area = process_yolo_label_file(file_path, k)

                        if videoname not in video_surface_areas:
                            video_surface_areas[videoname] = []

                        video_surface_areas[videoname].append(surface_area)

                        counter = counter + 1                                                         

                    #If there is a new video starting - reset counter to 1
                    elif videoname != videonamePrevious:
                        videonamePrevious = videoname
                        file_path = os.path.join(root, file_name)
                        videoFrame = extract_number(file_path)

                        #Create counter for empty/non-existing files
                        counter = 1

                        while videoFrame > counter:
                            if videoname not in video_surface_areas:
                                video_surface_areas[videoname] = []  

                            video_surface_areas[videoname].append(0)
                            counter = counter + 1

                        surface_area = process_yolo_label_file(file_path, k)

                        if videoname not in video_surface_areas:
                            video_surface_areas[videoname] = []

                        video_surface_areas[videoname].append(surface_area)

                        counter = counter + 1 

        # Writing to the CSV file
        with open((output_file_path + str(k) + '.csv'), 'w', newline='') as output_file:
            csv_writer = csv.writer(output_file)
            header = ["videoname"] + [f"frame_{i}" for i in range(1, max(len(sa) for sa in video_surface_areas.values()) + 1)]
            csv_writer.writerow(header)

            for videoname, surface_areas in video_surface_areas.items():
                row = [videoname] + surface_areas + [None] * (len(header) - 1 - len(surface_areas))
                csv_writer.writerow(row)
        print('Class ' + str(k) + ' done!')

    print(f"Boundingbox number calculation completed. Results saved in {output_file_path}.")

if __name__ == "__main__":
    main()

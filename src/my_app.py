'''
 Copyright (C) 2025  Fabian Huck

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 sketcher is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''
from datetime import datetime
import os

import json  # for svg to json function

def find_all_svg(folderpath):
    retlist = []
    for file in os.listdir(folderpath):
        # check the files which are end with specific extension
        if file.endswith(".svg"):
            # print path name of selected files
            print("found saved file %s" % file)
            retlist.append(file)
    return retlist


def getfilename(fullpath):
    try:
        return os.path.basename(fullpath)
    except Exception as ex:
        return str(ex)
    
def get_script_path():
    file_path = os.path.realpath(__file__)
    dir_path = os.path.dirname(file_path)
    return dir_path

def get_import_path():
    file_path = os.path.realpath(__file__)
    dir_path = os.path.dirname(file_path)
    import_path = os.path.join(dir_path.replace("src", "www"), "imported")
    return import_path

def make_file():
    with open('readme.txt', 'w') as f:
        f.write('Create a new text file!')
    return True

def save_svg_to_file(dirpath, svgtext):
    now = datetime.now()
    time_string = now.strftime("%H_%M_%S")
    fname = "sketcher_image_" + time_string + ".svg"
    fullexportpath = os.path.join(dirpath, fname)
    fullexportpath = fullexportpath.replace("file://", "")
    with open(fullexportpath, "w") as text_file:
        text_file.write(svgtext)
    return os.path.abspath(fullexportpath)


def clean_path(inpath):
    outpath = inpath.replace("file://", "").rstrip()
    return outpath


def make_dir(abspath, foldername):
    if "file:" in abspath:
        abspath = abspath.replace("file://", "")
    new_dir_path = os.path.join(abspath, foldername)
    if os.path.isdir(new_dir_path):
        return ("make_dir: Folder already exists: " + new_dir_path)
    try:
        os.mkdir(new_dir_path)
        return new_dir_path
    except Exception as e:
        print(f"An error occurred: {e}")
        return str(e)


# Example usage:
# svg_folder_to_json('path/to/svg/folder', 'output_svgs.json')
# str_ext: .svg, .png
def icon_folder_to_json(folder_path, str_ext):
    folder_path = clean_path(folder_path)
    icons = []
    log = []
    if not os.path.isdir(folder_path):
        print("icon_folder_to_json: Folder does not exist: " + folder_path)
        log.append("icon_folder_to_json: Folder does not exist: " + folder_path)
        return {"log": log, "json_data": {}}
    
    for filename in os.listdir(folder_path):
        print("  icon_folder_to_json: processing " + filename)
        log.append("  icon_folder_to_json: processing " + filename)
        if filename.lower().endswith(str_ext):
            file_path = os.path.join(folder_path, filename)
            print("  icon_folder_to_json: " + file_path)
            # log.append("  icon_folder_to_json: " + file_path)

            icon_id = os.path.splitext(filename)[0]
            new_icon = {
                "id": icon_id,
                "description": "",  # You can customize or extract description if needed
            }

            if "svg" in str_ext:
                with open(file_path, 'r', encoding='utf-8') as icon_file:
                    icon_content = icon_file.read().strip()
                    new_icon[str_ext.replace(".", "")] = icon_content

            icons.append(new_icon)

    json_data = {str_ext.replace(".", "") + "_list": icons}
    #log.append(" JSON_Data: " + str(svgs))

    outpath = str_ext.replace(".", "") + "_bundled.json"
    if not os.path.isfile(outpath):
        with open(outpath, 'w', encoding='utf-8') as json_file:
            json.dump(json_data, json_file, indent=2, ensure_ascii=False)

        print(f"JSON file created at: {outpath}")
        log.append("  JSON file created at: " + outpath)
    return {"log": log, "json_data": json_data}





if __name__ == '__main__':
    print("main function of python script")
    icon_folder_to_json(r"/home/fabian/Documents/Programmierung/UbuntuTouchProjects/Sketcher/sketcher/www/emoji", ".png")
    

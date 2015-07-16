# KIG
## K Image Gallery tool Installation and Usage

KIG is a Windows command line tool.

KIG makes the HTML code for you and also resizes the file to both thumbnail and full size. It uses a full installation of Irfanview for image processing. All three styles are supported. However if your files are not in the 1024x768 proportion then the Style 3 Full size should be done in FastStone Photo Resizer by specifing style 0 (zero). This one option only makes use of FastStone Photo Resizer.

### How to use
Open a command prompt at the folder where the gallery photos resides on your computer. (To open a command prompt at the folder, select the folder with the mouse, then hold down shift and right mouse click and select Open command window here.)

#### Option 1 type just `kig` and press *[enter]*

Type in `kig` in the command window and answer the question prompts.

##### Example: Sample of output from typing `kig`
---
````
C:\images-for-gallery>kig

Making HTML and resized photos and thumbnails for K Image gallery.

usage with parameters: kig iso_site_code gallery_id style_number [site_number]

You must specify a Project code.
Enter Project code: xxx
How do you want to distinguish this gallery from other galleries?
Gallery name or code: river
What style do you want for the pictures?
Choose theme number 1 or 2 or 3 or 0 for use with FastStone. Blank = 1: 1
What is the project number?
Enter number or leave blank for site code: 44
----- make large size and thumb with no borders -----
made gallery-river_01.jpg and gallery-river_01_thumb.jpg
made gallery-river_02.jpg and gallery-river_02_thumb.jpg
made gallery-river_03.jpg and gallery-river_03_thumb.jpg
made gallery-river_04.jpg and gallery-river_04_thumb.jpg
Finished!
````
---

#### Option 2 type in all parameters `kig xxx river 1 444`

The full command line `kig` `iso_site_code` `gallery_id` `style_number` [`site_number`] and annotated below. 
- **kig** is the program name,
- **xxx** is the site code often the ISO code,
- **1** is the style type
- **444** is the site number associated with the iso_site_code


##### Example: Command line with all parameters
---
```
kig xxx artifacts 1 222
```
---
The above example is where you know the site_number.

If you have the `site-lookup.txt` file in the `c:\ProgramData\kig` folder with the relevant data in (a line with `xxx=444`), you do not need the fourth parameter.

##### Example: Command line with three parameters (preferred)
---
```
kig ify artifacts 1
```
---

The resized files are named:
gallery-gallery_id_01.jpg and gallery-gallery_id_01_thumb.jpg

##### Example: Output from typing the three parameter command line
---
```
C:\images-for-gallery>kig xxx river 1

Making HTML and resized photos and thumbnails for K Image gallery.

Site number for xxx set to: 444
----- make large size and thumb with no borders -----
made gallery-river_01.jpg and gallery-river_01_thumb.jpg
made gallery-river_02.jpg and gallery-river_02_thumb.jpg
made gallery-river_03.jpg and gallery-river_03_thumb.jpg
made gallery-river_04.jpg and gallery-river_04_thumb.jpg
Finished!
```
---



All JPG output is created in a subfolder called readytoupload. The HTML file html.txt is opened in notepad. That file is in the same folder as the source files.

##### Example: The output HTML for four input files
---
```
<script type="text/javascript" src="/sites/default/files/media/44/imageGallery.js"></script> 
<p>About these photos</p> 
<div class="image-gallery"> 
<a  
href="/sites/default/files/media/xxx/gallery-river_01.jpg"><img alt="" 
src="/sites/default/files/media/xxx/gallery-river_01_thumb.jpg" style="width: 215px; height: 162px !important;" 
/></a>&nbsp;<a  
href="/sites/default/files/media/xxx/gallery-river_02.jpg"><img alt="" 
src="/sites/default/files/media/xxx/gallery-river_02_thumb.jpg" style="width: 215px; height: 162px !important;" 
/></a>&nbsp;<a  
href="/sites/default/files/media/xxx/gallery-river_03.jpg"><img alt="" 
src="/sites/default/files/media/xxx/gallery-river_03_thumb.jpg" style="width: 215px; height: 162px !important;" 
/></a>&nbsp;<a  
href="/sites/default/files/media/xxx/gallery-river_04.jpg"><img alt="" 
src="/sites/default/files/media/xxx/gallery-river_04_thumb.jpg" style="width: 215px; height: 162px !important;" 
/></a>&nbsp; 
</div> 
```
---


### Installation
Installation notes for install-kig.cmd
Unzip the ImageGallery.zip
Right click on the install-kig.cmd file and select "Run as administrator"

![Run as Administrator](/photos/RunAsAdmin.GIF)

Click Yes to the User Account Control.

![Run as Administrator](/photos/UserAccountControl.GIF)

If you have Irfanview and FastStone Photo Resizer installed, it should finish with no warning messages. 
Without Irfanview the HTML will still be generated but no files resized. While FastStone Photo Resizer is only used in style 0.


### Reinstallation
Simply rerun the installer by double clicking the installer. Reinstall does not need the "Run as Administrator" option.

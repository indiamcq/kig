# KIG  version 3
## K Image Gallery tool [Installation](#instal) and [Usage](#usage)

KIG is a Windows command line tool.

KIG makes the HTML code for you and also resizes the file to both thumbnail and full size. It uses a full installation of ImageMagic for image processing. It has 8 built in styles but can be extended with may more styles. 

### <a name="usage"></a>How to use
Open a command prompt at the folder where the gallery photos resides on your computer. (To open a command prompt at the folder, select the folder with the mouse, then hold down shift and right mouse click and select **Open command window here.**)

#### Option 1 type just `kig` and press *[enter]*

Type in `kig` in the command window and answer the question prompts.

##### Example: Sample of output from typing `kig`
---
````
C:\images-for-gallery>kig

Making HTML and resized photos and thumbnails for K Image gallery.

Usage with parameters: kig iso_site_code gallery_id style_number [border_color]

You must specify a Project code.
Enter Project code: **xxx**
How do you want to distinguish this gallery from other galleries?
Gallery name or code: **river**
Available style numbers and description:
1 no border
2 solid border
3 innerbevel border
4 embossed border
5 rainbow border
6 fuzzed-edge border
7 raised-bevel border
8 sunken-bevel border

          Note: Enter only numbers.
What style do you want for the pictures?
Choose theme number from the list above Blank = 1: **1**
What is the project number?
Enter number or leave blank for site code: 44
========== Making HTML fragment ===============================================
========== Making JPG_thumb files with solid white border =====================
made g1\gallery-g1_01_thumb.jpg
made g1\gallery-g1_02_thumb.jpg
========== Making JPG files with solid white border ===========================
made g1\gallery-g1_01.jpg
made g1\gallery-g1_02.jpg
Finished!
````
---

#### Option 2 type in all parameters `kig xxx river 1 red`

The full command line `kig` `iso_site_code` `gallery_id` `style_number` [`site_number` or `m` or `p`] and annotated below. 
- **kig** is the program name,
- **xxx** is the site code often the ISO code,
- **1** is the style type
- **red** is the color you want different to the default


##### Example: Command line with all parameters
---
```
kig xxx artifacts 1 red
```
---


##### Example: Command line with three parameters (preferred)
---
```
kig ify artifacts 1
```
---

The resized files are named:
`gallery-gallery_id_01.jpg` and `gallery-gallery_id_01_thumb.jpg`

##### Example: Output from typing the three parameter command line
---
```
C:\path\sample>kig xxx river 1

   Making HTML and resized photos and thumbnails for K Image gallery.
                              v3
        Available from: https://github.com/indiamcq/kig

========== Making HTML fragment ===============================================
========== Making JPG_thumb files with solid white border =====================
made g1\gallery-g1_01_thumb.jpg
made g1\gallery-g1_02_thumb.jpg
========== Making JPG files with solid white border ===========================
```
---



All JPG output is created in a subfolder called gallery\river. The HTML file html.txt is also in the same folder and opened in notepad. 

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


### <a name="instal"></a>Installation using install-kig.cmd

1. Download the trunk.zip file from [here](https://github.com/indiamcq/kig/archive/master.zip) or on the right hand side of  this page https://github.com/indiamcq/kig
2. Unzip the trunk.zip
3. Right click on the install-kig.cmd file and select "Run as administrator"

  ![Run as Administrator](/photos/RunAsAdmin.GIF)

4. Click Yes to the User Account Control.

  ![Run as Administrator](/photos/UserAccountControl.GIF)

You need to instal ImageMagic. 
Without Irfanview the HTML will still be generated but no files resized. While FastStone Photo Resizer is only used in style 0.


### Reinstallation
Simply rerun the installer by double clicking the installer. Reinstall does not need the "Run as Administrator" option.

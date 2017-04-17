# KIG  version 3

## K Image Gallery maker 

[Installation](#instal) and [Usage](#usage)

KIG is a Windows command line tool. As of version 3 it also has a GUI.

KIG makes the HTML code for you and also resizes the file to both thumbnail and full size. It uses an included version of ImageMagic for image processing. It has 8 built in styles but can be extended with may more styles. 

### How to use the Graphical User Interface

Start the kig-app from your start menu. Choose the folder where your pictures are stored. Then enter your K project code. Then enter your gallery name. As an option for some border types you can enter a border color. The default is white. Then select the style of border you want to create and click the type you want created.

A notepad will open with the HTML you need to be pasted in. Also an Explorer window will open showing you the newly created images in both thumb and full size.

### <a name="usage"></a>How to use command line tool

Open a command prompt at the folder where the gallery photos resides on your computer. (To open a command prompt at the folder, select the folder with the mouse, then hold down shift and right mouse click and select **Open command window here.**)

#### Option 1 type just `kig` and press *[enter]*

Type in `kig` in the command window and answer the question prompts.

##### Example: Sample of output from typing `kig`
---
```
C:\images-for-gallery>kig

Making HTML and resized photos and thumbnails for K Image gallery.

Usage with parameters: kig iso_site_code gallery_id style_number [border_color]

You must specify a Project code.
Enter Project code: xxx
How do you want to distinguish this gallery from other galleries?
Gallery name or code: river
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
Choose theme number from the list above Blank = 1: 1

made html.txt
made gallery-river_01_thumb.jpg
made gallery-river_02_thumb.jpg
made gallery-river_01.jpg
made gallery-river_02.jpg
Finished!
```
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

made html.txt
made gallery-river_01_thumb.jpg
made gallery-river_02_thumb.jpg
made gallery-river_01.jpg
made gallery-river_02.jpg
Finished!
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


### <a name="instal"></a>Installation 

1. Download the latest release from https://github.com/indiamcq/kig/releases

2. Run the kig-installer

3. Look in you start menu for kig and kig-app.

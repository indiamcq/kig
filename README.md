# KIG
## K Image Gallery tool Installation and Usage

KIG is a Windows command line tool.

### How to use
Open a command prompt at the folder where the gallery photos resides on your computer. (To open a command prompt at the folder, select the folder with the mouse, then hold down shift and right mouse click and select Open command window here.)

Either type in kig and answer the question prompts or type in:
kig iso_site_code gallery_id style_number [site_number]

#### Example 1
```
kig ify artifacts 1 222
```
the above is where you know the site_number.

If you have the site-lookup.txt file in the c:\ProgramData\kig folder with the data in, you do not need the fourth parameter.

#### Example 2
```
kig ify artifacts 1
```

The resized files are named:
gallery-gallery_id_01.jpg and gallery-gallery_id_01_thumb.jpg

All JPG output is created in a subfolder called readytoupload. The HTML file html.txt is opened in notepad. That file is in the same folder as the source files.

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

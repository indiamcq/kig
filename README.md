# kig
K Image Gallery builder tool

KIG is a Windows command line tool.

Open a command prompt at the folder where the gallery photos resides on your computer. (To open a command prompt at the folder, select the folder with the mouse, then hold down shift and right mouse click and select Open command window here.)

Usage
Either type in kig and answer the question prompts or type in:
kig iso_site_code gallery_id style_number [site_number]

for example
kig ify artifacts 1 222

the above is where you know the site_number.

If you have the site-lookup.txt file with the data in you do not need this parameter.
kig ify artifacts 1

The files are named:
gallery-gallery_id_01.jpg and gallery-gallery_id_01_thumb.jpg

All JPG output is created in a subfolder called readytoupload. The HTML file html.txt is opened in notepad. That file is in the same folder as the source files.

Installation
Installation notes for install-kig.cmd
Unzip the ImageGallery.zip
Right click on the install-kig.cmd file and select "Run as administrator"
 

Click Yes to the User Account Control.


If you have Irfanview installed it should finish with no warning messages.



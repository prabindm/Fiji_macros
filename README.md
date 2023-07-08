# Fiji_macros

[Fiji] is a powerful image analysis software, used worldwide by researchers for variour purposes. It is an wonderful GUI which most people use, but we can also use scripting/macro to automate repeatative tasks. This repository is for those tasks. 

## 1. Make publication figures
This is a simple task where we take the immunofluorescence images and do 3 things.
1. Adjust the brightness in each channel so that the markers are clearly visibile to naked eye in a pdf.
2. Delete a channel/layer/color of the image we are not interested in.
3. Crop the image to a smaller size. We would like to select which portion of the image we want to have in our publication, so the cropping event should be interactive.
4. Use the smaller image and create a montage of all the remaining channels.
5. We want to direct the input and output directories and do the above changes only to the `.nd2` files that we collected from NIKON Confocal microscope.


[Fiji]: https://imagej.net/software/fiji/

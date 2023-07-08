# Fiji_macros

[Fiji] is a powerful image analysis software, used worldwide by researchers for variour purposes. It is an wonderful GUI which most people use, but we can also use scripting/macro to automate repeatative tasks. This repository is for those tasks. 

### 1.  Make publication figures
This is a simple task where we take the immunofluorescence images and do 3 things.
1. Adjust the brightness in each channel so that the markers are clearly visibile to naked eye in a pdf.
2. Delete a channel/layer/color of the image we are not interested in.
3. Crop the image to a smaller size. We would like to select which portion of the image we want to have in our publication, so the cropping event should be interactive.
4. Use the smaller image and create a montage of all the remaining channels.
5. We would like this to be saved as a `tif` file. 
6. We want to direct the input and output directories and do the above changes only to the `.nd2` files that we collected from NIKON Confocal microscope.
```{jpython}
/*
 * //Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".nd2") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
	
}

function processFile(input, output, file) {
	//setBatchMode(true); //hides subsequent image windows and processes in the background
	run("Bio-Formats", "open=[" + input + "/" + file + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	//imports images using Bio-formats
	
	setBatchMode(true);
	//run("Duplicate...", " ");
	//duplicateImageID = getImageID();
	//make a duplicate of the image and collect ID

	//setBatchMode("hide");
	//This brings up the current image window 
	//the next step is to set threshold. I want to be able to see the thresholding and be able to 
	//change it to what i think appropriate.
	originalImageID = getImageID(); //imageID is collected for later use
	//run("Brightness/Contrast...");
	
	
	// this is the DAPI Channel
	setMinAndMax(22, 112);
	run("Next Slice [>]");
	run("Delete Slice", "delete=channel");
	// this is the RED channel
	setMinAndMax(119, 265);
	run("Next Slice [>]");
	// this is the FAR-RED Channel
	setMinAndMax(162, 282);
	run("Previous Slice [<]");
	saveAs("tiff", output + "/" + file + "_LUTset" + ".tif");
	
	
	setBatchMode("show");
	// make and select a location
	makeRectangle(230, 230, 300, 300);
	title = "Place Rectangle";
	msg = "If necessary, move the rectangle to focus on a nucleus, then click \"OK\".";
  	waitForUser(title, msg);
  		// crop the image to 1 nucleus
  		run("Crop");
  		
  	setBatchMode("hide");
  		//make a montage
  		run("Make Montage...", "columns=3 rows=1 scale=1 border=1");
  
		saveAs("tiff", output + "/" + file + "Montage" + ".tif");
		close();
		showProgress(i, list.length);
	}
	

```
This is the final output of the image.

<image src = "pdm_4014_slide4_ch4_001.nd2Montage.jpg">




[Fiji]: https://imagej.net/software/fiji/

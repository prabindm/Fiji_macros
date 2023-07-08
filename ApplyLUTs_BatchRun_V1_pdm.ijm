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

	//setBatchMode("show");
	//This brings up the current image window 
	//the next step is to set threshold. I want to be able to see the thresholding and be able to 
	//change it to what i think appropriate.
	originalImageID = getImageID(); //imageID is collected for later use
	//run("Brightness/Contrast...");

	// this is the DAPI Channel
	setMinAndMax(22, 112);
	run("Next Slice [>]");
	// this is the Green channel
	run("Next Slice [>]");
	// this is the RED channel
	setMinAndMax(119, 265);
	run("Next Slice [>]");
	// this is the FAR-RED Channel
	setMinAndMax(162, 282);


	//run("Channels Tool...");
	Property.set("CompositeProjection", "Sum");
	Stack.setDisplayMode("composite");
	Stack.setActiveChannels("1011");
	saveAs("tiff", output + "/" + file + ".tif");
	close();
	showProgress(i, list.length);
	}
	

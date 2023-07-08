/*
 * //Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".jpg") suffix

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
	//Save results from all images in a single file
	saveAs("Results", output + "All_Results.tsv")
}

function processFile(input, output, file) {
	//setBatchMode(true); //hides subsequent image windows and processes in the background
	run("Bio-Formats", "open=[" + input + "/" + file + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	//imports images using Bio-formats
run("Set Scale...", "distance=1 known=0.65 unit=uM");	
run("Stack to RGB"); //multichannel files is flattened
run("8-bit"); // transformed to a B&W image
//setBatchMode("show");
originalImageID = getImageID(); //imageID is collected for later use
//So we will create a mask from the duplicate image, create a mask and number the objects in the image,
//and then overlay the mask on the original image to collect object properties such as intensity.

run("Duplicate...", " ");
duplicateImageID = getImageID();
//make a duplicate of the image and collect ID

run("Gaussian Blur...", "sigma=2");
//https://imagej.nih.gov/ij/developer/api/ij/plugin/filter/GaussianBlur.html
//This allows the edges to be more readily identified!


//setBatchMode("show");
//This brings up the current image window 
//the next step is to set threshold. I want to be able to see the thresholding and be able to 
//change it to what i think appropriate.

run("Threshold...");  // open Threshold tool
  title = "Threshold";
  msg = "If necessary, use the \"Threshold\" tool to\nadjust the threshold, then click \"OK\".";
  waitForUser(title, msg);
  selectImage(duplicateImageID);  //make sure we still have the same image
  getThreshold(lower, upper);
  setThreshold(lower, upper);

//setBatchMode("hide");
//send the rest of the image windows to background.

run("Create Mask"); //create a binary mask
run("Watershed"); // separate objects
save(output + "/Binary_OUTPUT_" + file);

run("Analyze Particles...", "size=200-Infinity exclude add"); 
//this gives results for the obeject on the mark

run("Clear Results");
//we dont need the results as it is on the mask

selectImage(originalImageID);
roiManager("Show ALl with label");//the mask is overlayed on the original image
roiManager("Deselect");
roiManager("Measure");

//save ROIs for current image
roiManager("Deselect");
roiManager("save", output+ "/" + file + "_ROI.zip");
roiManager("Deselect");
roiManager("Delete");
close();
}
	

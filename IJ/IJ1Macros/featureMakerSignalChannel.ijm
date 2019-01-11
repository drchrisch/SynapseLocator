/*
 * featureMakerSignalChannel macro called from Synapse Locator
 * 
 * Calculate set of features for given input tif (single or two channel).
 * 
 * drchrisch@gmail.com, cs12dec2018
 *
 */

/*
 * Define functions
 */
// function to count number of images and windows
function counterFcn() {
	it_list = getList("image.titles");
	w_list = getList("window.titles");
	print("Number of images: " + it_list.length + ", Number of windows: " + w_list.length);
	
	if (it_list.length==0)
    	 print("No image windows are open");
  	else {
    	 print("Image windows:");
    	 for (i=0; i<it_list.length; i++)
        	print("   "+it_list[i]);
  	}
	print("");

	if (w_list.length==0)
    	 print("No non-image windows are open");
  	else {
    	 print("Non-image windows:");
    	 for (i=0; i<w_list.length; i++)
        	print("   "+w_list[i]);
  	}
	print("");	
}

// function to check for active processing
function checkerFcn(searchString, maxN, waitTime, width) {
	counter=1;
	stillProcessing=1;
	success=0;
	while(stillProcessing){
		it_list = getList("image.titles");
		for (i=0; i<it_list.length; i++) {
			if (startsWith(it_list[i], searchString)) {
				if(width!=0) {
					selectImage(it_list[i]);
					width_=getWidth();
					if (width_!=width) {
						//print("Closing output: " + it_list[i] + ", width: " + width_);
						close();
						} else {
							//print("Almost ready");
							success=1;
					}
				} else {
					//print("Almost ready");
					success=1;									
				}
			}
		}
		if (success) {
			stillProcessing=0;
			print("Success after: " + counter*waitTime + " ms");
		} else {
			counter+=1;
			wait(waitTime);
			if (counter > maxN) {
				stillProcessing=0;
				success=0;
				print("PROCESSING ABORTED (not completed within: " + counter*waitTime + " ms)");
			}
		}
	}
	return success;
}


 /*
 * Start processing
 */
/*
 * Clear open windows (if any)
 */
list = getList("image.titles");
if (list.length>0) { run("Close All"); }



/*
 * Handle input
 */
args=getArgument;
//print("Arguments: " +args);
if (args=="") {
	print("Macro started directly");
	exit();
	// If no argument -> OpenDialog
	path2file=File.openDialog("Select a File");
	outpath=File.openDialog("Select a File");
	exitORnot="";
	} else {
		print("Macro started programmatically");
		args=split(args,",");
		path2file=args[0]; // Contains dataFile
		outpath=args[1]; // Contains path to output folder
		oldMin=parseInt(args[2]);
		oldMax=parseInt(args[3]);
		newMin=parseInt(args[4]);
		newMax=parseInt(args[5]);
		channelsN = args[6];
		avgSpotSize = args[7];
		exitORnot = args[8]; // Exit after run or not
	}

/*
 * Prepare input/output names
 */
fileName = File.getName(path2file);
inpath = File.getParent(path2file);
//print("File:", path2file);
//print("Name:", fileName);
//print("Directory:", inpath);
//outpath=inpath + File.separator + "featureData";

print("Running featureMakerSignalChannel macro");
print("Processing input: " + path2file);
print("Processing to output: " + outpath);


setBatchMode(true);
/*
 * Open stack (two channel input)
 */
open(path2file);
//print("Loaded image: " + getTitle());
//getDimensions(width, height, channels, slices, frames);
//print("Width: " + width);
//print("Slices: " + slices);
rename("Input");
getDimensions(width, height, channels, slices, frames);

if (startsWith(channelsN, "double")) {
	/*
	 * Start processing, deinterleave if needed (use Image/Stacks/Tools/Make substack)
	 */
	//run("Deinterleave", "how=2"); NOT WORKING IN BATCHMODE!!!!!!
	//run("Make Substack...", "  slices={first-last-increment}");
	print("Deinterleave");

	selectImage("Input");
	parameters="slices=2-" + slices*channels + "-" + 2;
	run("Make Substack...", parameters);
	if(checkerFcn("Substack (2-", 10000, 100, 0)) {print("...");} else {exit("Max number of iterations reached!");}
	rename("masterStack");
	close("Input");
	//counterFcn();
} else {
	selectImage("Input");
	rename("masterStack");
}


/*
 * Rescale!
*/
selectImage("masterStack");
run("32-bit");
parameters="";
parameters+="value=" + oldMin + " stack";
run("Subtract...", parameters);
newFactor=newMax-newMin;
parameters="";
parameters+="value=" + newFactor + " stack";
run("Multiply...", parameters);
oldFactor=oldMax-oldMin;
parameters="";
parameters+="value=" + oldFactor + " stack";
run("Divide...", parameters);
parameters="";
parameters+="value=-" + newMin + " stack";
run("Subtract...", parameters);
run("16-bit");


/*
 * Set FeatureJ options and iterate through feature calculations
 */
run("FeatureJ Options", "isotropic save");
if (avgSpotSize == "small") {
	scales = newArray(1.0, 2.0, 3.0);
} else if (avgSpotSize == "medium") {
	scales = newArray(2.0, 3.5, 5.0);
} else if (avgSpotSize == "large") {
	scales = newArray(2.5, 4.0, 6.0);
}

// Laplacian
for (sfi=0; sfi<scales.length; sfi++) {
	sf=scales[sfi];
	parameters="";
	parameters+="compute smoothing=";
	parameters+=toString(sf);
	selectImage("masterStack");
	run("FeatureJ Laplacian",parameters);
	list = getList("image.titles");
	for (i=0; i<list.length; i++) {
		selectImage(list[i]);
		if (startsWith(list[i],"masterStack Laplacian")) {
			tmpName=outpath + File.separator + "Laplacian_SignalChannel_" + toString(sf) + ".tif";
			saveAs("Tiff", tmpName);
			close();
		}
	}
}


run("Close All");
setBatchMode(false);

print("Macro 'featureMakerSignalChannel' finished");
if (startsWith(exitORnot,"newStart")) { eval("script", "System.exit(0);"); } { exit(); }


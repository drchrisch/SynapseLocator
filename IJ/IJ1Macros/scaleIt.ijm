/*
 * scaleIt macro to scale input image (Synapse Locator helper)
 * 
 * Apply run("TransformJ Scale") to input tif (2 channel).
 * (Saves output as input name plus '_scaled')
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

// function to combine channels (interleave) and save under given name
function interleaveNsave(tmpName1, tmpName2, out_name) {
	/*
	 * Combine filtered data and save
	 * 	
	 * run("Interleave", "stack_1=Stack#1 stack_2=Stack#2");
	 */
	print("Interleave images");
	parameters="";
	parameters+="stack_1=";
	parameters+=tmpName1;
	parameters+=" stack_2=";
	parameters+=tmpName2;
	run("Interleave", parameters);
	if(checkerFcn("Combined Stacks", 100000, 10, 0)) {print("...");} else {exit("Max number of iterations reached!");}		
	selectImage("Combined Stacks");
	saveAs("Tiff", out_name);
	return;
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
	print("scaleIt macro started directly");
	// If no argument -> OpenDialog and get path to file
	path2file=File.openDialog("Select a File");
	name = File.getName(path2file);
	path = File.getParent(path2file);
	name_scaled = substring(name, 0, lastIndexOf(name, ".tif")) + '_scaled.tif';
	path2outfile = path + File.separator + name_scaled;
    exitORnot = "";
	Dialog.create("scaleIt params");
	Dialog.addChoice("Scale Process:", newArray("upscale", "downscale"));
	Dialog.addChoice("Channel N:", newArray("single", "double"));
	Dialog.show();
	scaleProcess = Dialog.getChoice();
	if (startsWith(scaleProcess, "up")) {sampleFactor = 2;} else {sampleFactor = 0.5;}
	channelsN = Dialog.getChoice();
} else {
	print("scaleIt macro started programmatically");
	args=split(args,",");
	path2file=args[0]; // Contains input dataFile
	path2outfile=args[1]; // Contains output dataFile
	scaleProcess=args[2];
	if (startsWith(scaleProcess, "up")) {sampleFactor = 2;} else {sampleFactor = 0.5;}
	channelsN = args[3];
	exitORnot=args[4]; // Exit after run or not
	}


/*
* Prepare input/output names
*/
name = File.getName(path2file);
tmpName1 = "STACK1";
tmpName2 = "STACK2";

print("Hello from scaleIt. Sample Factor = " + sampleFactor);
print("Processing input " + name);
print("Saving output to " + path2outfile);

/*
 * Start processing, Iterate through file list
 */
setBatchMode(true);

/*
* Start processing, open file, get some infos
*/
print("Loading data");
open(path2file);
getDimensions(width, height, channels, slices, frames);
//counterFcn();


if (startsWith(channelsN, "single")) {
	selectImage(name);
	
	/*		 
	 * Upsample image stacks
	 * 
	 * run("TransformJ Scale");
	 */
	print("Upsampling data");

	run("TransformJ Options", "adopt progress log");
	parameters = "x-factor=1.0 y-factor=1.0 z-factor=" + sampleFactor + " interpolation=[Quintic B-Spline] preserve";

	selectImage(name);
	kwd = name + " scaled";
	run("TransformJ Scale", parameters);
	//"x-factor=1.0 y-factor=1.0 z-factor=2 interpolation=[Quintic B-Spline] preserve");
	if(checkerFcn(kwd, 100000, 100, 0)) {print("...");} else {exit("Max number of iterations reached!");}
	close(name);
	selectImage(kwd);
	saveAs("Tiff", path2outfile);
} else {
	/*
	 * Start processing, deinterleave if needed (use Image/Stacks/Tools/Make substack)
	 */
	//run("Deinterleave", "how=2"); NOT WORKING IN BATCHMODE!!!!!!
	//run("Make Substack...", "  slices={first-last-increment}");
	print("Deinterleave");

	selectImage(name);
	parameters="slices=1-" + slices*channels + "-" + 2;
	run("Make Substack...", parameters);
	if(checkerFcn("Substack (1-", 10000, 100, 0)) {print("...");} else {exit("Max number of iterations reached!");}
	rename(tmpName1);

	selectImage(name);
	parameters="slices=2-" + slices*channels + "-" + 2;
	run("Make Substack...", parameters);
	if(checkerFcn("Substack (2-", 10000, 100, 0)) {print("...");} else {exit("Max number of iterations reached!");}
	rename(tmpName2);	
	//counterFcn();
	close(name);

	/*		 
	 * Upsample image stacks
	 * 
	 * run("TransformJ Scale");
	 */
	print("Upsampling data");

	run("TransformJ Options", "adopt progress log");
	parameters = "x-factor=1.0 y-factor=1.0 z-factor=" + sampleFactor + " interpolation=[Quintic B-Spline] preserve";

	selectImage(tmpName1);
	kwd = tmpName1 + " scaled";
	run("TransformJ Scale", parameters);
	//"x-factor=1.0 y-factor=1.0 z-factor=2 interpolation=[Quintic B-Spline] preserve");
	if(checkerFcn(kwd, 100000, 100, 0)) {print("...");} else {exit("Max number of iterations reached!");}
	close(tmpName1);
	selectImage(kwd);
	rename(tmpName1);

	selectImage(tmpName2);
	kwd = tmpName2 + " scaled";
	run("TransformJ Scale", parameters);
	//"x-factor=1.0 y-factor=1.0 z-factor=2 interpolation=[Quintic B-Spline] preserve");
	if(checkerFcn(kwd, 100000, 100, 0)) {print("...");} else {exit("Max number of iterations reached!");}
	close(tmpName2);
	selectImage(kwd);
	rename(tmpName2);

	// Combine raw data and save
	print("Save output");
	counterFcn();
	interleaveNsave(tmpName1, tmpName2, path2outfile);
	//counterFcn();
}



run("Close All");
setBatchMode(false);
//counterFcn();

print("Macro 'scaleIt' finished");
if (startsWith(exitORnot,"newStart")) { eval("script", "System.exit(0);"); } { exit(); }


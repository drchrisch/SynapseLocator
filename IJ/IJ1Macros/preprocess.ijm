/*
 * preprocess macro to process input to Synapse Locator
 * 
 * Apply filter and deconvolution to input tifs (2 channels, interleaved).
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
}


/*
 * Start processing
 */

print("\\Clear");

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
path2file=newArray(2);
if (args=="") {
	print("preprocess macro started directly");
	// If no argument -> OpenDialog and get path to file
	path2file[0]=File.openDialog("Select a File");
	path2file[1]=File.openDialog("Select a File");
	path2out = File.getParent(path2file[0]); // That's a bit special, set output dir to input dir.
    exitORnot = "";
	Dialog.create("preprocess params");
	Dialog.addChoice("Smoothing:", newArray("Median Filter", "Gaussian Smooth"));
	Dialog.addCheckbox("Bandpass Filter", true);
	Dialog.addCheckbox("Subtract Background", true);
	Dialog.addCheckbox("Deconv", true);
	Dialog.addNumber("Median Filter xy:", 1);
	Dialog.addNumber("Median Filter z:", 0);
	Dialog.addNumber("Gaussian sigma:", 0.5);
	Dialog.addNumber("Bandpass min:", 2);
	Dialog.addNumber("Bandpass max:", 25);
	//Dialog.addNumber("Subtract Radius:", 250);
	Dialog.addNumber("Subtract Radius:", 250);
	Dialog.addNumber("PSF xy:", 0.4);
	Dialog.addNumber("PSF z:", 2.0);
	//Dialog.addNumber("Deconv RF:", 0.01);
	Dialog.addNumber("Deconv RF:", 0.0001);
	Dialog.addNumber("Voxel Size xy:", 0.2);
	//Dialog.addNumber("Voxel Size xy:", 0.146);
	Dialog.addNumber("Voxel Size z:", 0.5);
	Dialog.show();
	smoothing = Dialog.getChoice();
	if (startsWith(smoothing, "Median")) {doSmoothing=1;} else {doSmoothing=0;}
	doBandpass=Dialog.getCheckbox();
	doSubtract=Dialog.getCheckbox();
	doDeconvolution=Dialog.getCheckbox();
	medFiltxy = Dialog.getNumber();
	medFiltz = Dialog.getNumber();
	doMedianFilterParams=newArray(medFiltxy, medFiltxy, medFiltz);
	doGaussianSmoothParams = newArray(Dialog.getNumber());
	doBandpassParams_min=Dialog.getNumber();
	doBandpassParams_max=Dialog.getNumber();
	doBandpassParams=newArray(doBandpassParams_min, doBandpassParams_max);	
	doSubtractParams=newArray(Dialog.getNumber());
	PSFxy = Dialog.getNumber();
	PSFz = Dialog.getNumber();
	PSF = newArray(PSFxy, PSFxy, PSFz);	
	doDeconvolutionParams=newArray(Dialog.getNumber());
	voxelSizexy = Dialog.getNumber();
	voxelSizez = Dialog.getNumber();
    voxelSize=newArray(voxelSizexy, voxelSizexy, voxelSizez);
} else {
		print("preprocess macro started programmatically");
		args=split(args,",");
		path2file[0]=args[0]; // Contains dataFile 1
		path2file[1]=args[1]; // Contains dataFile 2
		path2out=args[2]; // Contains output dir
		exitORnot=args[3]; // Exit after run or not
		doSmoothing=args[4]; // Start with median filter or Gaussian smooth
		doBandpass=args[5]; // Use bandpass filter
		doSubtract=args[6]; // Subtract background
		doDeconvolution=args[7]; // Do deconvolve
		doMedianFilterParams=split(args[8]); // Start with median filter or Gaussian smooth
		doGaussianSmoothParams=split(args[9]); // Start with median filter or Gaussian smooth
		doBandpassParams=split(args[10]); // Use bandpass filter
		doSubtractParams=split(args[11]); // Subtract background
		PSF=split(args[12]); // PSF
		doDeconvolutionParams=split(args[13]); // Do deconvolve
		voxelSize=split(args[14]);
	}


for (doMedianFilterParams_i=0; doMedianFilterParams_i<doMedianFilterParams.length; doMedianFilterParams_i++) {
	doMedianFilterParams[doMedianFilterParams_i]=parseFloat(doMedianFilterParams[doMedianFilterParams_i]);
}
for (doGaussianSmoothParams_i=0; doGaussianSmoothParams_i<doGaussianSmoothParams.length; doGaussianSmoothParams_i++) {
	doGaussianSmoothParams[doGaussianSmoothParams_i]=parseFloat(doGaussianSmoothParams[doGaussianSmoothParams_i]);
}
for (doBandpassParams_i=0; doBandpassParams_i<doBandpassParams.length; doBandpassParams_i++) {
	doBandpassParams[doBandpassParams_i]=parseFloat(doBandpassParams[doBandpassParams_i]);
}
for (doSubtractParams_i=0; doSubtractParams_i<doSubtractParams.length; doSubtractParams_i++) {
	doSubtractParams[doSubtractParams_i]=parseFloat(doSubtractParams[doSubtractParams_i]);
}
for (PSF_i=0; PSF_i<PSF.length; PSF_i++) {
	PSF[PSF_i]=parseFloat(PSF[PSF_i]);
	voxelSize[PSF_i]=parseFloat(voxelSize[PSF_i]);
}
for (doDeconvolutionParams_i=0; doDeconvolutionParams_i<doDeconvolutionParams.length; doDeconvolutionParams_i++) {
	doDeconvolutionParams[doDeconvolutionParams_i]=parseFloat(doDeconvolutionParams[doDeconvolutionParams_i]);
}

print("PSF:");
Array.print(PSF);

/*
 * Start processing, Iterate through file list
 */
setBatchMode(true);


for (file_i=0; file_i<path2file.length; file_i++) {
	/*
	* Prepare input/output names
	*/
	path = File.getParent(path2file[file_i]);
	name = File.getName(path2file[file_i]);
	name_raw = substring(name, 0, lastIndexOf(name, ".tif")) + '_raw.tif';
	name_mf = substring(name, 0, lastIndexOf(name, ".tif")) + '_mf.tif';
	name_proc = substring(name, 0, lastIndexOf(name, ".tif")) + '_proc.tif';
	out_raw = path2out + File.separator + name_raw;
	out_mf = path2out + File.separator + name_mf;
	out_proc = path2out + File.separator + name_proc;
	tmpName1="STACK1";
	tmpName2="STACK2";

	print("Processing input " + toString(1 + file_i) + ": " + path2file[file_i]);
	
	/*
	* Start processing, open file, get some infos
	*/
	print("Loading data");
	open(path2file[file_i]);
	getDimensions(width, height, channels, slices, frames);
	//print("Width: " + width);
	//print("Height: " + height);
	//print("Channels: " + channels);
	//print("Slices: " + slices);
	//print("Frames: " + frames);  
	//counterFcn();
	
	
	/*
	 * Start processing, deinterleave (use Image/Stacks/Tools/Make substack)
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

	// Combine raw data and save
	print("Save raw output");
	interleaveNsave(tmpName1, tmpName2, out_raw);
	//counterFcn();

		
	/*
	 * Continue processing, use input settings
	 */
	print("Filter data");
	 /*
	 * 
	 * (filter (use Plugins/3D/3D Fast Filters ) or Plugins-Process-Smooth (3D))
	 * 
	 * parameters="filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=1.0 Nb_cpus=4";
	 * Also tested with: run("Median 3D...", "x=1 y=1 z=0");
	 * parameters="x=" + medFilt[0] + " y=" + medFilt[1] + " z=" + medFilt[2];
	 * run("Median 3D...", parameters);
	 */
	/*
	if (doSmoothing) {
		print("Median Filter");
		selectWindow(tmpName1);
		parameters="radius=" + doMedianFilterParams[0] + " stack";
		run("Median...", parameters);

		selectWindow(tmpName2);
		parameters="radius=" + doMedianFilterParams[0] + " stack";
		run("Median...", parameters);
	*/
	if (doSmoothing) {
		print("Median Filter");
		selectWindow(tmpName1);
		parameters="filter=Median radius_x_pix=" + doMedianFilterParams[0] + " radius_y_pix=" + doMedianFilterParams[1] + " radius_z_pix=" + doMedianFilterParams[2] +  " Nb_cpus=4";
		run("3D Fast Filters", parameters);
		if(checkerFcn("3D_Median", 100000, 100, 0)) {print("...");} else {exit("Max number of iterations reached!");}
		close(tmpName1);
		selectImage("3D_Median");
		rename(tmpName1);
	
		selectWindow(tmpName2);
		run("3D Fast Filters",parameters);
		if(checkerFcn("3D_Median", 100000, 100, 0)) {print("...");} else {exit("Max number of iterations reached!");}
		close(tmpName2);
		selectImage("3D_Median");
		rename(tmpName2);
	} else {
		print("Gaussian Smoothing");
		selectWindow(tmpName1);
		parameters="method=Gaussian sigma=" + doGaussianSmoothParams[0] + " use";
		run("Smooth (3D)", parameters);
		if(checkerFcn("Smoothed", 100000, 100, 0)) {print("...");} else {exit("Max number of iterations reached!");}
		close(tmpName1);
		selectImage("Smoothed");
		rename(tmpName1);
	
		selectWindow(tmpName2);
		run("Smooth (3D)", parameters);
		if(checkerFcn("Smoothed", 100000, 100, 0)) {print("...");} else {exit("Max number of iterations reached!");}
		close(tmpName2);
		selectImage("Smoothed");
		rename(tmpName2);
	}
	
	// Combine (median) filtered data and save
	print("Save filtered output");
	interleaveNsave(tmpName1, tmpName2, out_mf);
		
	if (doBandpass) {
		parameters=	"filter_large=" + doBandpassParams[1] + " filter_small=" + doBandpassParams[0] + " suppress=None process";
		selectWindow(tmpName1);
		run("Bandpass Filter...", parameters);
		selectWindow(tmpName2);
		run("Bandpass Filter...", parameters);
	}

/* 	if (doSubtract) {
		parameters="rolling=" + doSubtractParams[0] + " sliding disable stack";
		selectWindow(tmpName1);
		run("Subtract Background...", parameters);
		selectWindow(tmpName2);
		run("Subtract Background...", parameters);
	}
 */

	/*
	 * Check for deconvolution step
	 */
	if (doDeconvolution) {
		/*
		* Continue processing, deconvolve
		*/
		close("Combined Stacks");
		list = getList("image.titles");
		for (i=0; i<list.length; i++) {
			if (endsWith(list[i],"_mf.tif")) {close(list[i]);}
		}
		//counterFcn();
		print("Deconvolve data");

		// Voxel size: [0.17, 0.17, 0.5]
		// FWHM = 2.355 standard deviation sigma (FWHM: ([0.4, 0.4, 2.0]/ [0.17, 0.17, 0.5]) / 2.355 => sigma: [1.0, 1.0, 1.7]
		// psf = " -psf synthetic Gaussian 1.0 1.0 1.7 size 50 50 50 intensity 255.0";
		sigma=newArray(PSF.length);
		for (sigma_i=0; sigma_i<PSF.length; sigma_i++) {
			sigma[sigma_i]=PSF[sigma_i]/voxelSize[sigma_i]/2.355;
		}
		//print("sigma 1: " + sigma[0] + ", sigma 2: " + sigma[1] + ", sigma 3: " + sigma[2]);
		
		psf = " -psf synthetic Gaussian ";
		psf += toString(sigma[0]) + " ";
		psf += toString(sigma[1]) + " ";
		psf += toString(sigma[2]) + " ";
		psf += "size 32 32 32 intensity 255.0";
		algorithm = " -algorithm RIF " + doDeconvolutionParams[0];
		parameters = "";
		parameters += " -display no";
		parameters += " -out stack STACKdeconv normalized short nosave";
		parameters += " -constraint nonnegativity";
		parameters += " -pad NO NO 32 32";
		parameters += " -apo NO NO";
		parameters += " -monitor no";
		parameters += " -fft Academic";

		image = " -image platform STACK1";
		if(width>512) {waitTime=100;} else {waitTime=10;}
		run("DeconvolutionLab2 Run", image + psf + algorithm + parameters);
		if(checkerFcn("STACKdeconv", 100000, waitTime, width)) {print("...");} else {exit("Max number of iterations reached!");}
		close(tmpName1);
		selectImage("STACKdeconv");
		rename(tmpName1);

		image = " -image platform STACK2";
		run("DeconvolutionLab2 Run", image + psf + algorithm + parameters);
		if(checkerFcn("STACKdeconv", 100000, waitTime, width)) {print("...");} else {exit("Max number of iterations reached!");}
		close(tmpName2);
		selectImage("STACKdeconv");
		rename(tmpName2);
		//counterFcn();
	}

	if (doSubtract) {
		parameters="rolling=" + doSubtractParams[0] + " sliding disable stack";
		selectWindow(tmpName1);
		run("Subtract Background...", parameters);
		selectWindow(tmpName2);
		run("Subtract Background...", parameters);
	}

	if (doBandpass || doSubtract || doDeconvolution) {
		// Combine filtered data and save
		print("Save preprocessed output");
		interleaveNsave(tmpName1, tmpName2, out_proc);
		//counterFcn();
	}

	//counterFcn();
	run("Close All");
}

//run("Close All");
setBatchMode(false);

print("Macro 'preprocess' finished");
if (startsWith(exitORnot,"newStart")) { eval("script", "System.exit(0);"); } { exit(); }


	


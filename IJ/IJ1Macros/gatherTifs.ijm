/*
 * gatherTifs macro to process output from Synapse Locator
 * 
 *
 * drchrisch@gmail.com, cs12dec2018
 *
 */


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
if (args=="") {
	exit ("No argument!");
	} else {
		//print("Arguments: " +args);
		args=split(args,",");
		exitORnot = args[args.length-1]; // Exit after run or not is last input argument
		args=Array.trim(args,args.length-1); // args now holds data input and output
		//print("Arguments given\tArguments length: " + args.length);
	}

/*
 * Prepare output names
 */
dataPath=args[0];
outPath=args[0]+File.separator+args[1];
outPath1=args[0]+File.separator+replace(args[1],'Composite_proc','G0R0_SLready');
outPath2=args[0]+File.separator+replace(args[1],'Composite_proc','G1R1_SLready');
print("Starting gatherTifs macro with");
print("Save output as: " + outPath);
print("Save output #1 as: " + outPath1);
print("Save output #2 as: " + outPath2);

colors=newArray("Green", "Red", "Green", "Red", "Magenta", "Magenta"); // Define channel colors for output stack!

setBatchMode(true);

/*
 * Open files
 */
run("Conversions...", "scale");
//run("Bio-Formats Macro Extensions");
for (i=2; i<args.length; i++) {
	open(dataPath+File.separator+args[i]);
	//parameters="open=" + dataPath + File.separator + args[i];
	//Ext.openImagePlus(dataPath+File.separator+args[i]);
	//run("Bio-Formats Windowless Importer", parameters);
	run("32-bit");
}

/*
 * Set contrast
 */
list = getList("image.titles");
for (i=0; i<(list.length); i++) {
	selectImage(list[i]);
	resetMinAndMax();
	run("Enhance Contrast", "saturated=0.35");
	run(colors[i]);
}

/*
 * Save all images and identified spots and signals as multichannel tif!
 * Save data#1 and transformed data#2 as separate interleaved tif!
*/
// part 1
parameters="c1" + "=" + list[0];
for (i=1; i<(list.length); i++) {
	parameters+=" c" + toString(i+1) + "=" + list[i];
}
parameters+=" create";
run("Merge Channels...", parameters);
saveAs("Tiff", outPath);

/*
 * Check input data for "proc" and make SLready output!
*/
if (matches(args[2], ".*proc.*")){
	// part 2a
	run("Close All");
	open(dataPath+File.separator+args[2]);
	open(dataPath+File.separator+args[3]);
	list = getList("image.titles");
	parameters="stack_1=" + list[0] + " stack_2=" + list[1];
	run("Interleave", parameters);
	saveAs("Tiff", outPath1);

	// part 2ab
	run("Close All");
	open(dataPath+File.separator+args[4]);
	open(dataPath+File.separator+args[5]);
	list = getList("image.titles");
	parameters="stack_1=" + list[0] + " stack_2=" + list[1];
	run("Interleave", parameters);
	saveAs("Tiff", outPath2);
}

run("Close All");
setBatchMode(false);

print("Macro 'gatherTifs' finished");
if (startsWith(exitORnot,"newStart")) { eval("script", "System.exit(0);"); } { exit(); }
